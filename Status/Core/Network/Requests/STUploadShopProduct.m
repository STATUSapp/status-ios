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
        
        NSMutableDictionary *params = [self getDictParamsWithToken];
        if (weakSelf.shopProduct.productUrl) {
            params[@"link"] = weakSelf.shopProduct.productUrl;
        }
        
        NSData *imageData = UIImageJPEGRepresentation(weakSelf.shopProduct.localImage, 1.f);
        
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[NSString stringWithFormat:@"%@%@", kBaseURL, [weakSelf urlString]] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:imageData
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
    return kUploadShopProduct;
}


@end
