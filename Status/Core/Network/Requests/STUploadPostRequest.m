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
        
        __strong STUploadPostRequest *strongSelf = weakSelf;
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        if (strongSelf.postId) {
            params[@"post_id"] = strongSelf.postId;
        }
        
        if (strongSelf.caption) {
            params[@"caption"] = strongSelf.caption;
        }
        
        NSMutableArray *shopProductsIds = [@[] mutableCopy];
        for (STShopProduct *sp in strongSelf.shopProducts) {
            if (sp.uuid) {
                [shopProductsIds addObject:sp.uuid];
            }
        }
        if (shopProductsIds.count) {
            params[@"products"] = shopProductsIds;
        }
        strongSelf.params = params;
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", [CoreManager networkService].baseUrl, [strongSelf urlString]] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:strongSelf.postData
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
    return _postId == nil?kPostPhoto:kUpdatePost;
}
@end
