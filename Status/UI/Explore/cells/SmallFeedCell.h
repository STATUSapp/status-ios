//
//  SmallFeedCell.h
//  Status
//
//  Created by Andrus Cosmin on 29/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmallFeedCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
