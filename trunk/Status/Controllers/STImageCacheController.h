//
//  STImageCacheController.h
//  Status
//
//  Created by Andrus Cosmin on 17/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STConstants.h"

typedef void (^loadImageCompletion)(UIImage *img);
typedef void (^loadPostImageCompletion)(UIImage *origImg);
typedef void (^loadBlurPostCompletion) (UIImage *bluredImg);
typedef void (^downloadImageComp)(NSString *downloadedImage);
typedef void (^loadImageComp)(NSString *downloadedImage, BOOL downloaded);
@interface STImageCacheController : NSObject

+(STImageCacheController *) sharedInstance;

#if !USE_SD_WEB
-(void) loadImageWithName:(NSString *) imageFullLink andCompletion:(loadImageCompletion) completion isForFacebook:(BOOL)forFacebook;
#else
-(void) loadImageWithName:(NSString *) imageFullLink andCompletion:(loadImageCompletion) completion;
#endif
-(void) loadPostImageWithName:(NSString *) imageFullLink withPostCompletion:(loadPostImageCompletion) completion andBlurCompletion:(loadBlurPostCompletion)blurCompl;
-(NSString *) getImageCachePath:(BOOL)forFacebook;
-(void) cleanTemporaryFolder;
-(void)startImageDownloadForNewFlowType:(STFlowType)flowType andDataSource:(NSArray *)newPosts;
-(void)changeFlowType:(STFlowType) flowType needsSort:(BOOL)needsSort;
- (void)saveImageForBlur:(UIImage *)image imageURL:(NSURL *)imageURL;
@end
