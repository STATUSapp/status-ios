//
//  STChatController.m
//  Status
//
//  Created by Andrus Cosmin on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STChatController.h"
#import "SRWebSocket.h"
#import "STConstants.h"
#import "STNetworkQueueManager.h"
#import "STLoginService.h"
#import "STCoreDataManager.h"
#import "STDAOEngine.h"
#import "STNotificationsManager.h"
#import "STNotificationsManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "STGetChatUrlAndPortRequest.h"

#import "CreateDataModelHelper.h"
#import "NSString+VersionComparison.h"
#import "CreateDataModelHelper.h"
#import "STLocalNotificationService.h"
#import "BadgeService.h"
#import "STCoreDataMessageSync.h"

NSString *const kFirstChatVersion = @"1.0.4";

@interface STChatController()<SRWebSocketDelegate>{
    SRWebSocket *_webSocket;
    AFNetworkReachabilityManager* _reachabilityManager;
    NSTimer *_pingTimer;
}

@property (nonatomic, assign) BOOL chatLoadingParameters;

@end

@implementation STChatController

+(STChatController*)sharedInstance{
    static STChatController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedManager = [[self alloc] init];
        _sharedManager.chatPort = -1;//not defined
    });
    
    return _sharedManager;
                  
}

-(void)forceReconnect{
    [self close];
//    [self reconnect];
}
- (void)connectChat
{
    if ([_chatSocketUrl rangeOfString:@"http"].location == NSNotFound) {
        //we should add http to the socket string
        _chatSocketUrl = [NSString stringWithFormat:@"http://%@", _chatSocketUrl];
    }
    _currentRoomId = nil;
    [self close];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%ld",_chatSocketUrl, (long)_chatPort]]]];
    _webSocket.delegate = self;
    _status = STWebSockerStatusConnecting;
    
    [_webSocket open];
}

- (void)reconnect
{
    if (_status != STWebSockerStatusClosed) {
        return;
    }
    
    if (![CoreManager loggedIn] &&
        [FBSDKAccessToken currentAccessToken]==nil&&
        [[CoreManager loginService] currentUserUuid]==nil)
    {
        NSLog(@"Missing Acces token. Connect when available");
        return;
    }
    if (_chatSocketUrl==nil ||_chatPort == -1) {
        if (_chatLoadingParameters == NO) {
            _chatLoadingParameters = YES;
            __weak STChatController *weakSelf = self;
            [STGetChatUrlAndPortRequest getReconnectInfoWithCompletion:^(id response, NSError *error) {
                __strong STChatController *strongSelf = weakSelf;
                strongSelf.chatLoadingParameters = NO;
                if ([response[@"status_code"] integerValue] == 200) {
                    strongSelf.chatSocketUrl = response[@"hostname"];
                    strongSelf.chatPort = [response[@"port"] integerValue];
                    [strongSelf connectChat];
                    
                }
                
            } failure:^(NSError *error) {
                __strong STChatController *strongSelf = weakSelf;
                strongSelf.chatLoadingParameters = NO;
                NSLog(@"Get chat reconnect params failed : %@", error);
            }];
        }
        else
        {
            //wait the next reconnect
        }
    }
    else
        [self connectChat];
    
}

