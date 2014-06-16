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

@end

@interface STChatController : NSObject

@property (nonatomic, assign) STWebSockerStatus status;
@property (nonatomic, weak) id <STChatControllerDelegate> delegate;
- (void)reconnect;
- (void)close;
- (void)sendMessage:(NSString *)message;
+(STChatController *)sharedInstance;
@end
