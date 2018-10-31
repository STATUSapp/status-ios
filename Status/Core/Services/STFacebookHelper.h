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

typedef void (^loaderCompletion) (NSString * _Nonnull nextLink);
typedef void (^refreshCompletion) (NSArray * _Nonnull newObjects);
typedef void (^loadFBPicturesCompletion) (NSDictionary * _Nullable result);
typedef void (^shareCompletion) (BOOL result);

@interface STFacebookHelper : NSObject
-(void)loadAlbumsWithRefreshBlock:(refreshCompletion _Nonnull )refreshCompletion;
-(void)loadPhotosForAlbum:(NSString *_Nonnull)albumId withRefreshBlock:(refreshCompletion _Nonnull )refreshCompletion;
-(void)getUserExtendedInfoWithCompletion:(void (^_Nonnull)(NSDictionary * _Nonnull info))completion;
-(void)shareImageFromLink:(NSString *_Nonnull)imageLink;
-(void)shareTopImage:(UIImage * _Nullable)topImage
      withCompletion:(shareCompletion _Nonnull )completion;

//app promote
//-(void)promoteTheApp;
-(void)loadUserFriendsWithCompletion:(refreshCompletion _Nonnull )completion;

//fb native ads service
+ (STNativeAdsController *_Nonnull)fbNativeAdsService;

@end
