//
//  STChatRoomViewController.h
//  Status
//
//  Created by Andrus Cosmin on 27/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STListUser;

@interface STChatRoomViewController : UIViewController
+ (STChatRoomViewController *)roomWithUser:(STListUser *)user;
@end
