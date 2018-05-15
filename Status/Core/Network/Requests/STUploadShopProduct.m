//
//  STUploadShopProduct.m
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STUploadShopProduct.h"
#import "STShopProduct.h"

@implementation STUploadShopProduct

+ (void)uploadShopProduct:(STShopProduct *)shopProduct
         withCompletion:(STRequestCompletionBlock)completion
                failure:(STRequestFailureBlock)failure{
    
    STUploadShopProduct *request = [STUploadShopProduct new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.shopProduct = shopProduct;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUploadShopProduct *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STUploadShopProduct *strongSelf = weakSelf;
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        if (strongSelf.shopProduct.productUrl) {
            params[@"link"] = strongSelf.shopProduct.productUrl;
        }
        strongSelf.params = params;
        NSData *imageData = UIImageJPEGRepresentation(strongSelf.shopProduct.localImage, 1.f);
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", [CoreManager networkService].baseUrl, [strongSelf urlString]] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData
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
    return kUploadShopProduct;
}


@end
