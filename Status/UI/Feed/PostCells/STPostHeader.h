//
//  STPostHeader.h
//  Status
//
//  Created by Cosmin Andrus on 11/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STPost;

@interface STPostHeader : UICollectionReusableView

- (void)configureCellWithPost:(STPost *)post;
- (void)configureForSection:(NSInteger)sectionIndex;
+ (CGSize)headerSize;

@end
