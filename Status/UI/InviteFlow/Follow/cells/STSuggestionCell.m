//
//  STSuggestionCell.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STSuggestionCell.h"
#import "STSuggestedUser.h"

@interface STSuggestionCell ()

@property (weak, nonatomic) IBOutlet UIImageView *divider;
@end

@implementation STSuggestionCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    _userImageView.layer.cornerRadius = _userImageView.frame.size.width / 2;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithSuggestedUser:(STSuggestedUser *)su isLastInSection:(BOOL)lastInSection{
    _followButton.selected = [su.followedByCurrentUser boolValue];
    _userNameLabel.text = su.userName;
    _divider.hidden = lastInSection;
}

+(CGFloat)cellHeight{
    return 80.f;
}

@end
