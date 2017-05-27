//
//  STImageCacheObj.m
//  Status
//
//  Created by Andrus Cosmin on 17/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STImageCacheObj.h"
#import "STPost.h"
#import "STUserProfile.h"

@implementation STImageCacheObj

+ (STImageCacheObj *)imageCacheObjFromObj:(STBaseObj *)obj{
    STImageCacheObj *ico = [STImageCacheObj new];
    ico.imageUrl = obj.mainImageUrl;
    return ico;
}

@end
