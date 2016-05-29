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
#import "UIImage+ImageEffects.h"
#import "UIImageView+WebCache.h"
#import "STLocationManager.h"
#import "STConstants.h"
#import "STImagePickerController.h"
#import "STConversationsListViewController.h"
#import "STChatRoomViewController.h"
#import "STMoveScaleViewController.h"
#import "STInviteUserToUploadRequest.h"
#import "STSettingsViewController.h"
#import "STUsersListController.h"
#import "STFacebookLoginController.h"

#import "STFollowUsersRequest.h"
#import "STUnfollowUsersRequest.h"

#import "STNativeAdsController.h"
#import "STNavigationService.h"

#import "STListUser.h"

#import "FeedCVC.h"

#import "UserProfileInfoCell.h"
#import "UserProfileFriendsInfoCell.h"
#import "UserProfileBioLocationCell.h"

typedef NS_ENUM(NSInteger, ProfileSection) {
    ProfileSectionInfo = 0,
    ProfileSectionFriendsInfo,
    ProfileSectionBioAndLocation,
    ProfileSectionCount,
};


//NSInteger const kTopLeftButtonTagBack = 11;
//NSInteger const kTopLeftButtonTagSettings = 12;

@interface STUserProfileViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *topLeftButton;
@property (weak, nonatomic) IBOutlet UIButton *topRightButton;


@property (nonatomic, strong) NSString * profileUserId;
@property (nonatomic, strong) STUserProfile * userProfile;
@property (nonatomic, assign) BOOL skipRefreshReqeust;

@end

@implementation STUserProfileViewController

+ (STUserProfileViewController *)newControllerWithUserId:(NSString *)userId {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:[NSBundle mainBundle]];
    STUserProfileViewController * newController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([STUserProfileViewController class])];
    newController.profileUserId = userId;
    
    return newController;
}


+ (STUserProfileViewController *)newControllerWithUserUserDataModel:(STUserProfile *)userProfile {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:[NSBundle mainBundle]];
    STUserProfileViewController * newController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([STUserProfileViewController class])];
    newController.userProfile = userProfile;
    newController.profileUserId = userProfile.uuid;
    newController.skipRefreshReqeust = YES;
    
    return newController;
}

-(void)setLoadingScreen:(BOOL)loading{
    if (loading == YES) {
        _collectionView.hidden = YES;
//        [self.view bringSubviewToFront:_backgroundImageView];
        _loadingSpinner.hidden = NO;
        [_loadingSpinner startAnimating];
//        [self.view bringSubviewToFront:_loadingSpinner];
    }
    else
    {
        _collectionView.hidden = NO;
        _loadingSpinner.hidden = YES;
        [_loadingSpinner stopAnimating];
//        [self.view sendSubviewToBack:_loadingSpinner];

        _backgroundImageView.image = [[STUIHelper splashImageWithLogo:NO] applyDarkEffect];
//        [self.view sendSubviewToBack:_backgroundImageView];

    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _backgroundImageView.image = [[STUIHelper splashImageWithLogo:NO] applyDarkEffect];

    if ([_profileUserId isEqualToString:[CoreManager loginService].currentUserUuid]) {
        _isMyProfile = YES;
    }
    
    _topLeftButton.hidden = _isMyProfile;
    _topRightButton.hidden = !_isMyProfile;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_skipRefreshReqeust) {
        _skipRefreshReqeust = NO;
        [self setupVisualsWithProfile:_userProfile];
    } else {
        [self getAndDisplayProfile];
    }
    [self.collectionView reloadData];
//    if (!_isLaunchedFromNearbyController) {
//        UISwipeGestureRecognizer * swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGallery:)];
//        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
//        [self.view addGestureRecognizer:swipeLeft];
//        
//        UISwipeGestureRecognizer * swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onBack)];
//        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
//        [self.view addGestureRecognizer:swipeRight];
//    }
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (STUserProfile *)userProfile {
    return _userProfile;
}

- (void)getAndDisplayProfile {
    
    [self setLoadingScreen:YES];
    
    if (_userProfile) {
        [self setupVisualsWithProfile:_userProfile];
    }    
    __weak STUserProfileViewController * weakSelf = self;
    [STGetUserProfileRequest getProfileForUserID:_profileUserId
                                  withCompletion:^(id response, NSError *error) {
        
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
    
    [self setLoadingScreen:profile==nil];
    
    [self.collectionView reloadData];
    
}

#pragma mark - UICollectionViewDelegates

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return ProfileSectionCount;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger numRows = 0;
    switch (section) {
        case ProfileSectionInfo:
        case ProfileSectionFriendsInfo:
        case ProfileSectionBioAndLocation:
            numRows = 1;
            break;
            
        default:
            break;
    }

    return numRows;
}

- (NSString *)identifierForIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = @"";
    switch (indexPath.section) {
        case ProfileSectionInfo:
            identifier = @"UserProfileInfoCell";
            break;
        case ProfileSectionFriendsInfo:
            identifier = @"UserProfileFriendsInfoCell";
            break;
        case ProfileSectionBioAndLocation:
            identifier = @"UserProfileBioLocationCell";
            break;

        default:
            break;
    }
    
    return identifier;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self identifierForIndexPath:indexPath] forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[UserProfileInfoCell class]]) {
        [((UserProfileInfoCell *)cell).profileImageView sd_setImageWithURL:[NSURL URLWithString:_userProfile.mainImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                _backgroundImageView.image = [image applyDarkEffect];
            }
            else
                _backgroundImageView.image = [[STUIHelper splashImageWithLogo:NO] applyDarkEffect];
        }];
        
        [(UserProfileInfoCell *)cell configureCellWithUserProfile:_userProfile];

    }
    else if ([cell isKindOfClass:[UserProfileFriendsInfoCell class]]){
        [(UserProfileFriendsInfoCell *)cell configureForProfile:_userProfile];
    }
    else if ([cell isKindOfClass:[UserProfileBioLocationCell class]]){
        [(UserProfileBioLocationCell *)cell configureCellForProfile:_userProfile];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == ProfileSectionInfo) {
        [self onTapGallery:nil];
    }
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize cellSize = CGSizeZero;
    CGFloat screenWidth = self.view.frame.size.width;

    switch (indexPath.section) {
        case ProfileSectionInfo:{

            cellSize = CGSizeMake(screenWidth, screenWidth);
    }
            break;
        case ProfileSectionFriendsInfo:{
            
            cellSize = CGSizeMake(screenWidth, [UserProfileFriendsInfoCell defaultCellHeight]);
        }

            break;
        case ProfileSectionBioAndLocation:{
            
            cellSize = CGSizeMake(screenWidth, [UserProfileBioLocationCell cellHeightForProfile:_userProfile]);
        }
    
        default:
            break;
    }
    
    return cellSize;
}


