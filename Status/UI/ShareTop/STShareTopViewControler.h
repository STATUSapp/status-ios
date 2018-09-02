//
//  STShareTopViewControler.h
//  Status
//
//  Created by Cosmin Andrus on 01/09/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STNotificationObj;

@interface STShareTopViewControler : UIViewController

+ (STShareTopViewControler *)shareTopViewControllerWithNotification:(STNotificationObj *)no;

@end
