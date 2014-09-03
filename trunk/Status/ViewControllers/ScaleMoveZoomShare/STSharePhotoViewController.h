//
//  STSharePhotoViewController.h
//  Status
//
//  Created by Andrus Cosmin on 23/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMoveScaleViewController.h"

@interface STSharePhotoViewController : UIViewController
@property (nonatomic, strong) NSData *imgData;
@property (nonatomic, strong) NSData *bluredImgData;
@property (nonatomic, weak) id <STSharePostDelegate> delegate;
@property (nonatomic, strong) NSString *editPostId;
@end
