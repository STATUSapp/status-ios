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
        
        NSMutableDictionary * paramsDict = [weakSelf getDictParamsWithToken];
        if (weakSelf.userProfile.firstname) {
            paramsDict[@"firstname"] = weakSelf.userProfile.firstname;
        }
        if (weakSelf.userProfile.lastName) {
            paramsDict[@"lastname"] = weakSelf.userProfile.lastName;
        }
        if (weakSelf.userProfile.fullName) {
            paramsDict[@"fullname"] = weakSelf.userProfile.fullName;
        }
        if (weakSelf.userProfile.bio) {
            paramsDict[@"bio"] = weakSelf.userProfile.bio;
        }
        if (weakSelf.userProfile.username) {
            paramsDict[@"username"] = weakSelf.userProfile.username;
        }
        if (weakSelf.userProfile.gender) {
            paramsDict[@"gender"] = weakSelf.userProfile.gender;
        }
        
        NSString *url = [weakSelf urlString];
        weakSelf.params = paramsDict;
        [[STNetworkQueueManager networkAPI] POST:url
                                    parameters:paramsDict
                                        progress:nil
                                       success:weakSelf.standardSuccessBlock
                                       failure:weakSelf.standardErrorBlock];
    };
    return executionBlock;
}

-(NSString *)urlString{
    return kUpdateUserProfile;
}

@end
