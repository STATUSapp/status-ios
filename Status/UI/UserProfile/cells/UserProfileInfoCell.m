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

CGFloat distanceLabelWidthPadding = 30.f;
CGFloat distanceLabelStandardHeight = 21.f;

@interface UserProfileInfoCell() 
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UIButton *nameAndAgeButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *distanceLabelWidthConstr;

@end

@implementation UserProfileInfoCell


- (void)configureCellWithUserProfile:(STUserProfile *)profile{
    
    if ([profile.uuid isEqualToString:[CoreManager loginService].currentUserUuid]) {
        _followButton.hidden = _messageButton.hidden = YES;
    }
    else
    {
        _followButton.hidden = _messageButton.hidden = NO;

    }
    
    NSString *age = @"";
    if (profile.birthday) {
        age = [NSDate yearsFromDate:profile.birthday];
        
    }
    NSString *nameString = profile.fullName.length > 0?profile.fullName:profile.firstname;
    NSString *nameAndAgeString = [NSString stringWithFormat:@"%@%@%@",nameString,age.length>0?@", ":@"", age];
    [_nameAndAgeButton setTitle:nameAndAgeString forState:UIControlStateNormal];
    [_nameAndAgeButton setTitle:nameAndAgeString forState:UIControlStateHighlighted];

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
    
    NSString * distanceText = [[CoreManager locationService] distanceStringToLocationWithLatitudeString:profile.latitude
                                                                                     andLongitudeString:profile.longitude];
    
    if ([distanceText isEqualToString:ST_UNKNOWN_DISTANCE_MESSAGE]) {
        distanceText = @"";
    }
    
    if (distanceText.length == 0) {
        statusText = hasLastSeenStatus ? [NSString stringWithFormat:@"%@", statusText] : @"";
    }else {
        statusText = hasLastSeenStatus ? [NSString stringWithFormat:@", %@", statusText] : @"";
    }
    _statusImageView.hidden = !hasLastSeenStatus;
    
    
    NSString *statusAndLocationString = [NSString stringWithFormat:@"%@%@", distanceText, statusText];
    
    _distanceLabel.text = statusAndLocationString;
    CGFloat maxWidth = self.contentView.frame.size.width - distanceLabelWidthPadding;
    NSDictionary *attributes = @{NSFontAttributeName : self.distanceLabel.font};
    CGRect rect = [statusAndLocationString boundingRectWithSize:CGSizeMake(maxWidth, distanceLabelStandardHeight)
                                                        options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                     attributes:attributes context:nil];
    _distanceLabelWidthConstr.constant = round(rect.size.width) + 2.f;
    
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

- (void)setStatusIconForStatus:(STUserStatus)userStatus {
    switch (userStatus) {
        case STUserStatusAway:
            _statusImageView.image = [UIImage imageNamed:@"status_away"];
            break;
        case STUserStatusOffline:
            _statusImageView.image = [UIImage imageNamed:@"status_offline"];
            break;
            
        case STUserStatusActive:
            _statusImageView.image = [UIImage imageNamed:@"status_online"];
            break;
            
        default:
            _statusImageView.image = nil;
            break;
    }
}


@end
