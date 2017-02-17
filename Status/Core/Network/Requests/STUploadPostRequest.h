//
//  STUploadPostRequest.h
//  Status
//
//  Created by Cosmin Andrus on 22/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"
@class STShopProduct;

@interface STUploadPostRequest : STBaseRequest
@property(nonatomic, strong)NSString *postId;
@property(nonatomic, strong)NSString *caption;
@property(nonatomic, strong)NSData *postData;
@property(nonatomic, strong)NSArray <STShopProduct *> *shopProducts;

+ (void)uploadPostForId:(NSString *)postId
               withData:(NSData*)postData
             andCaption:(NSString *)caption
           shopProducts:(NSArray <STShopProduct *> *)shopProducts
         withCompletion:(STRequestCompletionBlock)completion
                failure:(STRequestFailureBlock)failure;
@end
