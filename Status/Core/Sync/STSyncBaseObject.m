//
//  STSyncBaseObject.m
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STSyncBaseObject.h"

@interface STSyncBaseObject ()

@end

@implementation STSyncBaseObject

-(void)sync{
    if ([self canSyncNow]) {
        [self downloadPages];
    }
}

-(NSUserDefaults *)lastCheckUserDefaults{
    NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"SYNC_LAST_CHECK"];
    return ud;
}
#pragma mark - Hook Methods
-(BOOL)canSyncNow{
    NSAssert(NO, @"This method \"canSyncNow\" should be implemented by the subclasses");
    return NO;
}

-(void)downloadPages{
    NSAssert(NO, @"This method \"downloadPages\" should be implemented by the subclasses");
    return;

}
-(void)resetLastCheck{
    NSAssert(NO, @"This method \"resetLastCheck\" should be implemented by the subclasses");
    return;
}
@end
