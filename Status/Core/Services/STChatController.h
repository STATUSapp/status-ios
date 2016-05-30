//
//  STChatController.h
//  Status
//
//  Created by Andrus Cosmin on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STConstants.h"

@protocol STChatControllerDelegate <NSObject>

-(void)chatDidClose;
-(void)chatDidOpenRoom:(NSString *)roomId;
-(void)chatDidAuthenticate;

-(void)userWasBlocked;
-(void)userBlockSuccess;
@end

@protocol STRechabilityDelegate <NSObject>

-(void)networkOn;
-(void)networkOff;

@end

@interface STChatController : NSObject

@property (nonatomic, strong) NSString *chatSocketUrl;
@property (nonatomic) NSInteger chatPort;

@property (nonatomic, assign) STWebSockerStatus status;
@property (nonatomic, assign) STConnectionStatus connectionStatus;
@property (nonatomic, weak) id <STChatControllerDelegate> delegate;
@property (nonatomic, weak) id <STRechabilityDelegate> rechabilityDelegate;
@property (nonatomic, strong) NSString *currentRoomId;
@property (nonatomic, strong) NSString *currentUserId;
@property (nonatomic, assign) BOOL authenticated;
@property (nonatomic, assign) BOOL loadMore;

- (void)reconnect;
-(void)forceReconnect;
- (void)close;
-(void)authenticate;
- (void)sendMessage:(NSString *)message inRoom:(NSString *)roomId;
-(void)openChatRoomForUserId:(NSString *)userId;
-(void)leaveCurrentRoom;
-(void)getRoomMessages:(NSString *)roomId withOffset:(NSInteger)offset;
-(void)syncRoomMessages:(NSString *)roomId withMessagesIds:(NSArray *)messagesUuids;
+(STChatController *)sharedInstance;
- (void)startReachabilityService;
-(void)leaveRoom:(NSString *)roomId;
- (void)blockUserWithId:(NSString *)userId;
#pragma mark -Helpers
-(BOOL)canChat;
+(BOOL)allowChatWithVersion:(NSString *)version;

@end
