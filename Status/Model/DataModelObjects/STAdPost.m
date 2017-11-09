//
//  STAdPost.m
//  Status
//
//  Created by Cosmin Andrus on 09/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STAdPost.h"
#import "STFacebookAdModel.h"

@interface STAdPost ()

@property (nonatomic, strong, readwrite) STFacebookAdModel *adModel;

@end

@implementation STAdPost

-(instancetype)init{
    self = [super init];
    if (self) {
        self.uuid = [[NSUUID UUID] UUIDString];
        self.adModel = [STFacebookAdModel new];
    }
    return self;
}

-(BOOL)isAdPost{
    return YES;
}
@end
