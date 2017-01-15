//
//  UserProfileNoPhotosCell.m
//  Status
//
//  Created by Cosmin Andrus on 01/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "UserProfileNoPhotosCell.h"

@implementation UserProfileNoPhotosCell

+ (CGSize)cellSizeForNumberOfPhotos:(NSInteger)itemsCount {
    if (itemsCount > 0) {
        return CGSizeZero;
    }
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return CGSizeMake(screenSize.width, 304.f);
}
@end
