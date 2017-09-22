//
//  STLocationManager.h
//  Status
//
//  Created by Andrus Cosmin on 18/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^STNewLocationBlock)(void);

extern NSString * const kNotificationNewLocationHasBeenUploaded;

@interface STLocationManager : NSObject

@property (nonatomic, strong) CLLocation *latestLocation;
- (void)restartLocationManager;
- (void)startLocationUpdates;
- (void)stopLocationUpdates;
- (void)forceLocationToUpdate;
- (void)startLocationUpdatesWithCompletion:(STNewLocationBlock) completion;
- (NSString *)distanceStringToLocationWithLatitudeString:(NSString *)latitude andLongitudeString:(NSString *)longitudeString;

+(BOOL)locationUpdateEnabled;
@end
