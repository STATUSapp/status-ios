//
//  STLocalNotificationService.h
//  Status
//
//  Created by Andrus Cosmin on 16/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

//this works on on the main thread

@interface STLocalNotificationService : NSObject

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo;

@end
