//
//  STImageResizeService.m
//  Status
//
//  Created by Cosmin Andrus on 21/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STImageResizeService.h"
#import "UIImage+Resize.h"

@implementation STImageResizeService

#pragma mark - Public
- (UIImage *)resizeImage:(UIImage *)image
              forUseType:(STImageUseType)useType{
    CGSize originalSize = image.size;
    CGFloat targetWidth = [self widthForUseType:useType];
    
    if (targetWidth>=originalSize.width) {
        return image;
    }
    CGFloat compressRatio = targetWidth/originalSize.width;
    CGSize targetSize = CGSizeMake(targetWidth, compressRatio * originalSize.height);
    UIImage *croppedImg = [image resizedImage:targetSize
                         interpolationQuality:kCGInterpolationHigh];
    return croppedImg;
}


#pragma mark - Private

- (CGFloat)widthForUseType:(STImageUseType)useType{
    CGFloat result = 0.f;
    switch (useType) {
        case STImageUseTypeUploadPost:
            result = 1500.f;
            break;
        case STImageUseTypeUploadProfile:
            result = 720.f;
            break;
        case STImageUseTypeUploadProduct:
            result = 700;
            break;
        default:
            result = 0.f;
            break;
    }
    return result;
}

@end
