//
//  STMessageSendCell.h
//  Status
//
//  Created by Andrus Cosmin on 27/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STBubbleCell.h"

@interface STMessageSendCell : STBubbleCell
-(void)configureCellWithMessage:(NSString *) message andDateStr:(NSString *) dateStr;
-(void)configureCellWithMessage:(Message *) message;
@end
