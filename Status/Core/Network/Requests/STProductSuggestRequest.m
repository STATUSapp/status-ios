//
//  STProductSuggestRequest.m
//  Status
//
//  Created by Cosmin Andrus on 21/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STProductSuggestRequest.h"

@interface STProductSuggestRequest ()

@property (nonatomic, strong) NSString *barcodeString;
@property (nonatomic, strong) NSString *brand;
@property (nonatomic, strong) NSString *productName;
@property (nonatomic, strong) NSString *store;

@end

@implementation STProductSuggestRequest
+ (void)suggestProductWithBarcode:(NSString *)barcodeString
                            brand:(NSString *)brand
                      productName:(NSString *)productName
                            store:(NSString *)store
                                andCompletion:(STRequestCompletionBlock)completion
                                      failure:(STRequestFailureBlock)failure{
    
    STProductSuggestRequest *request = [STProductSuggestRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.barcodeString = barcodeString;
    request.brand = brand;
    request.productName = productName;
    request.store = store;
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STProductSuggestRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        params[@"barcode"] = weakSelf.barcodeString;
        params[@"brand"] = weakSelf.brand;
        params[@"product_name"] = weakSelf.productName;
        params[@"store"] = weakSelf.store;
        weakSelf.params = params;
        [[STNetworkQueueManager networkAPI] POST:url
                                     parameters:params
                                       progress:nil
                                        success:weakSelf.standardSuccessBlock
                                        failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kProductSuggest;
}

@end
