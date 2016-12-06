//
//  STImageCacheController.h
//  Status
//
//  Created by Andrus Cosmin on 17/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STConstants.h"

@class STImageCacheObj;

typedef void (^loadImageCompletion)(UIImage *img);
typedef void (^loadPostImageCompletion)(UIImage *origImg);
typedef void (^loadBlurPostCompletion) (UIImage *bluredImg);
typedef void (^downloadImageComp)(NSString *downloadedImage);
typedef void (^loadImageComp)(NSString *downloadedImage, BOOL downloaded, CGSize downloadedImageSize);
@interface STImageCacheController : NSObject

@property(nonatomic, strong) NSString *photoDownloadBaseUrl;

-(void) loadImageWithName:(NSString *) imageFullLink andCompletion:(loadImageCompletion) completion;
-(void) loadPostImageWithName:(NSString *) imageFullLink withPostCompletion:(loadPostImageCompletion) completion;
-(void) cleanTemporaryFolder;
-(void)startImageDownloadForNewFlowType:(STFlowType)flowType andDataSource:(NSArray <STImageCacheObj *>*)newObjects;
-(void)changeFlowType:(STFlowType) flowType needsSort:(BOOL)needsSort;

+ (BOOL) imageDownloadedForUrl:(NSString *)url;
+ (CGSize) imageSizeForUrl:(NSString *)url;
@end