- (void)close{
    [_webSocket close];
    _status = STWebSockerStatusClosed;
    _webSocket.delegate = nil;
    _webSocket = nil;
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    _status = STWebSockerStatusConnected;
    _currentUserId = nil;
     _authenticated = NO;
    [self authenticate];

    //add a ping timer since the iOS will disconect the socket after 60 seconds of idle.
    _pingTimer = [NSTimer scheduledTimerWithTimeInterval:50.f
                                                  target:self
                                                selector:@selector(pingAction:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
//    NSLog(@":( Websocket Failed With Error %@", error);
    
    _status = STWebSockerStatusClosed;
    if (_delegate && [_delegate respondsToSelector:@selector(chatDidClose)])
        [_delegate chatDidClose];
    _authenticated = NO;
    _currentUserId = nil;
    _webSocket = nil;
    [_pingTimer invalidate];
    _pingTimer = nil;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self performSelector:@selector(reconnect) withObject:nil afterDelay:5.f];
       
    }

}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message;
{
    NSError *err = nil;
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    NSLog(@"Received \"%@\"", response);
    
    if ([response[@"type"] isEqualToString:@"login"]) {
        if ([response[@"status"] boolValue]==YES) {
            _authenticated = YES;
            _currentUserId =  [CreateDataModelHelper validStringIdentifierFromValue:response[@"userID"]];
            if (_currentUserId == nil) {
                //fall back when the chat is not connected
                _currentUserId = [[CoreManager loginService] currentUserUuid];
            }
            for (NSDictionary *message in response[@"notReceivedMessages"]) {
                [self addMessage:message seen:NO];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(chatDidAuthenticate)]) {
                [_delegate performSelector:@selector(chatDidAuthenticate)];
            }
            [[CoreManager localNotificationService] postNotificationName:STChatControllerAuthenticate object:nil userInfo:nil];

            [[CoreManager localNotificationService] postNotificationName:kUnreadMessagesCountChangedNotification object:nil userInfo:@{kUnreadMessagesCountKey:response[@"unseenMessagesCount"]}];
        }
        else
        {
            [self authenticate];
        }
    }
    else if ([response[@"type"] isEqualToString:@"enterRoom"]){
        if([response[@"error"] boolValue] == YES){
            if (_delegate && [_delegate respondsToSelector:@selector(userWasBlocked)])
                [_delegate userWasBlocked];
        }
        else{
            NSLog(@"Room Id: %@", response[@"roomID"]);
            _currentRoomId = response[@"roomID"];
            if (_delegate && [_delegate respondsToSelector:@selector(chatDidOpenRoom:)]) {
                [_delegate performSelector:@selector(chatDidOpenRoom:) withObject:response[@"roomID"]];
            }
        }
    }
    else if ([response[@"type"] isEqualToString:@"message"]){
        if([response[@"error"] boolValue] == YES){
            if (_delegate && [_delegate respondsToSelector:@selector(userWasBlocked)])
                [_delegate userWasBlocked];
        }
        else{
            BOOL seen = [_currentRoomId isEqualToString:response[@"roomID"]];
            _loadMore = NO;
            [self addMessage:response seen:seen];
        }
    }
    else if ([response[@"type"] isEqualToString:@"leaveRoom"]){
        NSLog(@"Room left");
        _currentRoomId = nil;
    }
    else if ([response[@"type"] isEqualToString:@"getRoomMessages"]){
        for (NSDictionary *message in response[@"messages"]) {
            NSMutableDictionary *messageDict = [NSMutableDictionary dictionaryWithDictionary:message];
            messageDict[@"roomID"] = response[@"roomID"];
            [self addMessage:messageDict seen:YES];
        }
    }
    else if ([response[@"type"] isEqualToString:@"blockUser"]){
        if ([response[@"roomId"] isKindOfClass:[NSString class]] &&
            [response[@"roomId"] isEqualToString:_currentRoomId]) {
            if (_delegate && [_delegate respondsToSelector:@selector(userWasBlocked)])
                [_delegate userWasBlocked];
        }
        else
        {
            if (_delegate && [_delegate respondsToSelector:@selector(userBlockSuccess)])
                [_delegate userBlockSuccess];
        }
        
    }
    else if([response[@"type"] isEqualToString:@"syncRoomMessages"]){
        for (NSDictionary *message in response[@"messages"]) {
            NSMutableDictionary *messageDict = [NSMutableDictionary dictionaryWithDictionary:message];
            messageDict[@"roomID"] = response[@"roomID"];
            [self addMessage:messageDict seen:YES];
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    _currentUserId = nil;
    _status = STWebSockerStatusClosed;
    _authenticated = NO;
    _webSocket = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(chatDidClose)]) {
        [_delegate chatDidClose];

    }
    [_pingTimer invalidate];
    _pingTimer = nil;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self performSelector:@selector(reconnect) withObject:nil afterDelay:2.f];
    }
}

#pragma mark - Communication

-(void)authenticate{
    
    if ([CoreManager loggedIn] &&
        [FBSDKAccessToken currentAccessToken]!=nil&&
        [[CoreManager loginService] currentUserUuid]!=nil) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"type": @"login", @"token": [[CoreManager networkService] getAccessToken]} options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [_webSocket send:jsonString];
    }
    else
    {
        NSLog(@"Authenticate on login/register");
    }
   
}

-(void)openChatRoomForUserId:(NSString *)userId{
    if(userId==nil)
        return;
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"type": @"enterRoom", @"userId": userId} options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_webSocket send:jsonString];
}

-(void)leaveRoom:(NSString *)roomId{
    if(_status != STWebSockerStatusConnected){
        return;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"type": @"leaveRoom", @"roomId": roomId} options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_webSocket send:jsonString];
}

