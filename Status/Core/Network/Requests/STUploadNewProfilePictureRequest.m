//
//  STUploadNewProfilePictureRequest.m
//  Status
//
//  Created by Cosmin Andrus on 28/01/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STUploadNewProfilePictureRequest.h"

@implementation STUploadNewProfilePictureRequest
+ (void)uploadProfilePicture:(NSData*)pictureData
              withCompletion:(STRequestCompletionBlock)completion
                     failure:(STRequestFailureBlock)failure{
    
    STUploadNewProfilePictureRequest *request = [STUploadNewProfilePictureRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.pictureData = pictureData;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUploadNewProfilePictureRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        weakSelf.params = params;
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", [CoreManager networkService].baseUrl, [weakSelf urlString]] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:weakSelf.pictureData
                                        name:@"image"
                                    fileName:@"image.jpg"
                                    mimeType:@"image/jpg"];
        } error:nil];
        
        __block STUploadNewProfilePictureRequest *blockWeakSelf = weakSelf;
        
        NSURLSessionUploadTask *uploadTask = [[STNetworkQueueManager networkAPI]
                                              uploadTaskWithStreamedRequest:request
                                              progress:nil
                                              completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                  [[CoreManager networkService] removeFromQueue:blockWeakSelf];
                                                  
                                                  if (error) {
                                                      NSLog(@"Error: %@", error);
                                                      if (blockWeakSelf.failureBlock) {
                                                          blockWeakSelf.failureBlock(error);
                                                      }
                                                      
                                                  } else {
                                                      [[CoreManager networkService] requestDidSucceed:blockWeakSelf];
                                                      if (blockWeakSelf.completionBlock) {
                                                          blockWeakSelf.completionBlock(responseObject,nil);
                                                      }
                                                  }
                                              }];
        
        [uploadTask resume];
    };
    
    return executionBlock;
    
}

-(NSString *)urlString{
    return kSetProfilePicture;
}
@end
