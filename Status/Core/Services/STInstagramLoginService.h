//
//  STInstagramLoginService.h
//  Status
//
//  Created by Cosmin Andrus on 17/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSInteger const kClientCancelLoginCode;

typedef void (^STInstagramServiceCompletionBlock)(NSError *error);

@interface STInstagramLoginService : NSObject

@property (nonatomic, strong, readonly) NSString *clientInstagramToken;

- (void)startLoginWithCompletion:(STInstagramServiceCompletionBlock)completion;
- (NSURL *)getInstagramOauthURL;
- (void)instagramLoginFeedbackRedirectWithStatus:(NSInteger)statusCode;
- (void)commitInstagramClientToken;
- (void)clearService;
@end
