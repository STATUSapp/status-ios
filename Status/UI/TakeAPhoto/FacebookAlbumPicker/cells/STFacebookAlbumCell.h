//
//  STFacebookAlbumCell.h
//  Status
//
//  Created by Andrus Cosmin on 18/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STFacebookAlbumCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *albumTitleLbl;
@property (weak, nonatomic) IBOutlet UILabel *albumPhotoNumberLbl;
@property (weak, nonatomic) IBOutlet UIImageView *albumImageView;


-(void)configureCellWithALbum:(NSDictionary *)album;
@end
