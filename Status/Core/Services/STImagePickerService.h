//
//  STImageUploaderService.h
//  Status
//
//  Created by test on 07/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^imagePickerCompletion)(UIImage *img);

@interface STImagePickerService : NSObject

- (void)takeCameraPictureFromController:(UIViewController *)vc withCompletion:(imagePickerCompletion)completion;
- (void)launchLibraryPickerFromController:(UIViewController *)vc withCompletion:(imagePickerCompletion)completion;
- (void)launchFacebookPickerFromController:(UIViewController *)vc;



@end
