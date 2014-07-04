//
//  STImageCacheController.h
//  Status
//
//  Created by Andrus Cosmin on 17/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^loadImageCompletion)(UIImage *img);
typedef void (^downloadImageComp)(NSString *downloadedImage);
@interface STImageCacheController : NSObject

+(STImageCacheController *) sharedInstance;

-(void) loadImageWithName:(NSString *) imageFullLink andCompletion:(loadImageCompletion) completion;
-(NSString *) getImageCachePath;
-(void) cleanTemporaryFolder;
-(void)startImageDownloadForNewDataSource:(NSArray *)newPosts;

@end
