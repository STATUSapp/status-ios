//
//  STEarningsCell.h
//  Status
//
//  Created by Cosmin Andrus on 14/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STCommission;

@interface STEarningsCell : UICollectionViewCell

-(void) configurCellWithCommissionObj:(STCommission *)commissionObj;

@end
