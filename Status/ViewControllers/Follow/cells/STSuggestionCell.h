//
//  STSuggestionCell.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STSuggestedUser;

@interface STSuggestionCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *followButton;

-(void)configureCellWithSuggestedUser:(STSuggestedUser *)su;
+(CGFloat)cellHeight;

@end
