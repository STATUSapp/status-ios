//
//  STNavigationService.h
//  Status
//
//  Created by Andrus Cosmin on 29/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STImagePickerController;

@interface STNavigationService : NSObject

+ (void)presentLoginScreen;
+ (void)presentTabBarController;

+(STImagePickerController *)imagePickerController;

@end
