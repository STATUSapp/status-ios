//
//  STLocationManager.h
//  Status
//
//  Created by Andrus Cosmin on 18/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface STLocationManager : NSObject

+ (STLocationManager*)sharedInstance;
@property (nonatomic, strong) CLLocation *latestLocation;
-(void)restartLocationManager;
-(void)startLocationUpdates;
+(BOOL)locationUpdateEnabled;
@end
