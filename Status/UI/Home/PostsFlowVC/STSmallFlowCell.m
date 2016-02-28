//
//  STSmallFlowCell.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/07/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STSmallFlowCell.h"
#import "STDataModelObjects.h"
#import "STImageCacheController.h"

@implementation STSmallFlowCell
-(void)configureCellWithFlorTemplate:(STFlowTemplate *)ft{
    CGRect rect = self.contentView.frame;
    rect.size = [STSmallFlowCell cellSize];
    self.contentView.frame = rect;
    
    _nameLabel.text = [ft displayedName];
    if (![ft.url isKindOfClass:[NSNull class]]) {
        [[STImageCacheController sharedInstance] loadPostImageWithName:ft.url withPostCompletion:^(UIImage *img) {
            
            if (img!=nil)
                _imageView.image = img;
        } andBlurCompletion:nil];
    }
    else
        _imageView.image = [UIImage imageNamed:@"Nearby-placeholder"];

}
+(CGSize)cellSize{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tileWidth = (screenRect.size.width - 60.f)/2;
    return CGSizeMake(tileWidth, tileWidth);
}
-(void)setHighlighted:(BOOL)highlighted{
    if (highlighted == YES) {
        _nameLabel.alpha = 0.8f;
        if ([_imageView.image isEqual:[UIImage imageNamed:@"Nearby-placeholder"]]) {
            _imageView.alpha = 0.8f;
        }
        else
            _selectedImageView.hidden = NO;
    }
    else
    {
        _nameLabel.alpha = 1.f;
        _selectedImageView.hidden = YES;
        _imageView.alpha = 1.f;
    }
}
@end
