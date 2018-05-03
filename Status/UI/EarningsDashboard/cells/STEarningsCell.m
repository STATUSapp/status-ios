//
//  STEarningsCell.m
//  Status
//
//  Created by Cosmin Andrus on 14/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STEarningsCell.h"
#import "STCommission.h"
#import "UIImageView+WebCache.h"

@interface STEarningsCell ()

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *productBrandNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commissionDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *commissionAmountLabel;
@property (weak, nonatomic) IBOutlet UIView *disabledOverlayView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusViewWidthConstr;
@property (weak, nonatomic) IBOutlet UILabel *commssionStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *commissionStatusView;

@end

@implementation STEarningsCell

-(void)prepareForReuse{
    _productImageView.layer.cornerRadius = 0.f;
    _productImageView.image = [UIImage imageNamed:@"Item image"];
}

-(void) configurCellWithCommissionObj:(STCommission *)commissionObj{
    __weak STEarningsCell *weakSelf = self;
    [_productImageView sd_setImageWithURL:[NSURL URLWithString:commissionObj.mainImageUrl] placeholderImage:[UIImage imageNamed:@"Item image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong STEarningsCell *strongSelf = weakSelf;
        strongSelf.productImageView.layer.cornerRadius = 3.f;
        strongSelf.productImageView.layer.masksToBounds = YES;
    }];
    _productNameLabel.text = commissionObj.productName;
    _productBrandNameLabel.text = commissionObj.productBrandName;
    NSDateFormatter *df = [NSDateFormatter new];
    df.dateFormat = @"dd/MM/yyyy";
    _commissionDateLabel.text = [df stringFromDate:commissionObj.commissionDate];
    NSNumberFormatter *nf = [NSNumberFormatter new];
    nf.maximumFractionDigits = 2;
    _commissionAmountLabel.text = [NSString stringWithFormat:@"$ %@", [nf stringFromNumber:commissionObj.commissionAmount]];
    if (commissionObj.commissionState == STCommissionStateNone) {
        _disabledOverlayView.hidden = YES;
        _statusViewWidthConstr.constant = 0.f;
    }
    else{
        _disabledOverlayView.hidden = NO;
        NSString *statusString = nil;
        UIColor *statusColor = nil;
        if (commissionObj.commissionState == STCommissionStatePaid) {
            statusColor = [UIColor colorWithRed:63.f/255.f
                                          green:215.f/255.f
                                           blue:70.f/255.f
                                          alpha:1.f];
            statusString = NSLocalizedString(@"Paid", nil);
        }
        else if (commissionObj.commissionState == STCommissionStateWithdrawn){
            statusColor = [UIColor colorWithRed:254.f/255.f
                                          green:89.f/255.f
                                           blue:0.f/255.f
                                          alpha:1.f];
            statusString = NSLocalizedString(@"Withdrawn", nil);
        }
        
        if (statusString) {
            UIFont *statusFont = [UIFont fontWithName:@"ProximaNova-Regular" size:13.f];
            CGSize statusStringSize = [statusString sizeWithAttributes:@{NSFontAttributeName:statusFont}];
            _commssionStatusLabel.text = statusString;
            _commssionStatusLabel.textColor = statusColor;
            _commissionStatusView.backgroundColor = statusColor;
            _commssionStatusLabel.font = statusFont;
            _commissionStatusView.layer.cornerRadius = 5.f;
            _statusViewWidthConstr.constant = ceilf(statusStringSize.width) + 11.f;
        }
        
    }
    
}

+(CGSize)cellSize{
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 108.f);
}

@end
