//
//  STCustomCollectionViewCell.h
//  Status
//
//  Created by silviu on 2/16/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCustomCollectionViewCell : UICollectionViewCell

- (void)setUpWithPicturesURLs:(NSArray *)urlArray;
- (void)setUpWithDictionary: (NSDictionary *)setupDict forFlowType: (int) flowType;

@end
