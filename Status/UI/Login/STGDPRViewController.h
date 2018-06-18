//
//  GDPRViewController.h
//  Status
//
//  Created by Cosmin Andrus on 18/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, STGDPRType) {
    STGDPRTypeTermsOfUse = 0,
    STGDPRTypePrivacyPolicy,
};
@interface STGDPRViewController : UIViewController

+ (UINavigationController *)GDPRControllerWithType:(STGDPRType)type;

@end
