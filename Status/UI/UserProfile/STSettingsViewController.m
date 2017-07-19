//
//  STSettingsViewController.m
//  Status
//
//  Created by S B on 07/09/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STSettingsViewController.h"
#import "STRemoveAdsViewController.h"
#import "STFacebookLoginController.h"
#import <FBSDKLoginKit.h>
#import "AppDelegate.h"

#import "STGetUserSettingsRequest.h"
#import "STSetUserSettingsRequest.h"
#import "STTutorialPresenterViewController.h"
#import "STSuggestionsViewController.h"
#import "STFriendsInviterViewController.h"

#import "STDataAccessUtils.h"

// test

#import "STIAPHelper.h"

const NSInteger kSectionNumberNotifications = 0;
const NSInteger kSectionNumberInviteFollow = 1;
const NSInteger kSectionNumberContactLikeAds = 2;
const NSInteger kSectionNumberLogout = 3;

@interface STSettingsViewController ()
{
    FBSDKLoginButton *logoutButton;
}

@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UISwitch *switchLikes;
@property (weak, nonatomic) IBOutlet UISwitch *switchMessages;
@property (weak, nonatomic) IBOutlet UISwitch *switchUploadPhoto;
@property (weak, nonatomic) IBOutlet UISwitch *switchFriendJoinsStatus;
@property (weak, nonatomic) IBOutlet UISwitch *switchPhotosWaiting;
@property (weak, nonatomic) IBOutlet UISwitch *switchExtraLikes;
@property (weak, nonatomic) IBOutlet UISwitch *switchFollowers;

@property (strong, nonatomic) NSDictionary * settingsDict;
@end

@implementation STSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    
    NSString *versionString = [[STBaseRequest new] getAppVersion];
    _versionLabel.text = [NSString stringWithFormat:@"Version %@", versionString];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onTapDone)];
    
    _settingsDict = [[NSUserDefaults standardUserDefaults] objectForKey:STSettingsDictKey];
    __weak STSettingsViewController * weakSelf = self;
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
            weakSelf.settingsDict = response[@"data"];
            [[NSUserDefaults standardUserDefaults] setObject:weakSelf.settingsDict forKey:STSettingsDictKey];
            [weakSelf configureSwitches];

        }
    };

    logoutButton = [[CoreManager loginService] facebookLoginButton];
    [logoutButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    logoutButton.hidden = YES;
    [_logoutCell addSubview:logoutButton];
    [STGetUserSettingsRequest getUserSettingsWithCompletion:completion failure:nil];
    [self configureSwitches];
}

- (void)configureSwitches {
    [_switchLikes setOn:[[_settingsDict valueForKey:STNotificationsLikesKey] boolValue]];
    [_switchMessages setOn:[[_settingsDict valueForKey:STNotificationsMessagesKey] boolValue]];
    [_switchUploadPhoto setOn:[[_settingsDict valueForKey:STNotificationsUploadNewPhotoKey] boolValue]];
    [_switchFriendJoinsStatus setOn:[[_settingsDict valueForKey:STNotificationsFriendJoinStatusKey] boolValue]];
    [_switchPhotosWaiting setOn:[[_settingsDict valueForKey:STNotificationsPhotosWaitingKey] boolValue]];
    [_switchExtraLikes setOn:[[_settingsDict valueForKey:STNotificationsExtraLikesKey] boolValue]];
    [_switchFollowers setOn:[[_settingsDict valueForKey:STNotificationsFollowersKey] boolValue]];
}

