//
//  STFacebookActivity.m
//  Status
//
//  Created by Andrus Cosmin on 29/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookActivity.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation STFacebookActivity
- (NSString *)activityType {
    return @"ro.status.FACEBOOK";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"facebook_messenger"];
}

- (NSString *)activityTitle
{
    return @"Facebook Messenger";
}

-(FBLinkShareParams *)paramsForActivities:(NSArray *)activityItems{
    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
    params.link =
    [NSURL URLWithString:activityItems[1]];
    params.name = @"STATUS";
    params.caption = activityItems[0];
    //params.picture = [NSURL URLWithString:@"http://i.imgur.com/g3Qc1HN.png"];
    params.linkDescription = activityItems[0];

    return params;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
//    [FBSettings setLoggingBehavior:[NSSet setWithObjects:
//                                    FBLoggingBehaviorFBRequests,
//                                    FBLoggingBehaviorFBURLConnections,
//                                    FBLoggingBehaviorAccessTokens,
//                                    FBLoggingBehaviorPerformanceCharacteristics,
//                                    FBLoggingBehaviorSessionStateTransitions,
//                                    nil]];
    
    // If the Facebook app is installed and we can present the share dialog
    if ([FBDialogs canPresentMessageDialogWithParams:nil]) {
        return YES;
    }
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    [FBDialogs presentMessageDialogWithParams:[self paramsForActivities:activityItems] clientState:@{} handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
        if(error) {
            // An error occurred, we need to handle the error
            // See: https://developers.facebook.com/docs/ios/errors
            NSLog(@"%@",[NSString stringWithFormat:@"Error messaging link: %@", error.description]);
        } else {
            // Success
            NSLog(@"result %@", results);
        }
    }];
}
@end
