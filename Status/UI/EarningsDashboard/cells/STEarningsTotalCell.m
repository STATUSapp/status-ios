//
//  STEarningsTotalCell.m
//  Status
//
//  Created by Cosmin Andrus on 22/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STEarningsTotalCell.h"

@interface STEarningsTotalCell ()
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;

@end

@implementation STEarningsTotalCell

-(void)configureWithTotalAmount:(NSNumber *)totalAmount{
    NSNumberFormatter *nf = [NSNumberFormatter new];
    nf.maximumFractionDigits = 2;
    _totalAmountLabel.text = [NSString stringWithFormat:@"$ %@", [nf stringFromNumber:totalAmount]];

}

+(CGSize)cellSize{
    return CGSizeMake([[UIScreen mainScreen] bounds].size.width, 40.f);
}

@end
