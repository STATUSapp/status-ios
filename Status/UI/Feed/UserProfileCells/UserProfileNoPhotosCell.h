//
//  UserProfileNoPhotosCell.h
//  Status
//
//  Created by Cosmin Andrus on 01/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserProfileNoPhotosCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *uploadPhotoButton;
+ (CGSize)cellSizeForNumberOfPhotos:(NSInteger)itemsCount;
@end
