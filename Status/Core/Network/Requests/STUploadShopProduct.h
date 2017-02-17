//
//  STUploadShopProduct.h
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"
@class STShopProduct;
@interface STUploadShopProduct : STBaseRequest

@property (nonatomic, strong) STShopProduct *shopProduct;

+ (void)uploadShopProduct:(STShopProduct *)shopProduct
           withCompletion:(STRequestCompletionBlock)completion
                  failure:(STRequestFailureBlock)failure;

@end
