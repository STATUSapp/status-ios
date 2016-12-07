//
//  STConversationCell.h
//  Status
//
//  Created by Silviu on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STConversationUser;

@interface STConversationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
-(void)configureCellWithConversationUser:(STConversationUser *)cu;
@end
