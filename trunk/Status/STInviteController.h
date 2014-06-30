//
//  STInviteController.h
//  Status
//
//  Created by Cosmin Andrus on 6/30/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STInviteProtocol <NSObject>

-(void)setNewDates;

@end

@interface STInviteController : NSObject

@property (nonatomic, strong)NSNumber *selectedButtonTag;
@property (nonatomic, weak) id <STInviteProtocol> delegate;
+(STInviteController *) sharedInstance;
-(BOOL)shouldInviteBeAvailable;
-(BOOL)validInviteNumber:(NSNumber *)number;
-(void)setCurrentDateForSelectedItem;
-(void)callTheDelegate;
@end
