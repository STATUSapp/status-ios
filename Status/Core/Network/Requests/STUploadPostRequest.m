//
//  STUploadPostRequest.m
//  Status
//
//  Created by Cosmin Andrus on 22/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STUploadPostRequest.h"
#import "STShopProduct.h"
#import "STNetworkQueueManager.h"
#import "STNetworkManager.h"

@implementation STUploadPostRequest
+ (void)uploadPostForId:(NSString *)postId
               withData:(NSData*)postData
             andCaption:(NSString *)caption
           shopProducts:(NSArray <STShopProduct *> *)shopProducts
         withCompletion:(STRequestCompletionBlock)completion
                failure:(STRequestFailureBlock)failure{
    
    STUploadPostRequest *request = [STUploadPostRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.postId = postId;
    request.caption = caption;
    request.postData = postData;
    request.shopProducts = shopProducts;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUploadPostRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSMutableDictionary *params = [self getDictParamsWithToken];
        if (weakSelf.postId) {
            params[@"post_id"] = weakSelf.postId;
        }
        
        if (weakSelf.caption) {
            params[@"caption"] = weakSelf.caption;
        }
        
        NSMutableArray *shopProductsIds = [@[] mutableCopy];
        for (STShopProduct *sp in weakSelf.shopProducts) {
            if (sp.uuid) {
                [shopProductsIds addObject:sp.uuid];
            }
        }
        if (shopProductsIds.count) {
            params[@"products"] = shopProductsIds;
        }
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", kBaseURL, [weakSelf urlString]] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:weakSelf.postData
                                        name:@"image"
                                    fileName:@"image.jpg"
                                    mimeType:@"image/jpg"];
        } error:nil];
        
        NSURLSessionUploadTask *uploadTask = [[STNetworkQueueManager networkAPI]
                                              uploadTaskWithStreamedRequest:request
                                              progress:nil
                                              completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                  [[CoreManager networkService] removeFromQueue:weakSelf];
                                                  
                                                  if (error) {
                                                      NSLog(@"Error: %@", error);
                                                      if (weakSelf.failureBlock) {
                                                          weakSelf.failureBlock(error);
                                                      }
                                                      
                                                  } else {
                                                      if (weakSelf.completionBlock) {
                                                          weakSelf.completionBlock(responseObject,nil);
                                                      }
                                                      [[CoreManager networkService] requestDidSucceed:weakSelf];
                                                  }
                                              }];
        
        [uploadTask resume];
    };
    
    return executionBlock;
    
}

-(NSString *)urlString{
    return _postId == nil?kPostPhoto:kUpdatePost;
}
@end
