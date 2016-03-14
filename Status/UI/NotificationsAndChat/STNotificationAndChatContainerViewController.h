//
//  STNotificationAndChatContainerViewController.h
//  Status
//
//  Created by test on 08/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol STSideBySideContaineeDelegate <NSObject>

- (void)containeeEndedScrolling;
- (void)containeeStartedScrolling;

@end

@interface STNotificationAndChatContainerViewController : UIViewController<STSideBySideContaineeDelegate>

+ (instancetype)newController;

@end
