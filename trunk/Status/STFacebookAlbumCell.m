//
//  STFacebookAlbumCell.m
//  Status
//
//  Created by Andrus Cosmin on 18/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookAlbumCell.h"

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
}

@end
