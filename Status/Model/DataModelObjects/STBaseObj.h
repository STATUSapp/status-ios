//
//  STBaseObj.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreateDataModelHelper.h"
#import "NSString+Links.h"

//extern NSString * const kObjectUuidForLoading;
//extern NSString * const kObjectUuidForNothingToDisplay;

typedef NS_ENUM(NSUInteger, STProfileGender) {
    STProfileGenderMale = 0,
    STProfileGenderFemale,
    STProfileGenderOther
};

@interface STBaseObj : NSObject

@property(nonatomic, strong) NSDictionary *infoDict;
@property(nonatomic, strong) NSString *uuid;
@property(nonatomic, strong) NSString *appVersion;

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, strong) NSNumber *imageRatio;
@property (nonatomic, strong) NSString * mainImageUrl;

- (NSString *)genderImageNameForGender:(STProfileGender)gender;
- (STProfileGender)genderFromString:(NSString *)genderString;
- (void)saveDimentionsWithImageHeight:(CGFloat)imageHeight
                           imageRatio:(CGFloat)imageRatio
                           imageWidth:(CGFloat)imageWidth;
@end
