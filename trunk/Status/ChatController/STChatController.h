//
//  STChatController.h
//  Status
//
//  Created by Andrus Cosmin on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STConstants.h"

#define USE_CORE_DATA 1

@protocol STChatControllerDelegate <NSObject>

-(void)chatDidReceivedMesasage:(NSDictionary *)message;
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

@property (nonatomic, assign) STWebSockerStatus status;
@property (nonatomic, assign) STConnectionStatus connectionStatus;
@property (nonatomic, weak) id <STChatControllerDelegate> delegate;
@property (nonatomic, weak) id <STRechabilityDelegate> rechabilityDelegate;
@property (nonatomic, assign) NSInteger unreadMessages;
@property (nonatomic, strong) NSString *currentRoomId;
@property (nonatomic, strong) NSString *currentUserId;
@property (nonatomic, assign) BOOL authenticated;
@property (nonatomic, assign) BOOL loadMore;
- (void)reconnect;
-(void)forceReconnect;
- (void)close;
-(void)authenticate;
- (void)sendMessage:(NSString *)message inRoom:(NSString *)roomId;
#if USE_CORE_DATA

#else
-(NSArray *)conversationWithRoomId:(NSString *)roomId markAsSeen:(BOOL)mark;
-(BOOL)deleteConversationWithId:(NSString *)roomId;
-(void)cleanLocalHistory;
#endif
-(void)openChatRoomForUserId:(NSString *)userId;
-(void)leaveCurrentRoom;
-(void)getRoomMessages:(NSString *)roomId withOffset:(NSInteger)offset;

+(STChatController *)sharedInstance;
- (void)startReachabilityService;
-(void)leaveRoom:(NSString *)roomId;
- (void)blockUserWithId:(NSString *)userId;
#pragma mark -Helpers
-(BOOL)canChat;

@end
