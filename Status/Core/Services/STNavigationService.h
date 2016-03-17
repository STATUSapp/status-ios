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

//TODO: replace imagePickerController with imagePickerService

@property (nonatomic, strong) STImagePickerController *imagePickerController;

- (void)presentLoginScreen;
- (void)presentTabBarController;
-(void)switchToTabBarAtIndex:(NSInteger)index
                 popToRootVC:(BOOL)popToRoot;

+ (UIViewController *)viewControllerForSelectedTab;

@end
