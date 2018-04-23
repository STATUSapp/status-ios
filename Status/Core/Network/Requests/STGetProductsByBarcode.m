//
//  STGetProductsByBarcode.m
//  Status
//
//  Created by Cosmin Andrus on 20/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STGetProductsByBarcode.h"

@interface STGetProductsByBarcode ()

@property (nonatomic, strong) NSString *barcodeString;
@property (nonatomic, assign) NSInteger pageIndex;

@end

@implementation STGetProductsByBarcode
+ (void)getProductsByBarcode:(NSString *)barcodeString
                andPageIndex:(NSInteger)pageIndex
               andCompletion:(STRequestCompletionBlock)completion
                     failure:(STRequestFailureBlock)failure{
    
    STGetProductsByBarcode *request = [STGetProductsByBarcode new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.barcodeString = barcodeString;
    request.pageIndex = pageIndex;
    [[CoreManager networkService] addToQueue:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STGetProductsByBarcode *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        if (weakSelf.barcodeString) {
            params[@"barcode"] = weakSelf.barcodeString;
        }
        params[@"pageSize"] = @(kCatalogDownloadPageSize);
        params[@"page"] = @(weakSelf.pageIndex);
        weakSelf.params = params;
        [[STNetworkQueueManager networkAPI] GET:url
                                     parameters:params
                                       progress:nil
                                        success:weakSelf.standardSuccessBlock
                                        failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kGetProductsByBarcode;
}

@end
