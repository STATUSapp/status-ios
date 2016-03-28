//
//  STLocalNotificationService.m
//  Status
//
//  Created by Andrus Cosmin on 16/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STLocalNotificationService.h"

@implementation STLocalNotificationService

- (void)postNotificationName:(NSString *)aName object:(id)anObject{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject];
    });

}
- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:aName object:anObject userInfo:aUserInfo];
    });
}

@end
