//
//  FeedCVC.h
//  Status
//
//  Created by Cosmin Home on 06/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STFlowProcessor;

@interface FeedCVC : UICollectionViewController

+ (FeedCVC *)mainFeedController;
+ (FeedCVC *)singleFeedControllerWithPostId:(NSString *)postId;
+ (FeedCVC *)galleryFeedControllerForUserId:(NSString *)userId
                                andUserName:(NSString *)userName;

+ (FeedCVC *)feedControllerWithFlowProcessor:(STFlowProcessor *)processor;

@property (nonatomic, assign) BOOL shouldAddBackButton;

@end
