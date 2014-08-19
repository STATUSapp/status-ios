//
//  STAlbumImageCell.m
//  Status
//
//  Created by Andrus Cosmin on 19/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STAlbumImageCell.h"

@implementation STAlbumImageCell

-(void)prepareForReuse{
    _albumImageView.image = [UIImage imageNamed:@"placeholder imagine like screen"];
}
@end
