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
        
        __strong STUploadNewProfilePictureRequest *strongSelf = weakSelf;
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        strongSelf.params = params;
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", [CoreManager networkService].baseUrl, [strongSelf urlString]] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:strongSelf.pictureData
                                        name:@"image"
                                    fileName:@"image.jpg"
                                    mimeType:@"image/jpg"];
        } error:nil];
        
        NSURLSessionUploadTask *uploadTask = [[STNetworkQueueManager networkAPI]
                                              uploadTaskWithStreamedRequest:request
                                              progress:nil
                                              completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                  [[CoreManager networkService] removeFromQueue:strongSelf];
                                                  
                                                  if (error) {
                                                      NSLog(@"Error: %@", error);
                                                      if (strongSelf.failureBlock) {
                                                          strongSelf.failureBlock(error);
                                                      }
                                                      
                                                  } else {
                                                      [[CoreManager networkService] requestDidSucceed:strongSelf];
                                                      if (strongSelf.completionBlock) {
                                                          strongSelf.completionBlock(responseObject,nil);
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
