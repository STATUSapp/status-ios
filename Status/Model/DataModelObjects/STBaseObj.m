//
//  STBaseObj.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

NSString * const kObjectUuidForLoading = @"uuid_3";
NSString * const kObjectUuidForNothingToDisplay = @"uuid_1";
NSString * const kObjectUuidForTheEnd = @"uuid_2";


@implementation STBaseObj

-(NSString *)debugDescription{
    return [NSString stringWithFormat:@"%@", self.infoDict];
}

+ (instancetype)mockObjectLoading{
    STBaseObj * obj = [STBaseObj new];
    obj.uuid = kObjectUuidForLoading;
    return obj;
}

+ (instancetype)mockObjNothingToDisplay{
    STBaseObj * obj = [STBaseObj new];
    obj.uuid = kObjectUuidForNothingToDisplay;
    obj.mainImageDownloaded = YES;
    return obj;
    
}
+ (instancetype)mockObjTheEnd{
    STBaseObj * obj = [STBaseObj new];
    obj.uuid = kObjectUuidForTheEnd;
    obj.mainImageDownloaded = YES;
    return obj;
}

- (BOOL) isLoadingObject{
    return [self.uuid isEqualToString:kObjectUuidForLoading];
}

- (BOOL) isNothingToDisplayObj{
    return [self.uuid isEqualToString:kObjectUuidForNothingToDisplay];
}

- (BOOL) isTheEndObject{
    return [self.uuid isEqualToString:kObjectUuidForTheEnd];
}


@end
