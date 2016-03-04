//
//  STImagePickerController.h
//  Status
//
//  Created by Cosmin Andrus on 30/01/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^imagePickerCompletion)(UIImage *img, BOOL shouldCompressImage);
typedef void (^askUserToUploadCompletion)();

@interface STImagePickerController : NSObject

@property (nonatomic, copy) imagePickerCompletion completion;
@property (nonatomic, copy) askUserToUploadCompletion askUploadCompletion;
@property (nonatomic ,strong) UIViewController *viewController;
-(void)startImagePickerInViewController:(UIViewController *)viewController
                         withCompletion:(imagePickerCompletion)completion
                       andAskCompletion:(askUserToUploadCompletion)askUploadCompletion;
-(void)startImagePickerForOwnerInViewController:(UIViewController *)viewController
                                 withCompletion:(imagePickerCompletion)completion;
@end
