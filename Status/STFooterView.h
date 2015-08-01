//
//  STFooterView.h
//  Status
//
//  Created by Cosmin Andrus on 4/15/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STFooterView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIImageView *bkImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
-(void)configureFooterWithBkImage:(UIImage *)image;
-(void)showOnlyBackground;
@end
