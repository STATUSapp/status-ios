//
//  STNearbyCell.h
//  Status
//
//  Created by Cosmin Andrus on 01/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STUserProfile;

@interface STNearbyCell : UICollectionViewCell

- (void)configureCellWithUserProfile:(STUserProfile *)userProfile;
- (void)configureWithIndexPath:(NSIndexPath *)indexPath;

+ (CGSize ) cellSizeForProfile:(STUserProfile *)profile;

@end
