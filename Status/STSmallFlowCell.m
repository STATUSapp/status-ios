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
    [[STImageCacheController sharedInstance] loadPostImageWithName:ft.url withPostCompletion:^(UIImage *img) {
        
        if (img!=nil)
            _imageView.image = img;
    } andBlurCompletion:nil];
}
+(CGSize)cellSize{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat tileWidth = (screenRect.size.width - 60.f)/2;
    return CGSizeMake(tileWidth, tileWidth);
}
@end
