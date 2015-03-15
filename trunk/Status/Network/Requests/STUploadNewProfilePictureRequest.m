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
    [[STNetworkQueueManager sharedManager] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUploadNewProfilePictureRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSMutableDictionary *params = [self getDictParamsWithToken];

        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        AFJSONResponseSerializer *jsonReponseSerializer;
        jsonReponseSerializer = [STNetworkManager customResponseSerializer];
        manager.responseSerializer = jsonReponseSerializer;
        
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        
        AFHTTPRequestOperation *op = [manager POST:[weakSelf urlString] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:weakSelf.pictureData name:@"image" fileName:@"image.jpg" mimeType:@"image/jpg"];
            
        } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (weakSelf.completionBlock) {
                weakSelf.completionBlock(responseObject,nil);
            }
            
            [[STNetworkQueueManager sharedManager] requestDidSucceed:weakSelf];        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Error: %@ ", operation.responseString);
                NSInteger statusCode = [operation.response statusCode];
                if (error.code == NSURLErrorCancelled) { //cancelled
                    statusCode = NSURLErrorCancelled;
                }
                
                NSError *err = [NSError errorWithDomain:error.domain
                                                   code:statusCode
                                               userInfo:error.userInfo];
                if (weakSelf.failureBlock) {
                    weakSelf.failureBlock(err);
                }
            }];
        [op start];
    };
    
    return executionBlock;
    
}

-(NSString *)urlString{
    return kSetProfilePicture;
}
@end
