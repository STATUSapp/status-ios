//
//  STTopHeaderCell.h
//  Status
//
//  Created by Cosmin Andrus on 17/07/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STPost;
@interface STTopHeaderCell : UICollectionViewCell

- (void)configureWithPosts:(NSArray <STPost *> *)posts
                     topId:(NSString *)topId;
+ (CGSize)cellSize;

@end