- (NSDictionary *)getNewSettingsDict {
    return @{STNotificationsLikesKey : [NSNumber numberWithBool:_switchLikes.isOn],
             STNotificationsMessagesKey : [NSNumber numberWithBool:_switchMessages.isOn],
             STNotificationsUploadNewPhotoKey : [NSNumber numberWithBool:_switchUploadPhoto.isOn],
             STNotificationsFriendJoinStatusKey : [NSNumber numberWithBool:_switchFriendJoinsStatus.isOn],
             STNotificationsPhotosWaitingKey : [NSNumber numberWithBool:_switchPhotosWaiting.isOn],
             STNotificationsExtraLikesKey : [NSNumber numberWithBool:_switchExtraLikes.isOn],
             STNotificationsFollowersKey : @(_switchFollowers.isOn)};
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onTapDone {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case kSectionNumberNotifications:
            return 7;
        case kSectionNumberContactLikeAds:
            return 3;
        case kSectionNumberInviteFollow:
            return 2;
        case kSectionNumberLogout:
            return 1;
            
        default:
            return 0;
            break;
    }
}

#pragma mark - IBActions

- (IBAction)onTapRemoveAds:(id)sender {
    STRemoveAdsViewController * removeAds = [STRemoveAdsViewController newInstance];
    removeAds.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:removeAds animated:YES completion:nil];
}

- (IBAction)onTapLogout:(id)sender {
    [self fireFbLoginView];
}
- (IBAction)onTapRateUsInAppstore:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_REVIEW_URL_STRING]];
}

- (IBAction)onTapInviteFriends:(id)sender {
    STFriendsInviterViewController * inviteFriendsVC = [STFriendsInviterViewController newController];
    [self.navigationController pushViewController:inviteFriendsVC animated:NO];

}

- (IBAction)onTapFollowPeople:(id)sender {
    STSuggestionsViewController * suggestionsVC = [STSuggestionsViewController instatiateWithFollowType:STFollowTypeFriendsAndPeople];
    [self.navigationController pushViewController:suggestionsVC animated:YES];
}

- (IBAction)onTapLikeUsOnFacebook:(id)sender {
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/206383282888186"];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/getSTATUSapp"]];
    }
}

-(void)fireFbLoginView{
    [logoutButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}


- (IBAction)onTapLikeSwitch:(UISwitch *)sender {
    [self setSetting:STNotificationsLikesKey fromSwitch:sender];
}

- (IBAction)onTapMessagesSwitch:(UISwitch *)sender {
    [self setSetting:STNotificationsMessagesKey fromSwitch:sender];
}
- (IBAction)onTapUploadNewPhotoSwitch:(UISwitch *)sender {
    [self setSetting:STNotificationsUploadNewPhotoKey fromSwitch:sender];
}
- (IBAction)onTapFriendJoinsStatusSwitch:(UISwitch *)sender {
    [self setSetting:STNotificationsFriendJoinStatusKey fromSwitch:sender];
}
- (IBAction)onTapPhotosWaitingSwitch:(UISwitch *)sender {
    [self setSetting:STNotificationsPhotosWaitingKey fromSwitch:sender];
}
- (IBAction)onTapExtraLikesSwitch:(UISwitch *)sender {
    [self setSetting:STNotificationsExtraLikesKey fromSwitch:sender];
}
- (IBAction)onTapFollowersSwitch:(id)sender {
    [self setSetting:STNotificationsFollowersKey fromSwitch:sender];
}

- (IBAction)onHowItWorksPressed:(id)sender {
    STTutorialPresenterViewController * tutorialVC = [STTutorialPresenterViewController newInstance];
    tutorialVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:tutorialVC animated:YES completion:nil];
}


- (void)setSetting:(NSString *)setting fromSwitch:(UISwitch *)sender {
    __weak UISwitch * weakSender = sender;
    __weak STSettingsViewController * weakSelf = self;
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
            [[NSUserDefaults standardUserDefaults] setObject:[weakSelf getNewSettingsDict] forKey:STSettingsDictKey];
            
        }
    };
    STRequestFailureBlock failBlock = ^(NSError *error){
        [weakSender setOn:!sender.isOn];
    };
    [STSetUserSettingsRequest setSettingsValue:weakSender.isOn forKey:setting withCompletion:completion failure:failBlock];
}

@end
