//
//  UserProfileInfoCell.h
//  Status
//
//  Created by Andrus Cosmin on 09/05/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STUserProfile;

@interface UserProfileInfoCell : UICollectionViewCell

- (void)configureCellWithUserProfile:(STUserProfile *)profile;

+ (CGSize)cellSize;
@end
