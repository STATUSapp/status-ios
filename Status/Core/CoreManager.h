//
//  CoreManager.h
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STPostsPool;
@class STLocationManager;

@interface CoreManager : NSObject

+ (BOOL)shouldLogin;
+ (STPostsPool *)postsPool;
+ (STLocationManager *)locationManager;

@end
