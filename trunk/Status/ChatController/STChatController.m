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
#import "STWebServiceController.h"

NSString * const kChatSocketURL = @"http://glazeon.com";
NSString * const kReachableURL = @"www.glazeon.com";
int const kChatPort = 9001;

@interface STChatController()<SRWebSocketDelegate>{
    SRWebSocket *_webSocket;
    NSTimer *reconnectTimer;
    AFNetworkReachabilityManager* _reachabilityManager;
}

@end

@implementation STChatController

+(STChatController*)sharedInstance{
    static STChatController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
                  
}

-(void)setUnreadMessages:(NSInteger)unreadMessages{
    _unreadMessages = unreadMessages;
    [[NSNotificationCenter defaultCenter] postNotificationName:STUnreadMessagesValueDidChanged object:nil];
    
}
- (void)reconnect
{
    [self close];
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@:%d",kChatSocketURL, kChatPort]]]];
    _webSocket.delegate = self;
    _status = STWebSockerStatusConnecting;
    //TODO: remove this mock up
    [self setUnreadMessages:5];

    [_webSocket open];
    
}

- (void)close{
    [_webSocket close];
    _webSocket = nil;
    _webSocket.delegate = nil;
    
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket;
{
    NSLog(@"Websocket Connected");
    _status = STWebSockerStatusConnected;
     _authenticated = NO;
    [self authenticate];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
    NSLog(@":( Websocket Failed With Error %@", error);
    
    _status = STWebSockerStatusClosed;
    [_delegate chatDidClose];
    _authenticated = NO;
    _webSocket = nil;
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self performSelector:@selector(reconnect) withObject:nil afterDelay:10.f];
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
            //TODO - chat remove this mockup
            //[self performSelector:@selector(close) withObject:nil afterDelay:3.f];
            
            //TODO: save all room received
            if (_delegate && [_delegate respondsToSelector:@selector(chatDidAuthenticate)]) {
                [_delegate performSelector:@selector(chatDidAuthenticate)];
            }
            
            //TODO: - save unreadMessages
        }
    }
    else if ([response[@"type"] isEqualToString:@"getRoomId"]){
        NSLog(@"Room Id: %@", response[@"roomID"]);
        if (_delegate && [_delegate respondsToSelector:@selector(chatDidOpenRoom:)]) {
            [_delegate performSelector:@selector(chatDidOpenRoom:) withObject:response[@"roomID"]];
        }
        
    }
    else if ([response[@"type"] isEqualToString:@"message"]){
        //TODO: save into local plist and notify user;
        //TODO: recalculate unreadMessages;
        [self addMessage:response[@"message"] received:YES forRoomId:response[@"roomID"]];
        [_delegate chatDidReceivedMesasage:response[@"message"]];
    }
    
    //NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    //NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
    NSLog(@"WebSocket closed");
    _status = STWebSockerStatusClosed;
    _webSocket = nil;
    [_delegate chatDidClose];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        [self performSelector:@selector(reconnect) withObject:nil afterDelay:10.f];
    }
}

#pragma mark - Communication

-(void)authenticate{

    if ([STWebServiceController sharedInstance].accessToken!=nil &&
        [STWebServiceController sharedInstance].accessToken.length!=0) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"type": @"login", @"token": [STWebServiceController sharedInstance].accessToken} options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [_webSocket send:jsonString];
    }
    else
    {
        NSLog(@"Authenticate on login/register");
    }
   
}

-(void)openChatRoomForUserId:(NSString *)userId{
    //TODO: recalculate unreadMessages
    //TODO: initiate currentRoomId
    if(userId==nil)
        return;
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"type": @"getRoomId", @"userId": userId} options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_webSocket send:jsonString];
}

-(void)leaveRoom{
    //TODO: currentRoomId = nil;
}

- (void)sendMessage:(NSString *)message inRoom:(NSString *)roomId{
    NSString *newMessage = [message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSData *data = [NSJSONSerialization dataWithJSONObject:@{@"message":newMessage, @"type":@"message", @"roomId":roomId} options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [_webSocket send:jsonString];
}

#pragma mark - Local Storage
-(NSString *) getStoragePath{
    
    NSString *documentsDirectory = NSTemporaryDirectory();
    NSString *storagePath = [documentsDirectory stringByAppendingPathComponent:@"/Conversations"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:storagePath]){
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:storagePath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    return storagePath;
}

-(NSArray *)conversationWithRoomId:(NSString *)roomId{
    NSString *storagePath = [self getStoragePath];
    NSString *conversationFullPath = [storagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", roomId]];
    NSArray *conversation = [NSArray arrayWithContentsOfFile:conversationFullPath];
    
    return conversation;
}

-(void)addMessage:(NSString *)message received:(BOOL)received forRoomId:(NSString *)roomId{
    NSDictionary *messageDict = @{@"message":message, @"received":@(received)};
    NSMutableArray *history =[NSMutableArray arrayWithArray:[self conversationWithRoomId:roomId]];
    [history addObject:messageDict];
    NSString *storagePath = [self getStoragePath];
    NSString *conversationFullPath = [storagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", roomId]];
    [history writeToFile:conversationFullPath atomically:YES];
    
}

#pragma mark -Helpers

-(BOOL)canChat {
    if(_status == STWebSockerStatusConnected &&
       _authenticated &&
       _connectionStatus != STConnectionStatusOff)
        return YES;
    
    return NO;
}

#pragma mark - Rechability Service

- (void)startReachabilityService{
    
//    struct sockaddr_in mysock;
//    bzero ((char *) & mysock, sizeof (mysock)) ;
//    bzero ((char *) & mysock, sizeof (mysock));
//    mysock.sin_family = AF_INET;
//    mysock.sin_port = htons (kChatPort) ;
//    mysock.sin_addr.s_addr = inet_addr ([kReachableURL UTF8String]);
    
    NSLog(@"starting manager for domain:%@", kReachableURL);
    _reachabilityManager = [AFNetworkReachabilityManager managerForDomain:kReachableURL];
    //pentru notificari atunci cand se schimba statusul:
    __weak STChatController *weakSelf = self;
    [_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable: {
                NSLog(@"No Internet Connection");
                weakSelf.connectionStatus = STConnectionStatusOff;
                [weakSelf.rechabilityDelegate networkOff];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                NSLog(@"WIFI");
                weakSelf.connectionStatus = STConnectionStatusOn;
                [weakSelf.rechabilityDelegate networkOn];
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                NSLog(@"3G");
                weakSelf.connectionStatus = STConnectionStatusOn;
                [weakSelf.rechabilityDelegate networkOn];
                break;
            }
            default:{
                NSLog(@"Unknown network status");
                weakSelf.connectionStatus = STConnectionStatusOff;
                [weakSelf.rechabilityDelegate networkOff];
                break;
            }
        }
    }];
    [_reachabilityManager startMonitoring];
    
}

@end
