//
//  STMoveScaleViewController.h
//  Status
//
//  Created by Andrus Cosmin on 02/09/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STPost;

@interface STMoveScaleViewController : UIViewController
@property (nonatomic, strong) UIImage *currentImg;
@property (nonatomic, strong) STPost *post;
@property (nonatomic, assign) BOOL shouldCompress;

+ (instancetype)newControllerForImage:(UIImage *)img shouldCompress:(BOOL)compressing andPost:(STPost *)post;

@end
