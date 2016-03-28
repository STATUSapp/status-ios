//
//  STSharePhotoViewController.h
//  Status
//
//  Created by Andrus Cosmin on 23/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMoveScaleViewController.h"

@class STPost;

typedef NS_ENUM(NSUInteger,STShareControllerType){
    STShareControllerNotDefined = 0,
    STShareControllerAddPost,
    STShareControllerEditPost,
    STShareControllerEditCaption
};
@interface STSharePhotoViewController : UIViewController
@property (nonatomic, strong) NSData *imgData;
@property (nonatomic, strong) NSData *bluredImgData;
@property (nonatomic, strong) STPost *post;
@property (nonatomic) STShareControllerType controllerType;
@end
