//
//  STPost.m
//  Status
//
//  Created by Cosmin Home on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

/*
 
 {
 "app_version" = "1.0.17";
 caption = "vine, vine, primavara#STATUS ";
 "full_photo_link" = "http://d22t200r9sgmit.cloudfront.net/img/x84nn5dnesnyphxyvij-56bf6b0f8b5da.jpg";
 "is_owner" = 0;
 "number_of_likes" = 6;
 "post_date" = "2016-02-13 19:42:45";
 "post_id" = 11734;
 "post_liked_by_current_user" = 0;
 "report_status" = 1;
 "small_photo_link" = "http://d22t200r9sgmit.cloudfront.net/img/nc2e4hcooaduaibtl99z-56c235e2eb1d1.jpg";
 "user_id" = 188;
 "user_name" = "Nadie Todirica";
 }
 
 */

#import "STPost.h"
#import "NSDate+Additions.h"
#import "STImageCacheController.h"

@implementation STPost
+ (instancetype)postWithDict:(NSDictionary *)postDict {
    STPost * post = [STPost new];
    post.infoDict = postDict;
    [post setup];
    
    return post;
}

-(void)setup{
    self.appVersion = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"app_version"];
    _caption = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"caption"];
    _isOwner = [self.infoDict[@"is_owner"] boolValue];
    _numberOfLikes = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"number_of_likes"];
    
    _postDate = [NSDate dateFromServerDateTime:self.infoDict[@"post_date"]];
    self.uuid = [CreateDataModelHelper validStringIdentifierFromValue:self.infoDict[@"post_id"]];
    _postLikedByCurrentUser = [self.infoDict[@"post_liked_by_current_user"] boolValue];
    _reportStatus = self.infoDict[@"report_status"];
    _smallPhotoUrl = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"small_photo_link"];
    _userId = [CreateDataModelHelper validStringIdentifierFromValue:self.infoDict[@"user_id"]];
    _userName = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"user_name"];
    _postSeen = [self.infoDict[@"post_seen"] boolValue];
    _showFullCaption = NO;

    //super properties
    self.mainImageUrl = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"full_photo_link"];
    self.mainImageDownloaded = [STImageCacheController imageDownloadedForUrl:self.mainImageUrl];
    self.imageSize = CGSizeZero;
    
    
}

@end
