//
//  STPost.h
//  Status
//
//  Created by Cosmin Home on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@interface STPost : STBaseObj
+ (instancetype)postWithDict:(NSDictionary *)postDict;
+ (instancetype)mockPostNoPhotosToDisplay;
+ (instancetype)mockPostYouSawAll;
+ (instancetype)mockPostLoading;

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSString *fullPhotoUrl;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, strong) NSNumber *numberOfLikes;
@property (nonatomic, strong) NSDate *postDate;
@property (nonatomic, assign) BOOL postLikedByCurrentUser;
@property (nonatomic, assign) BOOL reportStatus;
@property (nonatomic, strong) NSString *smallPhotoUrl;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) BOOL postSeen;

//local added properties
@property (nonatomic, assign) BOOL imageDownloaded;
@property (nonatomic, assign) BOOL showFullCaption;

- (BOOL) isNoPhotosToDisplayPost;
- (BOOL) isYouSawAllPost;
- (BOOL) isLoadingPost;

@end
