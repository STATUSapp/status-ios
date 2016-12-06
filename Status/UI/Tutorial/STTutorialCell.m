//
//  STTutorialCell.m
//  Status
//
//  Created by Silviu on 01/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STTutorialCell.h"
#import "STTutorialModel.h"

CGFloat const kDefaultSubtitleLineHeight = 14.f;

@interface STTutorialCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLable;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleHeightConstraint;
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;

@end

@implementation STTutorialCell

- (void)configureWithModel:(STTutorialModel *)model{
    _titleLable.text = model.title;
    _subtitleLabel.text = model.subtitle;
    NSInteger numberOfRequiredLines = [[model.subtitle componentsSeparatedByString:@"\n"] count] + 1;
    _subtitleHeightConstraint.constant = kDefaultSubtitleLineHeight * numberOfRequiredLines;
    _tutorialImageView.image = [UIImage imageNamed:model.imageName];
    
    [self setNeedsLayout];
}

@end
