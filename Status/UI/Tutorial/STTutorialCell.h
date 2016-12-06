//
//  STTutorialCell.h
//  Status
//
//  Created by Silviu on 01/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STTutorialModel;

@interface STTutorialCell : UICollectionViewCell

- (void)configureWithModel:(STTutorialModel *)model;

@end
