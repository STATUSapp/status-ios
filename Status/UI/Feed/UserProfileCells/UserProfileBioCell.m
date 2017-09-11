//
//  UserProfileBioLocationCell.m
//  Status
//
//  Created by Andrus Cosmin on 09/05/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "UserProfileBioCell.h"
#import "STUserProfile.h"

CGFloat const kCellHeightOffset = 8.f;
CGFloat const kBioLabelWidthOffset = 28.f;

@interface UserProfileBioCell()

@property (weak, nonatomic) IBOutlet UILabel *bioLabel;

@end

@implementation UserProfileBioCell

-(void)configureCellForProfile:(STUserProfile *)profile{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSString *bioStr = profile.bio;
    NSAttributedString * bioString = [[NSMutableAttributedString alloc] initWithString:@""];
    if (bioStr) {
        bioString = [[NSAttributedString alloc] initWithString:bioStr
                                                    attributes:@{NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Regular" size:14.0f],NSParagraphStyleAttributeName : paragraphStyle}];
    }

    _bioLabel.attributedText = bioString;

}

+ (CGSize)cellSizeForProfile:(STUserProfile *)profile{
    if (profile.bio == nil) {
        profile.bio = @"";
    }
    
    if (profile.bio.length == 0) {
        return CGSizeZero;
    }
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 3;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    NSString *bioStr = profile.bio?:@"";
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];

    NSAttributedString * bioString = [[NSAttributedString alloc] initWithString:bioStr
                                                                     attributes:@{NSFontAttributeName : [UIFont fontWithName:@"ProximaNova-Regular" size:14.0f],NSParagraphStyleAttributeName : paragraphStyle}];
    
    CGRect stringSize = [bioString boundingRectWithSize:CGSizeMake(screenRect.size.width - kBioLabelWidthOffset, CGFLOAT_MAX) options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading) context:nil];
    
    
    return CGSizeMake(screenSize.width, kCellHeightOffset + round(stringSize.size.height));

}

@end
