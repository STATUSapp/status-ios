//
//  STAlbumImagesViewController.h
//  Status
//
//  Created by Andrus Cosmin on 19/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STWhiteNavBarViewController.h"

@interface STAlbumImagesViewController : STWhiteNavBarViewController
@property (nonatomic, strong) NSString *albumId;
@property (nonatomic, strong) NSString *albumTitle;

+ (STAlbumImagesViewController *)newController;
@end
