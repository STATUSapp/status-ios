//
//  STInstagramLoginService.m
//  Status
//
//  Created by Cosmin Andrus on 17/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STInstagramLoginService.h"
#import "STInstagramClientTokenRequest.h"
#import "STNavigationService.h"

NSString * const kInstagramClientToken = @"InstagramClientToken";
NSString * const kInstagramErrorDomain = @"com.status.instagram.error";
NSString * const kInstagramClientId = @"bf3b1b512b3944219eb264f713e8dc30";

NSInteger const kNoClientTokenReceivedCode = 10001;
NSInteger const kClientCancelLoginCode = 10002;

@interface STInstagramLoginService ()

@property (nonatomic, strong, readwrite) NSString *clientInstagramToken;
@property (nonatomic, copy) STInstagramServiceCompletionBlock completion;
@end

@implementation STInstagramLoginService

-(instancetype)init{
    self = [super init];
    if (self) {
        _clientInstagramToken = [self loadInstagramClientToken];
    }
    return self;
}

- (void)startLoginWithCompletion:(STInstagramServiceCompletionBlock)completion{
    self.completion = completion;
    if (self.clientInstagramToken) {
        self.completion(nil);
        return;
    }else{
        //get a new instagram client token
        __weak STInstagramLoginService *weakSelf = self;
        [STInstagramClientTokenRequest getClientInstagramTokenWithCompletion:^(id response, NSError *error) {
            __strong STInstagramLoginService *strongSelf = weakSelf;
            if (!error) {
                NSString *instaClientToken = response[@"instagram_client_token"];
                if (instaClientToken) {
                    strongSelf.clientInstagramToken = instaClientToken;
                    [[CoreManager navigationService]presentInstagramLogin];
                    
                }else{
                    strongSelf.clientInstagramToken = nil;
                    strongSelf.completion([NSError errorWithDomain:kInstagramErrorDomain code:kNoClientTokenReceivedCode userInfo:nil]);
                }
            }else{
                strongSelf.clientInstagramToken = nil;
                strongSelf.completion(error);
            }
        } failure:^(NSError *error) {
            __strong STInstagramLoginService *strongSelf = weakSelf;
            strongSelf.clientInstagramToken = nil;
            strongSelf.completion(error);
        }];
    }
}

- (NSURL *)getInstagramOauthURL{
    if (!self.clientInstagramToken) {
        return nil;
    }
    NSString *redirectURI = [NSString stringWithFormat:@"%@instagram_authentication?instagram_client_token=%@", kNoApiBaseURL, self.clientInstagramToken];
    NSString *urlString = [NSString stringWithFormat:@"https://api.instagram.com/oauth/authorize/?client_id=%@&redirect_uri=%@&response_type=code", kInstagramClientId, redirectURI];
    NSURL *url = [NSURL URLWithString:urlString];
    return url;
}

- (void)instagramLoginFeedbackRedirectWithStatus:(NSInteger)statusCode{
    if (statusCode == 200) {
        self.completion(nil);
    }else{
        //error
        NSError *error = [NSError errorWithDomain:kInstagramErrorDomain code:statusCode userInfo:nil];
        self.clientInstagramToken = nil;
        self.completion(error);
    }
}

- (void)commitInstagramClientToken{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:self.clientInstagramToken forKey:kInstagramClientToken];
    [ud synchronize];
}

- (void)clearService{
    self.clientInstagramToken = nil;
    self.completion = nil;
    [self commitInstagramClientToken];
}
#pragma mark - Private

- (NSString *)loadInstagramClientToken{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *result = [ud valueForKey:kInstagramClientToken];
    return result;
}

- (void)saveInstagramClientToken{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:self.clientInstagramToken forKey:kInstagramClientToken];
    [ud synchronize];

}
@end
