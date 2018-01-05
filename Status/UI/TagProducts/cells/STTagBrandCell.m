//
//  STTagBrandCell.m
//  Status
//
//  Created by Cosmin Andrus on 29/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagBrandCell.h"

@implementation STTagBrandCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse{
    [super prepareForReuse];
    _nameLabel.textColor = [UIColor blackColor];
}

-(void)setNoBrandFound{
    _nameLabel.text = NSLocalizedString(@"No brand found", nil);
    _nameLabel.textColor = [UIColor colorWithRed:148.f/255.f
                                           green:148.f/255.f
                                            blue:148.f/255.f
                                           alpha:1.f];
    _nameLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:16.f];
    _separatorView.hidden = NO;

}
@end
