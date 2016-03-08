//
//  STNavigationService.h
//  Status
//
//  Created by Andrus Cosmin on 29/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STImagePickerController;
@class STImagePickerService;

@interface STNavigationService : NSObject

//TODO: replace imagePickerController with imagePickerService

@property (nonatomic, strong) STImagePickerController *imagePickerController;
@property (nonatomic, strong) STImagePickerService * imagePickerService;

- (void)presentLoginScreen;
- (void)presentTabBarController;

@end
