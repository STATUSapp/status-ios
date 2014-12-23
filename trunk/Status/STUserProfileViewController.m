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

static NSString * const kBirthdayKey = @"birthday";
static NSString * const kFirstNameKey = @"firstname";
static NSString * const kFulNameKey = @"fullname";
static NSString * const kLastActiveKey = @"last_seen";
static NSString * const kLastNameKey = @"lastname";
static NSString * const kLocationKey = @"location";
static NSString * const kLocationLatitudeKey = @"location_lat";
static NSString * const kLocationLongitudeKey = @"location_lng";
static NSString * const kNumberOfPostsKey = @"number_of_posts";
static NSString * const kProfilePhotoLinkKey = @"user_photo";

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
    
    __weak STUserProfileViewController * weakSelf = self;
    
    [STGetUserProfileRequest getProfileForUserID:_userId withCompletion:^(id response, NSError *error) {
        NSLog(@"%@", response);
        [weakSelf setupVisualsWithDictionary:response];

        
    } failure:^(NSError *error) {
        // empty all fields
        NSLog(@"%@", error.debugDescription);
    }];
    
}

- (void)setupVisualsWithDictionary:(NSDictionary *)dict {
    
#warning solve NSNull case another way. Talk to server guy
    
    if (![[dict valueForKey:kFirstNameKey]  isEqual:[NSNull null]]) {
        _lblNameAndAge.text = [dict valueForKey:kFirstNameKey];
    } else {
        _lblNameAndAge.text = [dict valueForKey:kFulNameKey];
    }
    
    if (![[dict objectForKey:kBirthdayKey] isEqual:[NSNull null]]) {
        NSString * age = [NSDate yearsFromDate:[NSDate dateFromServerDate:[dict objectForKey:kBirthdayKey]]];
        _lblNameAndAge.text = [NSString stringWithFormat:@"%@, %@", _lblNameAndAge.text, age];
    }
    
    

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
}

- (IBAction)onTapCamera:(id)sender {
}

- (IBAction)onTapSettings:(id)sender {
}

- (IBAction)onTapEditUserProfile:(id)sender {
}


@end
