//
//  STInviteFriendsViewController.m
//  Status
//
//  Created by Silviu on 17/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STInviteFriendsViewController.h"
#import "STWhatsAppActivity.h"
#import "STConstants.h"
#import "STFacebookActivity.h"

@interface STInviteFriendsViewController ()
{
    UIActivityViewController *activityViewController;
}
@end

@implementation STInviteFriendsViewController

+ (STInviteFriendsViewController *)newInstance {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([STInviteFriendsViewController class])];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *inviteText = STInviteText;
    NSString *inviteLink = STInviteLink;
    
    NSArray *applicationActivities = @[[STWhatsAppActivity new],[STFacebookActivity new]];
    NSArray *excludedActivities    = @[UIActivityTypePostToWeibo,
                                       UIActivityTypePrint,
                                       UIActivityTypeCopyToPasteboard,
                                       UIActivityTypeAssignToContact,
                                       UIActivityTypeSaveToCameraRoll,
                                       UIActivityTypeAddToReadingList,
                                       UIActivityTypePostToFlickr,
                                       UIActivityTypePostToVimeo,
                                       UIActivityTypePostToTencentWeibo,
                                       UIActivityTypeAirDrop];
    NSArray *activityItems         = @[inviteText, inviteLink];
    
    
    activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    activityViewController.excludedActivityTypes = excludedActivities;
    UIActivityViewControllerCompletionHandler completion = ^(NSString *activityType, BOOL completed){
        //TODO: add tracker
    };
    [activityViewController setCompletionHandler:completion];}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)onInviteYourFriends:(id)sender {

    [self presentViewController:activityViewController animated:YES completion:^{
        
    }];
}


- (IBAction)dismissController:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
