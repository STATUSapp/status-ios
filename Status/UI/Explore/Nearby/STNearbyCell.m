//
//  STNearbyCell.m
//  Status
//
//  Created by Cosmin Andrus on 01/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STNearbyCell.h"
#import "STUserProfile.h"
#import "UIImageView+WebCache.h"
#import "NSDate+Additions.h"

CGFloat const kMarginsOffset = 24.f;//right + left + distance between items
CGFloat const kBottomHeightConstraint = 47.f;
CGFloat const kMessageBottomWidth = 37.f;

@interface STNearbyCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *profileName;
//@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameLeftContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nameWidthConstraint;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@end

@implementation STNearbyCell

-(void)prepareForReuse{
    [_profileImage sd_cancelCurrentAnimationImagesLoad];
    _profileImage.image = nil;
    _profileName.text = @"";
}
- (void)configureCellWithUserProfile:(STUserProfile *)userProfile{
    
    [_profileImage sd_setImageWithURL:[NSURL URLWithString:userProfile.mainImageUrl] placeholderImage:[UIImage imageNamed:[userProfile genderImage]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //TODO: CA - add the placeholders when needed
    }];
    
    NSString *age = @"";
    if (userProfile.birthday) {
        age = [NSDate yearsFromDate:userProfile.birthday];
        
    }
    NSString *nameString = [[userProfile.fullName componentsSeparatedByString:@" "] firstObject];
    NSString *nameAndAgeString = [NSString stringWithFormat:@"%@%@%@",nameString,age.length>0?@", ":@"", age];

    CGSize cellSize = [STNearbyCell cellSizeForProfile:userProfile];
    CGRect paragraphRect = [nameAndAgeString boundingRectWithSize:CGSizeMake(cellSize.width - kMessageBottomWidth, CGFLOAT_MAX)
                                                          options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName:_profileName.font} context:nil];

    _nameWidthConstraint.constant = roundf(paragraphRect.size.width) + 1.f;
    if (paragraphRect.size.width + kMessageBottomWidth < cellSize.width) {
        _nameLeftContraint.constant = (cellSize.width - paragraphRect.size.width - kMessageBottomWidth) / 2.f;
    }
    else
        _nameLeftContraint.constant = 0.f;
    
    _profileName.text = nameAndAgeString;
    
    self.layer.cornerRadius = 5.0f;
    self.layer.borderWidth = 1.0f;
    UIColor *borderColor = [UIColor colorWithRed:211.f/255.f
                                          green:211.f/255.f
                                           blue:211.f/255.f
                                          alpha:1.f];
    self.layer.borderColor = borderColor.CGColor;
    self.layer.masksToBounds = YES;
}

- (void)configureWithIndexPath:(NSIndexPath *)indexPath{
//    _messageButton.tag = indexPath.row;
}

+ (CGSize ) cellSizeForProfile:(STUserProfile *)profile{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGFloat width = (screenSize.width - kMarginsOffset ) / 2.f;

    if (CGSizeEqualToSize(profile.imageSize, CGSizeZero)) {
        return CGSizeMake(width, width + kBottomHeightConstraint);
    }
    else
    {
        CGSize imageSize = profile.imageSize;
        CGFloat ratio = imageSize.height / imageSize.width;
        return CGSizeMake(width, roundf(width * ratio + kBottomHeightConstraint));
    }
}

@end
