//
//  UserProfileInfoCell.m
//  Status
//
//  Created by Andrus Cosmin on 09/05/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "UserProfileInfoCell.h"
#import "STUserProfile.h"
#import "NSDate+Additions.h"
#import "STLocationManager.h"
#import "STFacebookLoginController.h"
#import "NSString+VersionComparison.h"
#import "UIImageView+WebCache.h"

CGFloat distanceLabelWidthPadding = 30.f;
CGFloat distanceLabelStandardHeight = 21.f;

@interface UserProfileInfoCell() 
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *messageEditButton;
@property (weak, nonatomic) IBOutlet UIButton *nameAndAgeButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *optionsButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editButtonConstraint;
@property (weak, nonatomic) IBOutlet UIButton *earningsButton;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

@end

@implementation UserProfileInfoCell

- (void)setBackButtonHidden:(BOOL)backButtonHidden{
    _backButton.hidden = backButtonHidden;
}

- (void)setSettingsButtonHidden:(BOOL)settingsButtonHidden{
    _settingsButton.hidden = settingsButtonHidden;
    _optionsButton.hidden = !settingsButtonHidden;
}

- (void)configureCellWithUserProfile:(STUserProfile *)profile{
    
    [_profileImageView sd_setImageWithURL:[NSURL URLWithString:profile.mainImageUrl] placeholderImage:[UIImage imageNamed:[profile genderImage]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            
        }
    }];
    
    if ([profile.uuid isEqualToString:[CoreManager loginService].currentUserUuid]) {
        _followButton.hidden = YES;
        [_messageEditButton setTitle:@"EDIT" forState:UIControlStateNormal];
        [_messageEditButton setTitle:@"EDIT" forState:UIControlStateHighlighted];
        _messageEditButton.enabled = YES;
        _editButtonConstraint.constant = 70.f;
        _earningsButton.hidden = !profile.isInfluencer;

    }
    else
    {
        _followButton.hidden = NO;
        _messageEditButton.enabled = NO;
        _messageEditButton.hidden = YES;
        _editButtonConstraint.constant = 0.f;
        _earningsButton.hidden = YES;

    }
    
    NSString *age = @"";
    if (profile.birthday) {
        age = [NSDate yearsFromDate:profile.birthday];
        
    }
    NSString *nameString = profile.fullName.length > 0?profile.fullName:profile.firstname;
    NSString *nameAndAgeString = [NSString stringWithFormat:@"%@%@%@",nameString,age.length>0?@", ":@"", age];
    [_nameAndAgeButton setTitle:nameAndAgeString forState:UIControlStateNormal];
    [_nameAndAgeButton setTitle:nameAndAgeString forState:UIControlStateHighlighted];
    
    if (!profile.isFollowedByCurrentUser) {
        [_followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
        [_followButton setTitle:@"FOLLOW" forState:UIControlStateHighlighted];
    }
    else
    {
        [_followButton setTitle:@"UNFOLLOW" forState:UIControlStateNormal];
        [_followButton setTitle:@"UNFOLLOW" forState:UIControlStateHighlighted];
    }
    
}

-(void)prepareForReuse{
    [super prepareForReuse];
    _profileImageView.image = nil;
}

+ (CGSize)cellSize{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    return CGSizeMake(screenSize.width, screenSize.width);
}

@end
