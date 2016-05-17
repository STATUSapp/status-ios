//
//  SmallFeedCell.m
//  Status
//
//  Created by Andrus Cosmin on 29/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "SmallFeedCell.h"

@interface SmallFeedCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation SmallFeedCell

-(void)setUpImage:(UIImage *)image{
    if (image!=nil) {
        _imageView.image = image;
        [_activityIndicator stopAnimating];
    }
    else
    {
        [_activityIndicator startAnimating];
        [_imageView setImage:[UIImage imageNamed:@"photo_placeholder"]];
    }
    
    [self.imageView.layer setCornerRadius:5.0];
    [self.imageView.layer setMasksToBounds:YES];
    self.imageView.clipsToBounds = YES;
    
//    self.backgroundColor = [UIColor clearColor];
//    self.layer.masksToBounds = NO;
//    self.layer.shadowColor = [UIColor blackColor].CGColor;
//    self.layer.shadowOffset = CGSizeMake(1,1);
//    self.layer.shadowOpacity = 0.3;
//    self.layer.shadowRadius = 2.0;
//    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.frame cornerRadius:2.0].CGPath;
}

@end
