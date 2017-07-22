//
//  STEarningsTotalCell.h
//  Status
//
//  Created by Cosmin Andrus on 22/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STEarningsTotalCell : UICollectionViewCell

-(void)configureWithTotalAmount:(NSNumber *)totalAmount;
+(CGSize)cellSize;

@end
