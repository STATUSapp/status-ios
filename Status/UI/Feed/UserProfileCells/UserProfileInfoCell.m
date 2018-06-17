//
//  UserProfileInfoCell.m
//  Status
//
//  Created by Andrus Cosmin on 09/05/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "UserProfileInfoCell.h"
#import "NSDate+Additions.h"
#import "STLocationManager.h"
#import "STLoginService.h"
#import "NSString+VersionComparison.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Mask.h"

@interface UserProfileInfoCell() 
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

@end

@implementation UserProfileInfoCell

- (void)configureCellWithUserProfile:(STUserProfile *)profile{
    
    __weak UserProfileInfoCell *weakSelf = self;
    [_profileImageView sd_setImageWithURL:[NSURL URLWithString:profile.mainImageUrl] placeholderImage:[UIImage imageNamed:[profile genderImage]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            __strong UserProfileInfoCell *strongSelf = weakSelf;
            [strongSelf.profileImageView maskImage:image];
        }
    }];
    STProfileButtonTag buttonTag = 0;    
    if ([profile.uuid isEqualToString:[[CoreManager loginService] currentUserUuid]]) {
        buttonTag = STProfileButtonTagEdit;
    }else{
        if (profile.isFollowedByCurrentUser) {
            buttonTag = STProfileButtonTagFollowing;
        }else{
            buttonTag = STProfileButtonTagFollow;
        }
    }
    [self setProfileButtonForTag:buttonTag];
}

-(void)setProfileButtonForTag:(STProfileButtonTag)tag{
    _bottomButton.tag = tag;
    NSString *imageName = nil;
    NSString *pressedImageName = nil;
    switch (tag) {
        case STProfileButtonTagEdit:
            imageName = @"profile_edit";
            pressedImageName = @"profile_edit_pressed";
            break;
        case STProfileButtonTagFollow:
            imageName = @"profile_follow";
            break;
        case STProfileButtonTagFollowing:
            imageName = @"profile_following";
            break;

        default:
            break;
    }
    UIImage *image = [UIImage imageNamed:imageName];
    [_bottomButton setImage:image forState:UIControlStateNormal];
    if (pressedImageName) {
        UIImage *pressedImage = [UIImage imageNamed:pressedImageName];
        [_bottomButton setImage:pressedImage forState:UIControlStateHighlighted];
    }else{
        [_bottomButton setImage:nil forState:UIControlStateHighlighted];
    }
}

-(void)prepareForReuse{
    [super prepareForReuse];
    [_profileImageView sd_cancelCurrentAnimationImagesLoad];
    _profileImageView.image = nil;
}

+ (CGSize)cellSize{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    return CGSizeMake(screenSize.width, 253.f);
}

@end
