//
//  UserProfileFriendsInfoCell.m
//  Status
//
//  Created by Andrus Cosmin on 09/05/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "UserProfileFriendsInfoCell.h"
#import "STUserProfile.h"

CGFloat const kDefaultCellHeight = 56.f;

@interface UserProfileFriendsInfoCell() 
@property (weak, nonatomic) IBOutlet UILabel *followersLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingLabel;
@property (weak, nonatomic) IBOutlet UILabel *postsLabel;

@end

@implementation UserProfileFriendsInfoCell

-(void)configureForProfile:(STUserProfile *)profile{
    
    [_postsLabel setText:[NSString stringWithFormat:@"%li", (long)profile.numberOfPosts]];
    [_followersLabel setText:[NSString stringWithFormat:@"%li", (long)profile.followersCount]];
    [_followingLabel setText:[NSString stringWithFormat:@"%li", (long)profile.followingCount]];
}

+ (CGSize)cellSize{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    return CGSizeMake(screenSize.width, kDefaultCellHeight);
}
@end
