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
        NSString *url = [weakSelf urlString];
        NSMutableDictionary *params = [weakSelf getDictParamsWithToken];
        if (weakSelf.requestType == STUserWithdrawnDetailsGet) {
            weakSelf.params = params;
            [[STNetworkQueueManager networkAPI] GET:url
                                         parameters:params
                                           progress:nil
                                            success:weakSelf.standardSuccessBlock
                                            failure:weakSelf.standardErrorBlock];
        }
        else
        {
            if (weakSelf.withdrawObj.firstname) {
                [params setObject:weakSelf.withdrawObj.firstname
                           forKey:@"firstname"];
            }
            if (weakSelf.withdrawObj.lastname) {
                [params setObject:weakSelf.withdrawObj.lastname
                           forKey:@"lastname"];
            }
            if (weakSelf.withdrawObj.email) {
                [params setObject:weakSelf.withdrawObj.email
                           forKey:@"email"];
            }
            if (weakSelf.withdrawObj.phone_number) {
                [params setObject:weakSelf.withdrawObj.phone_number
                           forKey:@"phone_number"];
            }
            if (weakSelf.withdrawObj.company) {
                [params setObject:weakSelf.withdrawObj.company
                           forKey:@"company"];
            }
            if (weakSelf.withdrawObj.vat_number) {
                [params setObject:weakSelf.withdrawObj.vat_number
                           forKey:@"vat_number"];
            }
            if (weakSelf.withdrawObj.register_number) {
                [params setObject:weakSelf.withdrawObj.register_number
                           forKey:@"register_number"];
            }
            if (weakSelf.withdrawObj.country) {
                [params setObject:weakSelf.withdrawObj.country
                           forKey:@"country"];
            }
            if (weakSelf.withdrawObj.city) {
                [params setObject:weakSelf.withdrawObj.city
                           forKey:@"city"];
            }
            if (weakSelf.withdrawObj.address) {
                [params setObject:weakSelf.withdrawObj.address
                           forKey:@"address"];
            }
            if (weakSelf.withdrawObj.iban) {
                [params setObject:weakSelf.withdrawObj.iban
                           forKey:@"iban"];
            }
            weakSelf.params = params;
            [[STNetworkQueueManager networkAPI] POST:url
                                          parameters:params
                                            progress:nil
                                             success:weakSelf.standardSuccessBlock
                                             failure:weakSelf.standardErrorBlock];
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
