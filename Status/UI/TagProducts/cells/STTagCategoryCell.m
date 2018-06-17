//
//  STTagCategoryCell.m
//  Status
//
//  Created by Cosmin Andrus on 01/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagCategoryCell.h"
#import "UIImageView+WebCache.h"

@implementation STTagCategoryCell
-(void)prepareForReuse{
    [super prepareForReuse];
    [_categoryImage sd_cancelCurrentAnimationImagesLoad];
}
@end
