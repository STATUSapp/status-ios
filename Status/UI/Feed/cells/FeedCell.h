//
//  FeedCell.h
//  Status
//
//  Created by Cosmin Home on 06/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STPost;

extern CGFloat const kCaptionMargins;

@interface FeedCell : UICollectionViewCell

-(void)configureCellWithPost:(STPost *)post;

@end
