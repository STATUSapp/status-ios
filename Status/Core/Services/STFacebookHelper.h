//
//  STFacebookAlbumsLoader.h
//  Status
//
//  Created by Andrus Cosmin on 31/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STFacebookLoginController.h"

typedef void (^loaderCompletion) (NSString *nextLink);
typedef void (^refreshCompletion) (NSArray *newObjects);
typedef void (^loadFBPicturesCompletion) (NSDictionary *result);

@interface STFacebookHelper : NSObject
-(void)loadAlbumsWithRefreshBlock:(refreshCompletion)refreshCompletion;
-(void)loadPhotosForAlbum:(NSString *)albumId withRefreshBlock:(refreshCompletion)refreshCompletion;
-(void)getUserExtendedInfoWithCompletion:(void (^)(NSDictionary *info))completion;
-(void) shareImageWithImageUrl:(NSString *)imgUrl description:(NSString *)description andCompletion:(facebookCompletion) completion;
-(void)promoteTheApp;
-(void)loadUserFriendsWithCompletion:(refreshCompletion)completion;
@end
