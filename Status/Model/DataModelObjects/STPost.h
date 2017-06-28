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

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, strong) NSNumber *numberOfLikes;
@property (nonatomic, strong) NSDate *postDate;
@property (nonatomic, assign) BOOL postLikedByCurrentUser;
@property (nonatomic, assign) NSNumber *reportStatus;
@property (nonatomic, strong) NSString *smallPhotoUrl;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) BOOL postSeen;
@property (nonatomic, strong) NSArray *shopProducts;
@property (nonatomic, strong) NSString *shareShortUrl;

//local added properties
@property (nonatomic, assign) BOOL showFullCaption;
@property (nonatomic, assign) BOOL showShopProducts;
@end
