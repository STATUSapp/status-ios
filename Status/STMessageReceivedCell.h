//
//  STMessageReceivedCell.h
//  Status
//
//  Created by Andrus Cosmin on 27/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STMessageReceivedCell : UITableViewCell

+(float)cellHeightForText:(NSString *)message;
-(void)configureCellWithMessage:(NSString *) message;
@end
