//
//  STUserProfileViewController.m
//  Status
//
//  Created by Silviu Burlacu on 03/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STUserProfileViewController.h"
#import "STGetUserProfileRequest.h"
#import "NSDate+Additions.h"
#import "STEditProfileViewController.h"
#import "STMenuController.h"
#import "UIImage+ImageEffects.h"
#import "UIImageView+WebCache.h"
#import "STLocationManager.h"
#import "STFlowTemplateViewController.h"
#import "STConstants.h"
#import "STImagePickerController.h"
#import "STConversationsListViewController.h"
#import "STChatRoomViewController.h"
#import "STMoveScaleViewController.h"
#import "STInviteUserToUploadRequest.h"
#import "STSettingsViewController.h"
#import "STUsersListController.h"

#import "STFollowUsersRequest.h"
#import "STUnfollowUsersRequest.h"


@interface STUserProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBlurryPicture;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLocationIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewStatusIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblNameAndAge;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblUserDescription;
@property (weak, nonatomic) IBOutlet UIButton *btnFollowersCount;

@property (weak, nonatomic) IBOutlet UIButton *btnMessages;
@property (weak, nonatomic) IBOutlet UIButton *btnGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;
@property (weak, nonatomic) IBOutlet UIButton *btnEditUserProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnNextProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnFollow;
@property (weak, nonatomic) IBOutlet UIButton *btnFollowers;
@property (weak, nonatomic) IBOutlet UIButton *btnFollowing;
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessageToUser;
@property (weak, nonatomic) IBOutlet UIView *loadingPlaceholder;

@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) STUserProfile * userProfile;
@property (nonatomic, assign) BOOL skipRefreshReqeust;

@end

@implementation STUserProfileViewController

+ (STUserProfileViewController *)newControllerWithUserId:(NSString *)userId {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:[NSBundle mainBundle]];
    STUserProfileViewController * newController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([STUserProfileViewController class])];
    newController.userId = userId;
    
    return newController;
}


+ (STUserProfileViewController *)newControllerWithUserUserDataModel:(STUserProfile *)userProfile {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:[NSBundle mainBundle]];
    STUserProfileViewController * newController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([STUserProfileViewController class])];
    newController.userProfile = userProfile;
    newController.userId = userProfile.uuid;
    newController.skipRefreshReqeust = YES;
    
    return newController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _loadingPlaceholder.hidden = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_skipRefreshReqeust) {
        _skipRefreshReqeust = NO;
        [self setupVisualsWithProfile:_userProfile];
    } else {
        [self getAndDisplayProfile];
    }
    
    if (_isMyProfile) {
        _btnNextProfile.hidden = YES;
        _btnFollow.hidden = YES;
        _btnSettings.hidden = NO;
        _btnSendMessageToUser.hidden = YES;
        _btnEditUserProfile.hidden = NO;
        _btnFollowers.hidden = NO;
        _btnFollowing.hidden = NO;
        _btnFollowersCount.hidden = YES;
    } else {
        _btnNextProfile.hidden = NO;
        _btnFollow.hidden = NO;
        _btnSettings.hidden = YES;
        _btnSendMessageToUser.hidden = NO;
        _btnEditUserProfile.hidden = YES;
        _btnFollowers.hidden = YES;
        _btnFollowing.hidden = YES;
        _btnFollowersCount.hidden = NO;
    }
    
    if (!_isLaunchedFromNearbyController) {
        UISwipeGestureRecognizer * swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGallery:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.view addGestureRecognizer:swipeLeft];
        
        UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onBack)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.view addGestureRecognizer:swipeRight];
    }
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (STUserProfile *)userProfile {
    return _userProfile;
}

