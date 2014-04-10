//
//  STTopOption.h
//  Status
//
//  Created by Andrus Cosmin on 09/03/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STConstants.h"

@interface STTopOption : UIView

-(void) initWithType:(STTopOptionType) type;
-(void) updateBasicInfo;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIImageView *currentUserImg;
@property (weak, nonatomic) IBOutlet UILabel *currentUserName;
@end
