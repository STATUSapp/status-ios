//
//  STInviteController.h
//  Status
//
//  Created by Cosmin Andrus on 6/30/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STInviteController : NSObject
+(STInviteController *) sharedInstance;
-(BOOL)shouldInviteBeAvailable;
-(BOOL)validInviteNumber:(NSNumber *)number;
-(void)setCurrentDateForInviteNumber:(NSNumber *)number;

@end
