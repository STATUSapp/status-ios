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
#import "STInviteController.h"

@interface STInviteFriendsViewController ()
{
    UIButton *tappedButton;
}
@property (weak, nonatomic) IBOutlet UIButton *firstInvite;
@property (weak, nonatomic) IBOutlet UIButton *secondinvite;
@property (weak, nonatomic) IBOutlet UIButton *thirdinvite;
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

    [self loadButtons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadButtons{
    BOOL valid = [[STInviteController sharedInstance] validInviteNumber:@(_firstInvite.tag)];
    [_firstInvite setImage:[UIImage imageNamed:valid == NO ? @"invite your friends button":@"invited button"] forState:UIControlStateNormal];
    [_firstInvite setImage:[UIImage imageNamed:valid == NO ? @"invite your friends button pressed":@"invited button pressed"] forState:UIControlStateHighlighted];
    
    valid = [[STInviteController sharedInstance] validInviteNumber:@(_secondinvite.tag)];
    [_secondinvite setImage:[UIImage imageNamed:valid == NO ? @"invite your friends button":@"invited button"] forState:UIControlStateNormal];
    [_secondinvite setImage:[UIImage imageNamed:valid == NO ? @"invite your friends button pressed":@"invited button pressed"] forState:UIControlStateHighlighted];
    
    valid = [[STInviteController sharedInstance] validInviteNumber:@(_thirdinvite.tag)];
    [_thirdinvite setImage:[UIImage imageNamed:valid == NO ? @"invite your friends button":@"invited button"] forState:UIControlStateNormal];
    [_thirdinvite setImage:[UIImage imageNamed:valid == NO ? @"invite your friends button pressed":@"invited button pressed"] forState:UIControlStateHighlighted];

    
}

#pragma mark - IBActions

- (IBAction)onInviteYourFriends:(id)sender {

    tappedButton = sender;
    [(UIButton *)sender setUserInteractionEnabled:NO];
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
    
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    activityViewController.excludedActivityTypes = excludedActivities;
    UIActivityViewControllerCompletionHandler completion = ^(NSString *activityType, BOOL completed){
        //TODO: check if this works for all
        if (completed == YES) {
            [[STInviteController sharedInstance] setCurrentDateForInviteNumber:@(tappedButton.tag)];
            tappedButton = nil;
            [self loadButtons];
        }
        
    };
    
    
    
    [activityViewController setCompletionHandler:completion];
    
    [self presentViewController:activityViewController animated:YES completion:^{
        [(UIButton *)sender setUserInteractionEnabled:YES];
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
