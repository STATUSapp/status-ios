//
//  UICollectionViewCell+Additions.m
//  Status
//
//  Created by Cosmin Andrus on 04/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "UICollectionViewCell+Additions.h"

@implementation UICollectionViewCell (Additions)

+(CGSize)acceptedSizeFromSize:(CGSize)size{
    if (size.width < 0 ||
        size.height < 0) {
        return CGSizeZero;
    }
    return size;
}

@end