- (void)getAndDisplayProfile {
    
    _loadingPlaceholder.hidden = NO;
    
    if (_userProfile) {
        [self setupVisualsWithProfile:_userProfile];
    }    
    __weak STUserProfileViewController * weakSelf = self;
    [STGetUserProfileRequest getProfileForUserID:_userId withCompletion:^(id response, NSError *error) {
        
        weakSelf.userProfile = [STUserProfile userProfileWithDict:response];
        [weakSelf setupVisualsWithProfile:weakSelf.userProfile];
        
    } failure:^(NSError *error) {
        // empty all fields
        NSLog(@"%@", error.debugDescription);
        
        [[[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Something went wrong. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        
    }];
}

- (void)setupVisualsWithProfile:(STUserProfile *)profile {
    
    if (profile.firstname.length) {
        _lblNameAndAge.text = profile.firstname;
    } else {
        _lblNameAndAge.text = profile.fullName;
    }
    
    if (profile.birthday) {
        NSString * age = [NSDate yearsFromDate:profile.birthday];
        if (age) {
            _lblNameAndAge.text = [NSString stringWithFormat:@"%@, %@", _lblNameAndAge.text, age];
        }
    }

    [_btnGallery setTitle:[NSString stringWithFormat:@"%li", profile.numberOfPosts] forState:UIControlStateNormal];
    
    if (profile.bio == nil) {
        profile.bio = @"";
    }
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    
    NSAttributedString * bioString = [[NSAttributedString alloc] initWithString:profile.bio attributes:@{NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Regular" size:14.0f],
                                                                                                 NSParagraphStyleAttributeName : paragraphStyle}];
    _lblUserDescription.attributedText = bioString;
    
    
    if (profile.homeLocation == nil) {
        _imageViewLocationIcon.hidden = YES;
        _lblLocation.text = @"";
    }else {
        _imageViewLocationIcon.hidden = YES;
        _lblLocation.text = profile.homeLocation;
    }
    
    [_imageViewProfilePicture sd_setImageWithURL:[NSURL URLWithString:profile.profilePhotoURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        _imageViewBlurryPicture.image = [image applyDarkEffect];
    }];
    
    
    BOOL hasLastSeenStatus = YES;
    NSString * statusText;
    if (profile.isActive) {
        statusText = @"Active Now";
        [self setStatusIconForStatus:STUserStatusActive];
    } else if (profile.wasNeverActive) {
        statusText = @"Not Active";
        [self setStatusIconForStatus:STUserStatusOffline];
    } else if (profile.lastActive != nil) {
        statusText = [NSDate statusForLastTimeSeen:profile.lastActive];
        [self setStatusIconForStatus:[NSDate statusTypeForLastTimeSeen:profile.lastActive]];
    } else {
        hasLastSeenStatus = NO;
    }
    
   statusText = hasLastSeenStatus ? [NSString stringWithFormat:@" - %@", statusText] : @"";
    _imageViewStatusIcon.hidden = !hasLastSeenStatus;
    
    
    NSString * distanceText = [[STLocationManager sharedInstance] distanceStringToLocationWithLatitudeString:profile.latitude
                                                                                          andLongitudeString:profile.longitude];

    CGFloat fontSize = _lblDistance.font.pointSize;
    UIFont * statusFont = [UIFont fontWithName:@"ProximaNova-Regular" size:fontSize];
    UIFont * distanceFont = [UIFont fontWithName:@"ProximaNova-Semibold" size:fontSize];
    
    NSDictionary * statusDict = @{NSFontAttributeName : statusFont};
    NSDictionary * distanceDict = @{NSFontAttributeName : distanceFont};
    
    NSMutableAttributedString * text = [[NSMutableAttributedString alloc] initWithString:distanceText attributes:distanceDict];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:statusText attributes:statusDict]];
    _lblDistance.attributedText = text;
    
    _loadingPlaceholder.hidden = YES;
    
    _btnFollow.selected = profile.isFollowedByCurrentUser;
    [_btnFollowers setTitle:[NSString stringWithFormat:@"Followers %li", profile.followersCount] forState:UIControlStateNormal];
    [_btnFollowing setTitle:[NSString stringWithFormat:@"Following %li", profile.followingCount] forState:UIControlStateNormal];
    [_btnFollowersCount setTitle:[NSString stringWithFormat:@"%li", profile.followersCount] forState:UIControlStateNormal];
}

- (void)setStatusIconForStatus:(STUserStatus)userStatus {
    switch (userStatus) {
        case STUserStatusAway:
            _imageViewStatusIcon.image = [UIImage imageNamed:@"status_away"];
            break;
        case STUserStatusOffline:
            _imageViewStatusIcon.image = [UIImage imageNamed:@"status_offline"];
            break;
            
        case STUserStatusActive:
            _imageViewStatusIcon.image = [UIImage imageNamed:@"status_online"];
            break;
            
        default:
            _imageViewStatusIcon.image = nil;
            break;
    }
}

#pragma mark - IBActions
- (IBAction)onTapFollowing:(id)sender {
    STUsersListController * newVC = [STUsersListController newControllerWithUserId:_userId postID:nil andType:UsersListControllerTypeFollowing];
    [self.navigationController pushViewController:newVC animated:YES];
}
- (IBAction)onTapFollowers:(id)sender {
    STUsersListController * newVC = [STUsersListController newControllerWithUserId:_userId postID:nil andType:UsersListControllerTypeFollowers];
    [self.navigationController pushViewController:newVC animated:YES];
}

- (IBAction)onTapMessages:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
    STConversationsListViewController *viewController = (STConversationsListViewController *)[storyboard instantiateViewControllerWithIdentifier:@"STConversationsListViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
    
    
}

- (IBAction)onTapGallery:(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    STFlowTemplateViewController *flowCtrl = [storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = _isMyProfile ? STFlowTypeMyGallery : STFlowTypeUserGallery;
    flowCtrl.userID = _userId;
    flowCtrl.userName = _userProfile.fullName;
    
    [self.navigationController pushViewController:flowCtrl animated:YES];
}

- (IBAction)onTapMenu:(id)sender {
    [[STMenuController sharedInstance] showMenuForController:self];
}

- (IBAction)onTapNextProfile:(id)sender {
    
    if (!_isLaunchedFromNearbyController) {
        [self onTapGallery:nil];
        return;
    }
    
    if (_delegate) {
        if ([_delegate respondsToSelector:@selector(advanceToNextProfile)]) {
            [_delegate advanceToNextProfile];
        }
    }
}

- (IBAction)onTapFollowUser:(UIButton *)followBtn {
    
    __weak STUserProfileViewController * weakSelf = self;
    if (_userProfile.isFollowedByCurrentUser) {
        //unfollow user
        
        [STUnfollowUsersRequest unfollowUsers:@[@{@"uuid" : _userProfile.uuid}] withCompletion:^(id response, NSError *error) {
            weakSelf.btnFollow.selected = NO;
            weakSelf.userProfile.followersCount --;
            weakSelf.userProfile.isFollowedByCurrentUser = NO;
            [weakSelf setupVisualsWithProfile:weakSelf.userProfile];
        } failure:^(NSError *error) {

        }];
        
    } else {
        //follow user
        
        [STFollowUsersRequest followUsers:@[@{@"uuid" : _userProfile.uuid}] withCompletion:^(id response, NSError *error) {
            weakSelf.btnFollow.selected = YES;
            weakSelf.userProfile.followersCount ++;
            weakSelf.userProfile.isFollowedByCurrentUser = YES;
            [weakSelf setupVisualsWithProfile:weakSelf.userProfile];
        } failure:^(NSError *error) {
            
        }];
        
    }
}

- (IBAction)onTapCamera:(id)sender {
    __weak STUserProfileViewController *weakSelf = self;
    imagePickerCompletion completion = ^(UIImage *img, BOOL shouldCompressImage){
        [weakSelf startMoveScaleShareControllerForImage:img shouldCompress:shouldCompressImage editedPostId:nil captionString:nil];
        
    };
    
    if (_isMyProfile) {
        [[STImagePickerController sharedInstance] startImagePickerForOwnerInViewController:self withCompletion:completion];
    } else {
        [[STImagePickerController sharedInstance] startImagePickerInViewController:self.parentViewController withCompletion:completion andAskCompletion:^{
            [weakSelf inviteUserToUpload];
        }];
    }}

- (IBAction)onTapSettings:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STSettingsViewController * settingsCtrl = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([STSettingsViewController class])];
    UINavigationController   * setttingsNav = [[UINavigationController alloc] initWithRootViewController:settingsCtrl];
    [self presentViewController: setttingsNav animated:YES completion:nil];
}
- (IBAction)onTapSendMessageToUser:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
    STChatRoomViewController *viewController = (STChatRoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chat_room"];
    
    viewController.userInfo = [NSMutableDictionary dictionaryWithDictionary:@{@"user_id":_userId}];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)onTapEditUserProfile:(id)sender {
    STEditProfileViewController * editVC = [STEditProfileViewController newControllerWithUserId:_userId];
    editVC.userProfile = _userProfile;
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)startMoveScaleShareControllerForImage:(UIImage *)img
                               shouldCompress:(BOOL)compressing
                                 editedPostId:(NSString *)postId
                                captionString:(NSString *)captionString{
    
    // here, no compressing should be done, because it might be a cropping after this
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STMoveScaleViewController *viewController = (STMoveScaleViewController *)[storyboard instantiateViewControllerWithIdentifier:@"STMoveScaleViewController"];
    viewController.currentImg = img;
    
    
    viewController.delegate = (id<STSharePostDelegate>)[STMenuController sharedInstance].appMainController;
    viewController.editPostId = postId;
    viewController.shouldCompress = compressing;
    viewController.captionString = captionString;
    [self.navigationController pushViewController:viewController animated:NO];
}

- (void)inviteUserToUpload{
    
    NSString * name = [NSString stringWithFormat:@"%@", _userProfile.fullName];
    NSString * userId = [NSString stringWithFormat:@"%@", _userId];
    
    STRequestCompletionBlock completion = ^(id response, NSError *error){
        NSInteger statusCode = [response[@"status_code"] integerValue];
        if (statusCode ==STWebservicesSuccesCod || statusCode == STWebservicesFounded) {
            NSString *message = [NSString stringWithFormat:@"Congrats, you%@ asked %@ to take a photo.We'll announce you when his new photo is on STATUS.",statusCode == STWebservicesSuccesCod?@"":@" already", name];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil
                                                  cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }
    };
    [STInviteUserToUploadRequest inviteUserToUpload:userId withCompletion:completion failure:nil];
}

- (void)dealloc{
    self.delegate = nil;
}

@end
