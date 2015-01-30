//
//  STMoveScaleViewController.h
//  Status
//
//  Created by Andrus Cosmin on 02/09/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STSharePostDelegate <NSObject>

-(void)imageWasPosted;
-(void)imageWasEdited:(NSDictionary *)dict;

@end

@interface STMoveScaleViewController : UIViewController
@property (nonatomic, strong) UIImage *currentImg;
@property (nonatomic, strong) id <STSharePostDelegate>delegate;
@property (nonatomic, strong) NSString *editPostId;
@property (nonatomic, assign) BOOL shouldCompress;
@end
