//
//  SmallFeedCell.m
//  Status
//
//  Created by Andrus Cosmin on 29/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "SmallFeedCell.h"

@implementation SmallFeedCell

-(void)prepareForReuse{
    [_activityIndicator startAnimating];
    [_imageView setImage:[UIImage imageNamed:@"photo_placeholder"]];
}
@end
