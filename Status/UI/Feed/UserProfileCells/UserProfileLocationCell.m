//
//  UserLocationCell.m
//  Status
//
//  Created by Cosmin Andrus on 01/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "UserProfileLocationCell.h"
#import "STUserProfile.h"

@interface UserProfileLocationCell ()

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locationPin;

@end

@implementation UserProfileLocationCell

-(void)configureCellForProfile:(STUserProfile *)profile{
    if (profile.homeLocation == nil ||
        profile.homeLocation.length == 0) {
        _locationLabel.text = @"";
        _locationPin.hidden = YES;
    }else {
        _locationLabel.text = profile.homeLocation;
        _locationPin.hidden = NO;
    }
}

+ (CGSize)cellSizeForProfile:(STUserProfile *)profile{
    if (profile.homeLocation == nil) {
        profile.homeLocation = @"";
    }
    
    if (profile.homeLocation.length == 0) {
        return CGSizeZero;
    }
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    return CGSizeMake(screenRect.size.width, 36.f);
}

@end
