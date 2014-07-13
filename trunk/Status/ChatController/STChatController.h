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

-(void)chatDidReceivedMesasage:(NSString *)message;
-(void)chatDidClose;
-(void)chatDidOpenRoom:(NSString *)roomId;
-(void)chatDidAuthenticate;
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
@property (nonatomic, assign) BOOL authenticated;
- (void)reconnect;
- (void)close;
- (void)sendMessage:(NSString *)message inRoom:(NSString *)roomId;
-(NSArray *)conversationWithRoomId:(NSString *)roomId;
-(void)openChatRoomForUserId:(NSString *)userId;

+(STChatController *)sharedInstance;
- (void)startReachabilityService;

#pragma mark -Helpers
-(BOOL)canChat;

@end
