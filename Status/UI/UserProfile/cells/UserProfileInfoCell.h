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

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;

- (void)configureCellWithUserProfile:(STUserProfile *)profile;

- (void)setBackButtonHidden:(BOOL)backButtonHidden;

- (void)setSettingsButtonHidden:(BOOL)settingsButtonHidden;

+ (CGSize)cellSize;
@end
