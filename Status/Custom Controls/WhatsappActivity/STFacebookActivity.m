//
//  STFacebookActivity.m
//  Status
//
//  Created by Andrus Cosmin on 29/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookActivity.h"
#import "STInviteController.h"
#import <FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKMessageDialog.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>

@interface STFacebookActivity()<FBSDKSharingDelegate>

@end

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

-(FBSDKShareLinkContent *)paramsForActivities:(NSArray *)activityItems{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.imageURL = [NSURL URLWithString:@"http://status.glazeon.com/logo120p.png"];
    content.contentURL = [NSURL URLWithString:activityItems[1]];
    content.contentDescription = activityItems[0];
    content.contentTitle =  @"STATUS";

    return content;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    [FBSDKMessageDialog showWithContent:[self paramsForActivities:activityItems] delegate:self];
}

#pragma mark - FBSDKSharingDelegate
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    [[STInviteController sharedInstance] setCurrentDateForSelectedItem];
}

- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    NSLog(@"%@",[NSString stringWithFormat:@"Error messaging link: %@", error.description]);
}

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    NSLog(@"Sharing cancel");
}

@end