#pragma mark - IBActions

- (IBAction)onTapFollowing:(id)sender {
    STUsersListController * newVC = [STUsersListController newControllerWithUserId:_profileUserId
                                                                            postID:nil andType:UsersListControllerTypeFollowing];
    [self.navigationController pushViewController:newVC animated:YES];
}


- (IBAction)onTapBack:(id)sender {
    
    if (self.navigationController != nil) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
}


- (IBAction)onTapFollowers:(id)sender {
    STUsersListController * newVC = [STUsersListController newControllerWithUserId:_profileUserId
                                                                            postID:nil andType:UsersListControllerTypeFollowers];
    [self.navigationController pushViewController:newVC animated:YES];
}


- (IBAction)onTapGallery:(id)sender {
    
    FeedCVC *feedCVC = [FeedCVC galleryFeedControllerForUserId:_profileUserId andUserName:_userProfile.fullName];
    feedCVC.shouldAddBackButton = YES;
    [self.navigationController pushViewController:feedCVC animated:YES];
}


- (IBAction)onTapNextProfile:(id)sender {
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
            weakSelf.userProfile.followersCount --;
            weakSelf.userProfile.isFollowedByCurrentUser = NO;
            [weakSelf setupVisualsWithProfile:weakSelf.userProfile];
        } failure:^(NSError *error) {

        }];
        
    } else {
        //follow user
        
        [STFollowUsersRequest followUsers:@[@{@"uuid" : _userProfile.uuid}] withCompletion:^(id response, NSError *error) {
            weakSelf.userProfile.followersCount ++;
            weakSelf.userProfile.isFollowedByCurrentUser = YES;
            [weakSelf setupVisualsWithProfile:weakSelf.userProfile];
        } failure:^(NSError *error) {
            
        }];
        
    }
}

- (IBAction)onTapSettings:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STSettingsViewController * settingsCtrl = [storyboard instantiateViewControllerWithIdentifier: NSStringFromClass([STSettingsViewController class])];
    UINavigationController   * setttingsNav = [[UINavigationController alloc] initWithRootViewController:settingsCtrl];
    [self presentViewController: setttingsNav animated:YES completion:nil];
}
- (IBAction)onTapSendMessageToUser:(id)sender {
    //TODO: get user from the pool first and then initialize
    STListUser *lu = [STListUser new];
    lu.uuid = _profileUserId;
    //TODO: dev_1_2 add other properties if exists
    STChatRoomViewController *viewController = [STChatRoomViewController roomWithUser:lu];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)onMessageEditButtonPressed:(id)sender{
    if (_isMyProfile) {
        //go to Edit Profile
        [self onTapEditUserProfile:nil];
    }
    else
    {
        //go to Message to User
        [self onTapSendMessageToUser:nil];
        
    }
}

- (IBAction)onTapEditUserProfile:(id)sender {
    STEditProfileViewController * editVC = [STEditProfileViewController newControllerWithUserId:_profileUserId];
    editVC.userProfile = _userProfile;
    [self.navigationController pushViewController:editVC animated:YES];
}


- (void)inviteUserToUpload{
    
    NSString * name = [NSString stringWithFormat:@"%@", _userProfile.fullName];
    NSString * userId = [NSString stringWithFormat:@"%@", _profileUserId];
    
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
