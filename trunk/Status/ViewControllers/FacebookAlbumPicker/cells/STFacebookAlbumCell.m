//
//  STFacebookAlbumCell.m
//  Status
//
//  Created by Andrus Cosmin on 18/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookAlbumCell.h"
#import "STImageCacheController.h"

@implementation STFacebookAlbumCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)configureCellWithALbum:(NSDictionary *)album{
    _albumTitleLbl.text = album[@"name"];
    _albumPhotoNumberLbl.text = [NSString stringWithFormat:@"%ld photos", (long)[album[@"count"] integerValue]];
    __weak STFacebookAlbumCell *weakSelf = self;
    [[STImageCacheController sharedInstance] loadFBCoverPictureForAlbum:album andCompletion:^(UIImage *img) {
        weakSelf.albumImageView.image = img;
    }];
    
}

-(void)prepareForReuse{
    _albumTitleLbl.text = _albumPhotoNumberLbl.text = @"";
    _albumImageView.image = [UIImage imageNamed:@"placeholder imagine like screen"];
}

@end
