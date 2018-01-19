//
//  FeedCVC.h
//  Status
//
//  Created by Cosmin Home on 06/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSideBySideContaineeProtocol.h"
#import "STSideBySideContainerProtocol.h"

@class STFlowProcessor;

@protocol ContainerFeedCVCProtocol

@required
-(void)configureNavigationBar;
-(void)pushViewController:(UIViewController *)vc
                 animated:(BOOL)animated;
-(void)presentViewController:(UIViewController *)viewController
                    animated:(BOOL)animated;
@end

@interface FeedCVC : UICollectionViewController<STSideBySideContainerProtocol>

+ (FeedCVC *)feedControllerWithFlowProcessor:(STFlowProcessor *)processor;

@property (nonatomic, weak) id<STSideBySideContaineeProtocol> containeeDelegate;
@property (nonatomic, weak) id<ContainerFeedCVCProtocol>delegate;

@property (nonatomic, strong, readonly) STFlowProcessor *feedProcessor;
@property (nonatomic, strong, readonly) NSString *userName;

-(void)setFeedProcessor:(STFlowProcessor *)feedProcessor;
-(void)setUserName:(NSString *)userName;
- (void)onProfileOptionsPressed:(id)sender;

@end
