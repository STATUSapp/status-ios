//
//  STSettingsViewController.m
//  Status
//
//  Created by S B on 07/09/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STSettingsViewController.h"
#import "STRemoveAdsViewController.h"
#import "STLoginService.h"
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
#import "STUserProfilePool.h"
#import "STSnackBarService.h"
#import "STDeleteAccountRequest.h"

typedef NS_ENUM(NSUInteger, STSettingsSection) {
    STSettingsSectionNotifications = 0,
    STSettingsSectionCopyProfile,
    STSettingsSectionInviteFlow,
    STSettingsSectionLikeAdds,
    STSettingsSectionDeleteAccount,
    STSettingsSectionLogout,
    STSettingsSectionCount
};
typedef NS_ENUM(NSUInteger, STNotificationSection) {
    STNotificationSectionLikes = 0,
    STNotificationSectionMessages,
    STNotificationSectionUploadNew,
    STNotificationSectionAFriendJoined,
    STNotificationSectionPhotosWaiting,
    STNotificationSectionEarnExtraLikes,
    STNotificationSectionFollowers,
    STNotificationSectionTBDP,
    STNotificationSectionHintTBDP,
    STNotificationSectionSharePostTBDP,
    STNotificationSectionCount
};
@interface STSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@property (weak, nonatomic) IBOutlet UISwitch *switchLikes;
@property (weak, nonatomic) IBOutlet UISwitch *switchMessages;
@property (weak, nonatomic) IBOutlet UISwitch *switchUploadPhoto;
@property (weak, nonatomic) IBOutlet UISwitch *switchFriendJoinsStatus;
@property (weak, nonatomic) IBOutlet UISwitch *switchPhotosWaiting;
@property (weak, nonatomic) IBOutlet UISwitch *switchExtraLikes;
@property (weak, nonatomic) IBOutlet UISwitch *switchFollowers;
@property (weak, nonatomic) IBOutlet UISwitch *switchTBDP;
@property (weak, nonatomic) IBOutlet UISwitch *switchHintTBDP;
@property (weak, nonatomic) IBOutlet UISwitch *switchSharePostTBDP;

@property (strong, nonatomic) NSDictionary * settingsDict;
@property (strong, nonatomic) NSArray *deactivatedNotifications;
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Settings";
    self.deactivatedNotifications = @[@(STNotificationSectionMessages), @(STNotificationSectionPhotosWaiting), @(STNotificationSectionEarnExtraLikes)];
    NSString *versionString = [[STBaseRequest new] getAppVersion];
    _versionLabel.text = [NSString stringWithFormat:@"Version %@", versionString];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(onTapDone)];
    
    _settingsDict = [[NSUserDefaults standardUserDefaults] objectForKey:STSettingsDictKey];
    __weak STSettingsViewController * weakSelf = self;
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        __strong STSettingsViewController *strongSelf = weakSelf;
        if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
            strongSelf.settingsDict = response[@"data"];
            [[NSUserDefaults standardUserDefaults] setObject:strongSelf.settingsDict forKey:STSettingsDictKey];
            [strongSelf configureSwitches];

        }
    };

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
    [_switchTBDP setOn:[[_settingsDict valueForKey:STNotificationsTBDPKey] boolValue]];
    [_switchHintTBDP setOn:[[_settingsDict valueForKey:STNotificationsHintTBDPKey] boolValue]];
    [_switchSharePostTBDP setOn:[[_settingsDict valueForKey:STNotificationsSharePostTBDPKey] boolValue]];

}

- (NSDictionary *)getNewSettingsDict {
    return @{STNotificationsLikesKey : [NSNumber numberWithBool:_switchLikes.isOn],
             STNotificationsMessagesKey : [NSNumber numberWithBool:_switchMessages.isOn],
             STNotificationsUploadNewPhotoKey : [NSNumber numberWithBool:_switchUploadPhoto.isOn],
             STNotificationsFriendJoinStatusKey : [NSNumber numberWithBool:_switchFriendJoinsStatus.isOn],
             STNotificationsPhotosWaitingKey : [NSNumber numberWithBool:_switchPhotosWaiting.isOn],
             STNotificationsExtraLikesKey : [NSNumber numberWithBool:_switchExtraLikes.isOn],
             STNotificationsFollowersKey : @(_switchFollowers.isOn),
             STNotificationsTBDPKey : @(_switchTBDP.isOn),
             STNotificationsHintTBDPKey : @(_switchHintTBDP.isOn),
             STNotificationsSharePostTBDPKey : @(_switchSharePostTBDP.isOn)
             };
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addLinkToClipboard:(NSString *)shareUrl{
    if (shareUrl && [shareUrl length]) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = shareUrl;
        
        [[CoreManager snackBarService] showSnackBarWithMessage:@"Copied link to clipboard"];
    }
}


