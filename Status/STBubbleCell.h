//
//  STBubbleCell.h
//  Status
//
//  Created by Cosmin Andrus on 5/28/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STBubbleCell : UITableViewCell
+(float)cellHeightForText:(NSString *)message;
+(CGSize)sizeForText:(NSString *)message;
@end
