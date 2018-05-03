//
//  STUserWithDrawnDetailsRequest.m
//  Status
//
//  Created by Cosmin Andrus on 05/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STUserWithDrawnDetailsRequest.h"
#import "STWithdrawDetailsObj.h"

typedef NS_ENUM(NSUInteger, STUserWithdrawnDetails) {
    STUserWithdrawnDetailsGet = 0,
    STUserWithdrawnDetailsPost
};

@interface STUserWithDrawnDetailsRequest ()

@property (nonatomic, assign) STUserWithdrawnDetails requestType;
@property (nonatomic, strong) STWithdrawDetailsObj *withdrawObj;

@end
@implementation STUserWithDrawnDetailsRequest
+ (void)getUserWithdrawnDetailsWithCompletion:(STRequestCompletionBlock)completion
                                      failure:(STRequestFailureBlock)failure{
    
    STUserWithDrawnDetailsRequest *request = [STUserWithDrawnDetailsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.requestType = STUserWithdrawnDetailsGet;
    [[CoreManager networkService] addToQueueTop:request];
}

+ (void)postUserWithdrawnDetails:(STWithdrawDetailsObj *)withdrawObj
                  withCompletion:(STRequestCompletionBlock)completion
                         failure:(STRequestFailureBlock)failure{
    
    STUserWithDrawnDetailsRequest *request = [STUserWithDrawnDetailsRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.requestType = STUserWithdrawnDetailsPost;
    request.withdrawObj = withdrawObj;
    [[CoreManager networkService] addToQueueTop:request];
}


- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUserWithDrawnDetailsRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STUserWithDrawnDetailsRequest *strongSelf = weakSelf;
        NSString *url = [strongSelf urlString];
        NSMutableDictionary *params = [strongSelf getDictParamsWithToken];
        if (strongSelf.requestType == STUserWithdrawnDetailsGet) {
            strongSelf.params = params;
            [[STNetworkQueueManager networkAPI] GET:url
                                         parameters:params
                                           progress:nil
                                            success:strongSelf.standardSuccessBlock
                                            failure:strongSelf.standardErrorBlock];
        }
        else
        {
            if (strongSelf.withdrawObj.firstname) {
                [params setObject:strongSelf.withdrawObj.firstname
                           forKey:@"firstname"];
            }
            if (strongSelf.withdrawObj.lastname) {
                [params setObject:strongSelf.withdrawObj.lastname
                           forKey:@"lastname"];
            }
            if (strongSelf.withdrawObj.email) {
                [params setObject:strongSelf.withdrawObj.email
                           forKey:@"email"];
            }
            if (strongSelf.withdrawObj.phone_number) {
                [params setObject:strongSelf.withdrawObj.phone_number
                           forKey:@"phone_number"];
            }
            if (strongSelf.withdrawObj.company) {
                [params setObject:strongSelf.withdrawObj.company
                           forKey:@"company"];
            }
            if (strongSelf.withdrawObj.vat_number) {
                [params setObject:strongSelf.withdrawObj.vat_number
                           forKey:@"vat_number"];
            }
            if (strongSelf.withdrawObj.register_number) {
                [params setObject:strongSelf.withdrawObj.register_number
                           forKey:@"register_number"];
            }
            if (strongSelf.withdrawObj.country) {
                [params setObject:strongSelf.withdrawObj.country
                           forKey:@"country"];
            }
            if (strongSelf.withdrawObj.city) {
                [params setObject:strongSelf.withdrawObj.city
                           forKey:@"city"];
            }
            if (strongSelf.withdrawObj.address) {
                [params setObject:strongSelf.withdrawObj.address
                           forKey:@"address"];
            }
            if (strongSelf.withdrawObj.iban) {
                [params setObject:strongSelf.withdrawObj.iban
                           forKey:@"iban"];
            }
            strongSelf.params = params;
            [[STNetworkQueueManager networkAPI] POST:url
                                          parameters:params
                                            progress:nil
                                             success:strongSelf.standardSuccessBlock
                                             failure:strongSelf.standardErrorBlock];
        }
    };
    return executionBlock;
}

-(NSString *)urlString{
    if (self.requestType == STUserWithdrawnDetailsGet) {
        return kUserWithdrawnDetails;
    }
    
    return kUserWithdrawnUpdateDetails;

}

@end
