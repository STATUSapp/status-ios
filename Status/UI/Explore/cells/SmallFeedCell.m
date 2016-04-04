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

-(void)layoutSubviews{
    [super layoutSubviews];
//    self.layer.cornerRadius = 3.0f;
//    self.layer.borderWidth = 1.0f;
//    self.layer.borderColor = [UIColor clearColor].CGColor;
//    self.layer.masksToBounds = YES;
//    
//    self.layer.shadowColor = [[UIColor colorWithRed:255.f green:255.f blue:255.f alpha:1.f] CGColor];
//    self.layer.shadowOffset = CGSizeMake(0, 9.0f);
//    self.layer.shadowRadius = 2.0f;
//    self.layer.shadowOpacity = 0.5f;
//    self.layer.masksToBounds = NO;
//    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;

}
@end
