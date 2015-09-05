//
//  STSmallFlowCell.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/07/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STFlowTemplate;

@interface STSmallFlowCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
-(void)configureCellWithFlorTemplate:(STFlowTemplate *)ft;
+(CGSize)cellSize;
@end
