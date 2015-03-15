//
//  STFacebookAlbumsLoader.h
//  Status
//
//  Created by Andrus Cosmin on 31/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^loaderCompletion) (NSString *nextLink);
typedef void (^refreshCompletion) (NSArray *newObjects);
typedef void (^loadFBPicturesCompletion) (NSDictionary *result);

@interface STFacebookAlbumsLoader : NSObject
-(void)loadAlbumsWithRefreshBlock:(refreshCompletion)refreshCompletion;
-(void)loadPhotosForAlbum:(NSString *)albumId withRefreshBlock:(refreshCompletion)refreshCompletion;
+(void)loadPermissionsWithBlock:(refreshCompletion)refreshCompletion;
@end
