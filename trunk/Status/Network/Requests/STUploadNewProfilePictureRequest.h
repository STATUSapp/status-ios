//
//  STUploadNewProfilePictureRequest.h
//  Status
//
//  Created by Cosmin Andrus on 28/01/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STUploadNewProfilePictureRequest : STBaseRequest
@property (nonatomic, strong) NSData *pictureData;
+ (void)uploadProfilePicture:(NSData*)pictureData
              withCompletion:(STRequestCompletionBlock)completion
                     failure:(STRequestFailureBlock)failure;
@end
