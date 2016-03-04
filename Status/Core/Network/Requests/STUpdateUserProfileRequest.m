//
//  STUpdateUserProfileRequest.m
//  Status
//
//  Created by Silviu Burlacu on 28/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STUpdateUserProfileRequest.h"

@implementation STUpdateUserProfileRequest

+ (void)updateUserProfileWithFirstName:(NSString *)firstName
                              lastName:(NSString *)lastName
                              fullName:(NSString *)fullName
                          homeLocation:(NSString *)location
                                   bio:(NSString *)bio
                        withCompletion:(STRequestCompletionBlock)completion
                               failure:(STRequestFailureBlock)failure {
    
    STUpdateUserProfileRequest *request = [STUpdateUserProfileRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    
    NSMutableDictionary * paramsDict = [request getDictParamsWithToken];
    if (firstName.length) {
        paramsDict[@"firstname"] = firstName;
    }
    if (lastName.length) {
        paramsDict[@"lastname"] = lastName;
    }
    if (fullName.length) {
        paramsDict[@"fullname"] = fullName;
    }
    if (location.length) {
        paramsDict[@"location"] = location;
    }
    if (bio.length) {
        paramsDict[@"bio"] = bio;
    }
    request.paramsDict = paramsDict;
    
    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUpdateUserProfileRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        NSString *url = [weakSelf urlString];
        
        [[STNetworkQueueManager networkAPI] POST:url
                                    parameters:weakSelf.paramsDict
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kUpdateUserProfile;
}

@end
