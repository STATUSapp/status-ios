//
//  STFacebookAlbumsLoader.h
//  Status
//
//  Created by Andrus Cosmin on 31/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLoginService.h"
#import "STNativeAdsController.h"

typedef void (^loaderCompletion) (NSString *nextLink);
typedef void (^refreshCompletion) (NSArray *newObjects);
typedef void (^loadFBPicturesCompletion) (NSDictionary *result);
typedef void (^shareCompletion) (BOOL result);

@interface STFacebookHelper : NSObject
-(void)loadAlbumsWithRefreshBlock:(refreshCompletion)refreshCompletion;
-(void)loadPhotosForAlbum:(NSString *)albumId withRefreshBlock:(refreshCompletion)refreshCompletion;
-(void)getUserExtendedInfoWithCompletion:(void (^)(NSDictionary *info))completion;
-(void)shareImageFromLink:(NSString *)imageLink;
-(void)shareTopImage:(UIImage * _Nullable)topImage
      withCompletion:(shareCompletion)completion;

//app promote
//-(void)promoteTheApp;
-(void)loadUserFriendsWithCompletion:(refreshCompletion)completion;

//fb native ads service
+ (STNativeAdsController *)fbNativeAdsService;

@end