-(void)leaveCurrentRoom{
    if (_currentRoomId!=nil) {
        [self leaveRoom:_currentRoomId];
    }
}

- (void)sendMessage:(NSString *)message inRoom:(NSString *)roomId{
    NSString *newMessage = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"message":newMessage, @"type":@"message", @"roomId":roomId} options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_webSocket send:jsonString];
}

- (void)blockUserWithId:(NSString *)userId{
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"type":@"blockUser", @"userId":userId} options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_webSocket send:jsonString];
}

-(void)getRoomMessages:(NSString *)roomId withOffset:(NSInteger)offset{

    if (roomId==nil) {
        return;
    }
    _loadMore = YES;
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"limit":@(20), @"type":@"getRoomMessages", @"roomId":roomId, @"offset":@(offset)} options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_webSocket send:jsonString];
}

-(void)syncRoomMessages:(NSString *)roomId withMessagesIds:(NSArray *)messagesUuids{
    if (roomId==nil || messagesUuids.count == 0) {
        return;
    }
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"type":@"syncRoomMessages", @"roomId":roomId,@"messageIDs":messagesUuids} options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_webSocket send:jsonString];
}

-(void)pingAction:(id)sender{
    if (_webSocket.readyState == SR_OPEN) {
        [_webSocket sendPing:nil];
    }
}

#pragma mark - Local Storage
-(void)addMessage:(NSDictionary *)message seen:(BOOL) seen {
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionaryWithDictionary:message];
    NSString *stringMsg = resultDict[@"message"];
    if (![stringMsg isKindOfClass:[NSString class]]) {
        NSLog(@"Ignoring null messages");
        return;
    }
    
    NSString *roomId = resultDict[@"roomID"];
    if (roomId == nil) {
        roomId = resultDict[@"roomId"];
        if (roomId == nil) {
            NSLog(@"Not good check this out");
            return;
        }
    }
    
    NSString *uuid = resultDict[@"id"];
    if (uuid == nil || [uuid isEqual:[NSNull null]]) {
        NSLog(@"wrong id returned. Debug this");
        return;
    }
    
//    BOOL received = ![resultDict[@"userId"] isEqualToString:[STFacebookController sharedInstance].currentUserId];
    NSString *userId = [CreateDataModelHelper validStringIdentifierFromValue:resultDict[@"userId"]];
    BOOL received = ![userId isEqualToString:_currentUserId];
    
    resultDict[@"received"] = @(received);
    resultDict[@"seen"] = @(seen);
    if (seen == NO) {
        [[CoreManager badgeService] adjustUnreadMessages:1];
    }
    [[STCoreDataMessageSync new] synchronizeAsyncCoreDataFromData:@[resultDict] withCompletion:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (seen == NO && received && message[@"notification_info"]!=nil) {
                [[CoreManager notificationsService] handleInAppMessageNotification:message];
            }
        });

    }];
}

#pragma mark -Helpers

-(BOOL)canChat {
    if(_status == STWebSockerStatusConnected &&
       _authenticated &&
       _connectionStatus != STConnectionStatusOff)
        return YES;
    
    return NO;
}

+(BOOL)allowChatWithVersion:(NSString *)version{
    if (version == nil ||
        [version isKindOfClass:[NSNull class]]) {
        return NO;
    }
    return [version isGreaterThanEqualWithVersion:kFirstChatVersion];
}

#pragma mark - Rechability Service

- (void)startReachabilityService{
    
    NSLog(@"starting manager for domain:%@", kReachableURL);
    _reachabilityManager = [AFNetworkReachabilityManager managerForDomain:kReachableURL];
    //pentru notificari atunci cand se schimba statusul:
    __weak STChatController *weakSelf = self;
    [_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        __strong STChatController *strongSelf = weakSelf;
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable: {
                NSLog(@"No Internet Connection");
                strongSelf.connectionStatus = STConnectionStatusOff;
                [strongSelf.rechabilityDelegate networkOff];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                NSLog(@"WIFI");
                strongSelf.connectionStatus = STConnectionStatusOn;
                [strongSelf.rechabilityDelegate networkOn];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                NSLog(@"3G");
                strongSelf.connectionStatus = STConnectionStatusOn;
                [strongSelf.rechabilityDelegate networkOn];
                break;
            }
            default:{
                NSLog(@"Unknown network status");
                strongSelf.connectionStatus = STConnectionStatusOff;
                [strongSelf.rechabilityDelegate networkOff];
                break;
            }
        }
    }];
    [_reachabilityManager startMonitoring];
}
@end
