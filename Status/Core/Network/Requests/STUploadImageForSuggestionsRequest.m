//
//  STUploadImageForSuggestions.m
//  Status
//
//  Created by Cosmin Andrus on 28/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STUploadImageForSuggestionsRequest.h"

@interface STUploadImageForSuggestionsRequest ()

@property (nonatomic, strong) NSData *imageData;

@end

@implementation STUploadImageForSuggestionsRequest

+ (void)uploadImageForSuggestionsWithData:(NSData*)imageData
                           withCompletion:(STRequestCompletionBlock)completion
                                  failure:(STRequestFailureBlock)failure{
    
    STUploadImageForSuggestionsRequest *request = [STUploadImageForSuggestionsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.imageData = imageData;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUploadImageForSuggestionsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STUploadImageForSuggestionsRequest *strongSelf = weakSelf;
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"suggestions"] = @(YES);
        params[@"pending"] = @(YES);
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", [CoreManager networkService].baseUrl, [strongSelf urlString]] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:strongSelf.imageData
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
    return kPostPhoto;
}

@end
