//
//  STUpdateUserProfileRequest.m
//  Status
//
//  Created by Silviu Burlacu on 28/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STUpdateUserProfileRequest.h"

@interface STUpdateUserProfileRequest ()

@property (nonatomic, strong) STUserProfile *userProfile;

@end

@implementation STUpdateUserProfileRequest

+ (void)updateUserProfileWithProfile:(STUserProfile *)userProfile
                      withCompletion:(STRequestCompletionBlock)completion
                             failure:(STRequestFailureBlock)failure {
    
    STUpdateUserProfileRequest *request = [STUpdateUserProfileRequest new];
    request.completionBlock = completion;
    request.failureBlock = failure;
    request.executionBlock = [request _getExecutionBlock];
    request.retryCount = 0;
    request.userProfile = userProfile;

    [[CoreManager networkService] addToQueueTop:request];
}

- (STRequestExecutionBlock) _getExecutionBlock
{
    __weak STUpdateUserProfileRequest *weakSelf = self;
    STRequestExecutionBlock executionBlock = ^{
        
        __strong STUpdateUserProfileRequest *strongSelf = weakSelf;
        NSMutableDictionary * paramsDict = [strongSelf getDictParamsWithToken];
        if (strongSelf.userProfile.firstname) {
            paramsDict[@"firstname"] = strongSelf.userProfile.firstname;
        }
        if (strongSelf.userProfile.lastName) {
            paramsDict[@"lastname"] = strongSelf.userProfile.lastName;
        }
        if (strongSelf.userProfile.fullName) {
            paramsDict[@"fullname"] = strongSelf.userProfile.fullName;
        }
        if (strongSelf.userProfile.bio) {
            paramsDict[@"bio"] = strongSelf.userProfile.bio;
        }
        if (strongSelf.userProfile.username) {
            paramsDict[@"username"] = strongSelf.userProfile.username;
        }
        if (strongSelf.userProfile.gender) {
            paramsDict[@"gender"] = strongSelf.userProfile.gender;
        }
        
        NSString *url = [strongSelf urlString];
        strongSelf.params = paramsDict;
        [[STNetworkQueueManager networkAPI] POST:url
                                      parameters:paramsDict
                                        progress:nil
                                         success:strongSelf.standardSuccessBlock
                                         failure:strongSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kUpdateUserProfile;
}

@end
