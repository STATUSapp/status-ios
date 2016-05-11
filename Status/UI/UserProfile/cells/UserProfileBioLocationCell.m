//
//  UserProfileBioLocationCell.m
//  Status
//
//  Created by Andrus Cosmin on 09/05/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "UserProfileBioLocationCell.h"
#import "STUserProfile.h"

CGFloat const kCellHeightOffset = 50.f;
CGFloat const kBioLabelWidthOffset = 28.f;

@interface UserProfileBioLocationCell()

@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;

@end

@implementation UserProfileBioLocationCell

-(void)configureCellForProfile:(STUserProfile *)profile{
    if (profile.homeLocation == nil) {
        _locationLabel.text = @"N/A";
    }else {
        _locationLabel.text = profile.homeLocation;
    }

    if (profile.bio == nil) {
        profile.bio = @"";
    }
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSString *bioStr = profile.bio?:@"";
    NSAttributedString * bioString = [[NSAttributedString alloc] initWithString:bioStr
                                                                     attributes:@{NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Regular" size:14.0f],NSParagraphStyleAttributeName : paragraphStyle}];

    _bioLabel.attributedText = bioString;

}

+ (CGFloat)cellHeightForProfile:(STUserProfile *)profile{
    if (profile.bio == nil) {
        profile.bio = @"";
    }
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSString *bioStr = profile.bio?:@"";
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    NSAttributedString * bioString = [[NSAttributedString alloc] initWithString:bioStr
                                                                     attributes:@{NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Regular" size:14.0f],NSParagraphStyleAttributeName : paragraphStyle}];
    
    CGRect stringSize = [bioString boundingRectWithSize:CGSizeMake(screenRect.size.width - kBioLabelWidthOffset, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    
    return kCellHeightOffset + round(stringSize.size.height);

}

@end
