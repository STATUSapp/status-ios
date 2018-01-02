//
//  STSyncService.m
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STSyncService.h"
#import "STSyncBrand.h"

@interface STSyncService ()

@property (nonatomic, strong) STSyncBrand *brandSync;

@end

@implementation STSyncService

-(void)syncBrands{
    if (!_brandSync) {
        _brandSync = [STSyncBrand new];
    }
    [_brandSync sync];
}
@end
