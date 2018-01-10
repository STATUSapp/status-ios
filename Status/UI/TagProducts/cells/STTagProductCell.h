//
//  STTagProductCell.h
//  Status
//
//  Created by Cosmin Andrus on 05/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DGActivityIndicatorView.h"

@interface STTagProductCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet DGActivityIndicatorView *loadingView;

@end
