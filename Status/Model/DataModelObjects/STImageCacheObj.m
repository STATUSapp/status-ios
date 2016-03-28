//
//  STImageCacheObj.m
//  Status
//
//  Created by Andrus Cosmin on 17/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STImageCacheObj.h"
#import "STPost.h"

@implementation STImageCacheObj

+ (STImageCacheObj *)imageCacheObjFromPost:(STPost *)post{
    STImageCacheObj *ico = [STImageCacheObj new];
    ico.imageUrl = post.fullPhotoUrl;
    return ico;
}


@end
