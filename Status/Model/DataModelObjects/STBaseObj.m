//
//  STBaseObj.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@implementation STBaseObj

-(NSString *)debugDescription{
    return [NSString stringWithFormat:@"%@", self.infoDict];
}

- (NSString *)genderImageNameForGender:(STProfileGender)gender{
    NSString *imageName = @"boy";
    switch (gender) {
        case STProfileGenderOther:
        case STProfileGenderMale:
            imageName = @"boy";
            break;
        case STProfileGenderFemale:
            imageName = @"girl";
            break;
        default:
            break;
    }
    
    return imageName;
}

- (STProfileGender)genderFromString:(NSString *)genderString{
    STProfileGender gender = STProfileGenderOther;
    
    NSString *genderStringLowercase = [genderString lowercaseString];
    
    if ([genderStringLowercase isEqualToString:@"female"]) {
        gender = STProfileGenderFemale;
    }
    else if ([genderStringLowercase isEqualToString:@"male"]){
        gender = STProfileGenderMale;
    }
    
    return gender;
}

- (void)saveDimentionsWithImageHeight:(CGFloat)imageHeight
                           imageRatio:(CGFloat)imageRatio
                           imageWidth:(CGFloat)imageWidth {
    if (imageWidth > 0 &&
        imageHeight > 0) {
        self.imageSize = CGSizeMake(imageWidth, imageHeight);
    }else{
        self.imageSize = CGSizeZero;
    }
    if (imageRatio == 0) {
        if (imageWidth > 0 &&
            imageHeight > 0) {
            self.imageRatio = @(imageWidth/imageHeight);
        }else{
            self.imageRatio = @(0);
        }
    }else{
        self.imageRatio = @(imageRatio);
    }
}

@end
