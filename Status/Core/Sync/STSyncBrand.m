//
//  STSyncBrand.m
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STSyncBrand.h"
#import "STGetBrandsRequest.h"
#import "STCoreDataBrandSync.h"
#import "STCoreDataManager.h"

@interface STSyncBrand()

@property (nonatomic, strong) STCoreDataBrandSync *coreDataBrandSync;

@end

@implementation STSyncBrand

-(BOOL)canSyncNow{
    if (![CoreManager loggedIn]) {
        return NO;
    }
    NSUserDefaults *ud = [self lastCheckUserDefaults];
    NSDate *lastCheck = [ud valueForKey:@"BRANDS_LAST_CHECK"];
    if (!lastCheck) {
        lastCheck = [NSDate dateWithTimeIntervalSince1970:0];
    }
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    // pass as many or as little units as you like here, separated by pipes
    NSUInteger units = NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitMonth;
    
    NSDateComponents *components = [gregorianCalendar components:units fromDate:lastCheck toDate:[NSDate date] options:0];
    
    NSInteger years = [components year];
    NSInteger months = [components month];
    NSInteger day = [components day];
    
    if (years > 0 ||
        months > 0 ||
        day > 0) {
        return YES;
    }
    return NO;
}

-(void)downloadPages{
    if (!_coreDataBrandSync) {
        _coreDataBrandSync = [STCoreDataBrandSync new];
    }
    __weak STSyncBrand *weakSelf = self;
    [STGetBrandsRequest getBrandsEntitiesForPage:self.pageIndex
                                  withCompletion:^(id response, NSError *error) {
                                      if (!error) {
                                          __strong STSyncBrand *strongSelf = weakSelf;
                                          [strongSelf.coreDataBrandSync synchronizeAsyncCoreDataFromData:response withCompletion:^(NSError *error) {
                                              [[CoreManager coreDataService] save];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if ([response count] < kCatalogDownloadPageSize) {
                                                      [strongSelf setLastCheck];
                                                  }else{
                                                      strongSelf.pageIndex ++;
                                                      [strongSelf downloadPages];
                                                  }
                                                  NSLog(@"Brands Synced with error: %@", error);
                                              });
                                          }];
                                      }
                                  } failure:^(NSError *error) {
                                      NSLog(@"Sync brand failure: %@", error);
                                  }];
}

#pragma maerk - Helpers

-(void)setLastCheck{
    NSUserDefaults *ud = [self lastCheckUserDefaults];
    [ud setValue:[NSDate date] forKey:@"BRANDS_LAST_CHECK"];
    [ud synchronize];
}
-(void)resetLastCheck{
    NSUserDefaults *ud = [self lastCheckUserDefaults];
    [ud setValue:nil forKey:@"BRANDS_LAST_CHECK"];
    [ud synchronize];

}
@end
