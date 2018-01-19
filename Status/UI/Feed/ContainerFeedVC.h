//
//  ContainerFeedVC.h
//  Status
//
//  Created by Cosmin Andrus on 30/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STFlowProcessor;

@interface ContainerFeedVC : UIViewController

+ (ContainerFeedVC *)galleryFeedControllerForUserId:(NSString *)userId
                                        andUserName:(NSString *)userName;
+ (ContainerFeedVC *)tabProfileController;
+ (ContainerFeedVC *)homeFeedController;
+ (ContainerFeedVC *)singleFeedControllerWithPostId:(NSString *)postId;
+ (ContainerFeedVC *)feedControllerWithFlowProcessor:(STFlowProcessor *)processor;

@end
