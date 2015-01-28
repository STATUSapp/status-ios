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


@interface STUserProfileViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfilePicture;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBlurryPicture;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewLocationIcon;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewStatusIcon;
@property (weak, nonatomic) IBOutlet UILabel *lblNameAndAge;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblUserDescription;

@property (weak, nonatomic) IBOutlet UIButton *btnMessages;
@property (weak, nonatomic) IBOutlet UIButton *btnGallery;
@property (weak, nonatomic) IBOutlet UIButton *btnMenu;
@property (weak, nonatomic) IBOutlet UIButton *btnCamera;
@property (weak, nonatomic) IBOutlet UIButton *btnSettings;
@property (weak, nonatomic) IBOutlet UIButton *btnEditUserProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnNextProfile;
@property (weak, nonatomic) IBOutlet UIButton *btnSendMessageToUser;

@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSDictionary * userProfileDict;

@end

@implementation STUserProfileViewController

+ (STUserProfileViewController *)newControllerWithUserId:(NSString *)userId {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:[NSBundle mainBundle]];
    STUserProfileViewController * newController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([STUserProfileViewController class])];
    newController.userId = userId;
    
    return newController;
}

+ (STUserProfileViewController *)newControllerWithUserInfoDict:(NSDictionary *)userInfo {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"UserProfile" bundle:[NSBundle mainBundle]];
    STUserProfileViewController * newController = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([STUserProfileViewController class])];
    newController.userProfileDict = userInfo;
    newController.userId = userInfo[@"user_id"];
    
    return newController;
}

- (NSDictionary *)userProfileDict {
    return _userProfileDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getAndDisplayProfile];
    
    if (_isMyProfile) {
        _btnNextProfile.hidden = YES;
        _btnSettings.hidden = NO;
        _btnSendMessageToUser.hidden = YES;
        _btnEditUserProfile.hidden = NO;
    } else {
        _btnNextProfile.hidden = NO;
        _btnSettings.hidden = YES;
        _btnSendMessageToUser.hidden = NO;
        _btnEditUserProfile.hidden = YES;
    }
}

- (void)getAndDisplayProfile {
    __weak STUserProfileViewController * weakSelf = self;
    [STGetUserProfileRequest getProfileForUserID:_userId withCompletion:^(id response, NSError *error) {
        NSLog(@"%@", response);
        [weakSelf setupVisualsWithDictionary:response];
        weakSelf.userProfileDict = response;
        
    } failure:^(NSError *error) {
        // empty all fields
        NSLog(@"%@", error.debugDescription);
        
        [[[UIAlertView alloc] initWithTitle:@"Server Error" message:@"Something went wrong. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        
    }];
}

- (void)setupVisualsWithDictionary:(NSDictionary *)dict {
    
    if ([dict valueForKey:kFirstNameKey]  != [NSNull null]) {
        _lblNameAndAge.text = [dict valueForKey:kFirstNameKey];
    } else {
        _lblNameAndAge.text = [dict valueForKey:kFulNameKey];
    }
    
    if ([dict objectForKey:kBirthdayKey] != [NSNull null]) {
        NSString * age = [NSDate yearsFromDate:[NSDate dateFromServerDate:[dict objectForKey:kBirthdayKey]]];
        _lblNameAndAge.text = [NSString stringWithFormat:@"%@, %@", _lblNameAndAge.text, age];
    }
    
    _lblUserDescription.text = [STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kBioKey];
    _lblLocation.text = [STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kLocationKey];
    
    NSString * photoStringURL = [STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kProfilePhotoLinkKey];
    [_imageViewProfilePicture sd_setImageWithURL:[NSURL URLWithString:photoStringURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        _imageViewBlurryPicture.image = [image applyDarkEffect];
    }];
    
    NSDate * lastSeenDate = [NSDate dateFromServerDate:[STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kLastActiveKey]];
    _lblStatus.text = lastSeenDate ? [NSDate statusForLastTimeSeen:lastSeenDate] : @"";
    _imageViewStatusIcon.hidden = lastSeenDate ? NO : YES;
    [self setStatusIconForStatus:[NSDate statusTypeForLastTimeSeen:lastSeenDate]];
    
    _lblDistance.text = [[STLocationManager sharedInstance] distanceStringToLocationWithLatitudeString:[STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kLocationLatitudeKey]
                                                                                    andLongitudeString:[STUserProfileViewController getObjectFromUserProfileDict:dict forKey:kLocationLongitudeKey]];
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

+(id)getObjectFromUserProfileDict:(NSDictionary *)dict forKey:(NSString *)key {
    if ([dict objectForKey:key] != [NSNull null]) {
        return [dict objectForKey:key];
    }
    return nil;
}


#pragma mark - IBActions

- (IBAction)onTapMessages:(id)sender {
}

- (IBAction)onTapGallery:(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    STFlowTemplateViewController *flowCtrl = [storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = _isMyProfile ? STFlowTypeMyGallery : STFlowTypeUserGallery;
    flowCtrl.userID = _userId;
    flowCtrl.userName = [_userProfileDict valueForKey:kFulNameKey];
    
    [self.navigationController pushViewController:flowCtrl animated:YES];
}

- (IBAction)onTapMenu:(id)sender {
    [[STMenuController sharedInstance] showMenuForController:self];
}

- (IBAction)onTapNextProfile:(id)sender {
}

- (IBAction)onTapCamera:(id)sender {
}

- (IBAction)onTapSettings:(id)sender {
    [[STMenuController sharedInstance] goSettings];
}
- (IBAction)onTapSendMessageToUser:(id)sender {
}

- (IBAction)onTapEditUserProfile:(id)sender {
    STEditProfileViewController * editVC = [STEditProfileViewController newControllerWithUserId:_userId];
    editVC.userProfileDict = _userProfileDict;
    [self.navigationController pushViewController:editVC animated:YES];
}


@end
