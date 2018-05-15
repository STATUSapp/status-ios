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
        
        __strong STProductSuggestRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        params[@"barcode"] = strongSelf.barcodeString;
        params[@"brand"] = strongSelf.brand;
        params[@"product_name"] = strongSelf.productName;
        params[@"store"] = strongSelf.store;
        weakSelf.params = params;
        [[STNetworkQueueManager networkAPI] POST:url
                                     parameters:params
                                       progress:nil
                                        success:strongSelf.standardSuccessBlock
                                        failure:strongSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kProductSuggest;
}

@end
