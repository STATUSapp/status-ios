//
//  STLocationManager.m
//  Status
//
//  Created by Andrus Cosmin on 18/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STLocationManager.h"
#import "STConstants.h"

#import "STSetUserLocationRequest.h"

static const double kGPSRecordTime = 1800;//seconds, half an hour
static const double kGPSAccuracyMetters = 150;
static const double kGPSTimestampSeconds = 15.0;
@interface STLocationManager()<CLLocationManagerDelegate>
{
    CLLocationManager *_locationManager;
}
@property (copy) STNewLocationBlock newLocationBlock;
@end

@implementation STLocationManager
static STLocationManager *_locationManager;
+ (STLocationManager*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _locationManager = [[STLocationManager alloc] init];
    });
    
    return _locationManager;
}
- (id)init
{
    self = [super init];
    if (self){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        _locationManager.delegate = self;
        // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
    }
    
    return self;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    
    if(currentLocation.horizontalAccuracy > kGPSAccuracyMetters)
    {
        NSLog(@"Ignoring GPS location more than %0.2f meters inaccurate :%0.2f",kGPSAccuracyMetters,currentLocation.horizontalAccuracy);
        return;
    }
    
    NSDate* locationDate = currentLocation.timestamp;
    NSTimeInterval howRecent = [locationDate timeIntervalSinceNow];
    if (fabs(howRecent) > kGPSTimestampSeconds)
    {
        NSLog(@"Ignoring GPS location more than %0.2f seconds old(cached) :%0.2f",kGPSTimestampSeconds, fabs(howRecent));
        return;
    }
    
    if (self.newLocationBlock ==nil && _latestLocation!=nil) {
        howRecent = [locationDate timeIntervalSinceDate:_latestLocation.timestamp];
        
        if (fabs(howRecent) < kGPSRecordTime) {
            NSLog(@"Ignoring GPS location more than %0.2f seconds recent from latest location update", kGPSRecordTime);
            return;
        }
    }
    _latestLocation = currentLocation;
    [self sendLocationToServer];
    [self restartLocationManager];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Location Manager Fails with error: %@", error.debugDescription);
}

-(void)sendLocationToServer{
    STLocationManager *weakSelf = self;
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
            NSLog(@"Set User Location: %@", _latestLocation);
            if (weakSelf.newLocationBlock != nil) {
                weakSelf.newLocationBlock();
                weakSelf.newLocationBlock = nil;
            }
        }
    };
    [STSetUserLocationRequest setCurrentUserLocationWithCompletion:completion failure:nil];
}
-(void)restartLocationManager{
    if (UIApplication.sharedApplication.applicationState == UIApplicationStateActive)
    {
        [self stopLocationUpdates];
        [self performSelector:@selector(startLocationUpdates) withObject:nil afterDelay:kGPSRecordTime];
    }
}

- (void)startLocationUpdates{
    if ([STNetworkQueueManager sharedManager].accessToken!=nil &&
        [STNetworkQueueManager sharedManager].accessToken.length > 0) {
        [_locationManager startUpdatingLocation];
    }
}

- (void)startLocationUpdatesWithCompletion:(STNewLocationBlock) completion{
    self.newLocationBlock = completion;
    [self startLocationUpdates];
}

- (void)stopLocationUpdates{
    [_locationManager stopUpdatingLocation];
}

- (NSString *)distanceStringToLocationWithLatitudeString:(NSString *)latitude andLongitudeString:(NSString *)longitudeString {
    CLLocation * newLocation = [[CLLocation alloc] initWithLatitude:[latitude doubleValue] longitude:[longitudeString doubleValue]];
    CLLocationDistance distance = [newLocation distanceFromLocation:self.latestLocation];
    
    if (distance < 0) {
        return @"Unknown distance";
    }
    
    if (distance < 1000) { // 1000 meters = 1 km
        return @"Less than 1 km away";
    }
    return [NSString stringWithFormat:@"%i km away", (int)(distance/1000)];
}

+(BOOL)locationUpdateEnabled{
    return [CLLocationManager locationServicesEnabled] &&
    ([CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorized ||
     [CLLocationManager authorizationStatus]==kCLAuthorizationStatusAuthorizedWhenInUse);
}

@end
