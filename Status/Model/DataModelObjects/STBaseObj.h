//
//  STBaseObj.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreateDataModelHelper.h"

//extern NSString * const kObjectUuidForLoading;
//extern NSString * const kObjectUuidForNothingToDisplay;

typedef NS_ENUM(NSUInteger, STProfileGender) {
    STProfileGenderUndefined = 0,
    STProfileGenderMale,
    STProfileGenderFemale,
};

@interface STBaseObj : NSObject

@property(nonatomic, strong) NSDictionary *infoDict;
@property(nonatomic, strong) NSString *uuid;
@property(nonatomic, strong) NSString *appVersion;

@property (nonatomic, assign) BOOL mainImageDownloaded;
@property (nonatomic, assign) BOOL thumbnailImageDownloaded;
@property (nonatomic, assign) CGSize imageSize;//the full image size
@property (nonatomic, strong) NSString * mainImageUrl;
@property (nonatomic, strong) NSString * thumbnailPhotoUrl;

- (NSString *)genderImageNameForGender:(STProfileGender)gender;

@end