- (void)onTapDone {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return STSettingsSectionCount;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if (indexPath.section == STSettingsSectionNotifications) {
        if ([_deactivatedNotifications containsObject:@(indexPath.row)]) {
            //return 0.f to not show the row;
            height = 0.f;
        }
    }
    
    return height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger numRows = 0;
    switch (section) {
        case STSettingsSectionNotifications:
            numRows = STNotificationSectionCount;
            break;
        case STSettingsSectionCopyProfile:
            numRows = 1;
            break;
        case STSettingsSectionInviteFlow:
            numRows = 2;
            break;
        case STSettingsSectionLikeAdds:
            numRows = 4;
            break;
        case STSettingsSectionDeleteAccount:
            numRows = 1;
            break;
        case STSettingsSectionLogout:
            numRows = 1;
            break;

        default:
            break;
    }
    return numRows;
}

#pragma mark - IBActions

- (IBAction)onTapRemoveAds:(id)sender {
    STRemoveAdsViewController * removeAds = [STRemoveAdsViewController newInstance];
    removeAds.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:removeAds animated:YES completion:nil];
}

- (IBAction)onTapLogout:(id)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Logout from STATUS?", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Logout", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[CoreManager loginService] logoutManually];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)onTapRateUsInAppstore:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_REVIEW_URL_STRING]];
}
- (IBAction)onTapFollowUsOnInstagram:(id)sender {
    NSURL *instagramURL = [NSURL URLWithString:@"https://www.instagram.com/statusapp/"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    }
}

- (IBAction)onTapInviteFriends:(id)sender {
    UINavigationController * navVC = [STFriendsInviterViewController newController];
    [self.navigationController presentViewController:navVC animated:YES completion:nil];

}

- (IBAction)onTapFollowPeople:(id)sender {
    UINavigationController * suggestionsNav = [STSuggestionsViewController instatiateWithFollowType:STFollowTypeFriendsAndPeople];
    [self.navigationController presentViewController:suggestionsNav animated:YES completion:nil];
}

- (IBAction)onTapLikeUsOnFacebook:(id)sender {
    NSURL *facebookURL = [NSURL URLWithString:@"fb://profile/206383282888186"];
    if ([[UIApplication sharedApplication] canOpenURL:facebookURL]) {
        [[UIApplication sharedApplication] openURL:facebookURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.facebook.com/getSTATUSapp"]];
    }
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
- (IBAction)onTapTBDP:(id)sender {
    [self setSetting:STNotificationsTBDPKey fromSwitch:sender];
}
- (IBAction)onTapHintTBDP:(id)sender {
    [self setSetting:STNotificationsHintTBDPKey fromSwitch:sender];
}
- (IBAction)onTapSharePostTBDP:(id)sender {
    [self setSetting:STNotificationsSharePostTBDPKey fromSwitch:sender];
}

- (IBAction)onHowItWorksPressed:(id)sender {
    STTutorialPresenterViewController * tutorialVC = [STTutorialPresenterViewController newInstance];
    tutorialVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:tutorialVC animated:YES completion:nil];
}

- (IBAction)onCopyProfilePressed:(id)sender {
    NSString *currentUserId = [[CoreManager loginService] currentUserUuid];
    STUserProfile *up = [[CoreManager profilePool] getUserProfileWithId:currentUserId];
    [self addLinkToClipboard:up.profileShareUrl];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onDeleteAccountPressed:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning!", nil)
                                message:NSLocalizedString(@"\nAre you sure you want to delete your account?\n\n If you delete your account all your posts, likes, followers and other related data will be permanently deleted.", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Delete", nil) style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [STDeleteAccountRequest deleteAccountWithCompletion:^(id response, NSError *error) {
            if (!error) {
                if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                    [[CoreManager loginService] logoutManually];
                }
            }else{
                [self showFailAlert];
            }
        } failure:^(NSError *error) {
            [self showFailAlert];
        }];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:nil]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)setSetting:(NSString *)setting fromSwitch:(UISwitch *)sender {
    __weak STSettingsViewController * weakSelf = self;
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        __strong STSettingsViewController *strongSelf = weakSelf;
        if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
            [[NSUserDefaults standardUserDefaults] setObject:[strongSelf getNewSettingsDict] forKey:STSettingsDictKey];
            
        }
    };
    STRequestFailureBlock failBlock = ^(NSError *error){
        [sender setOn:!sender.isOn];
    };
    [STSetUserSettingsRequest setSettingsValue:sender.isOn forKey:setting withCompletion:completion failure:failBlock];
}

- (void)showFailAlert {
    UIAlertController *failAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                       message:NSLocalizedString(@"An error occured during the delete process. Please try again later.", nil) preferredStyle:UIAlertControllerStyleAlert];
    [failAlert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:failAlert animated:YES completion:nil];
}

@end
