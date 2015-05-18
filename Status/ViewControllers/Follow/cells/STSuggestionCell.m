//
//  STSuggestionCell.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STSuggestionCell.h"
#import "STSuggestedUser.h"

@implementation STSuggestionCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithSuggestedUser:(STSuggestedUser *)su{
    _followButton.selected = su.followedByCurrentUser;
    _userNameLabel.text = su.userName;
}

+(CGFloat)cellHeight{
    return 80.f;
}

@end
