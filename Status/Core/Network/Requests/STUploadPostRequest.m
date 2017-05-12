//
//  STUploadPostRequest.m
//  Status
//
//  Created by Cosmin Andrus on 22/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STUploadPostRequest.h"
#import "STShopProduct.h"

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
        else if (weakSelf.caption) {
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
        
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        AFJSONResponseSerializer *jsonReponseSerializer;
        jsonReponseSerializer = [STNetworkManager customResponseSerializer];
        manager.responseSerializer = jsonReponseSerializer;
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];


        AFHTTPRequestOperation *op = [manager POST:[weakSelf urlString] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:weakSelf.postData name:@"image" fileName:@"image.jpg" mimeType:@"image/jpg"];
            
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
    return _postId == nil?kPostPhoto:kUpdatePost;
}
@end
