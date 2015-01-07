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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getAndDisplayProfile];
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
    [_imageViewProfilePicture sd_setImageWithURL:[NSURL URLWithString:photoStringURL]];
}

+(id)getObjectFromUserProfileDict:(NSDictionary *)dict forKey:(NSString *)key {
    if ([dict objectForKey:key] != [NSNull null]) {
        return [dict objectForKey:key];
    }
    return nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBActions

- (IBAction)onTapMessages:(id)sender {
}

- (IBAction)onTapGallery:(id)sender {
}

- (IBAction)onTapMenu:(id)sender {
    [[STMenuController sharedInstance] showMenuForController:self];
}

- (IBAction)onTapCamera:(id)sender {
}

- (IBAction)onTapSettings:(id)sender {
}

- (IBAction)onTapEditUserProfile:(id)sender {
    STEditProfileViewController * editVC = [STEditProfileViewController newControllerWithUserId:_userId];
    editVC.userProfileDict = _userProfileDict;
    [self.navigationController pushViewController:editVC animated:YES];
}


@end
