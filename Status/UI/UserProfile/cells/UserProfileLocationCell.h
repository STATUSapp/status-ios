//
//  UserLocationCell.h
//  Status
//
//  Created by Cosmin Andrus on 01/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STUserProfile;
@interface UserProfileLocationCell : UICollectionViewCell
-(void)configureCellForProfile:(STUserProfile *)profile;
+ (CGSize)cellSizeForProfile:(STUserProfile *)profile;
@end
