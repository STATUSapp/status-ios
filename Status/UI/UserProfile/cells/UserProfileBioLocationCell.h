//
//  UserProfileBioLocationCell.h
//  Status
//
//  Created by Andrus Cosmin on 09/05/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STUserProfile;

@interface UserProfileBioLocationCell : UICollectionViewCell

-(void)configureCellForProfile:(STUserProfile *)profile;

+ (CGFloat)cellHeightForProfile:(STUserProfile *)profile;

@end
