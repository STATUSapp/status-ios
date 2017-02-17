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
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        AFJSONResponseSerializer *jsonReponseSerializer;
        jsonReponseSerializer = [STNetworkManager customResponseSerializer];
        manager.responseSerializer = jsonReponseSerializer;
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        
        AFHTTPRequestOperation *op = [manager POST:[weakSelf urlString] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:UIImageJPEGRepresentation(weakSelf.shopProduct.localImage, 1.f) name:@"image" fileName:@"image.jpg" mimeType:@"image/jpg"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (weakSelf.completionBlock) {
                weakSelf.completionBlock(responseObject,nil);
            }
            
            [[CoreManager networkService] requestDidSucceed:weakSelf];        }
                                           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                               NSLog(@"Error: %@ ", operation.responseString);
                                               NSInteger statusCode = [operation.response statusCode];
                                               if (error.code == NSURLErrorCancelled) { //cancelled
                                                   statusCode = NSURLErrorCancelled;
                                               }
                                               
                                               NSError *err = [NSError errorWithDomain:error.domain
                                                                                  code:statusCode
                                                                              userInfo:error.userInfo];
                                               [[CoreManager networkService] removeFromQueue:weakSelf];
                                               if (weakSelf.failureBlock) {
                                                   weakSelf.failureBlock(err);
                                               }
                                               
                                           }];
        [op start];
    };
    
    return executionBlock;
    
}

-(NSString *)urlString{
    return kUploadShopProduct;
}


@end
