//
//  STMoveScaleViewController.h
//  Status
//
//  Created by Andrus Cosmin on 02/09/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STSharePostDelegate <NSObject>

@optional

-(void)imageWasPostedWithPostId:(NSString *)postId;
-(void)imageWasEdited:(NSDictionary *)dict;
-(void)captionWasEditedForPost:(NSDictionary *)postDict withNewCaption:(NSString *)newCaption;

@end

@interface STMoveScaleViewController : UIViewController
@property (nonatomic, strong) UIImage *currentImg;
@property (nonatomic, strong) id <STSharePostDelegate>delegate;
@property (nonatomic, strong) NSString *editPostId;
@property (nonatomic, strong) NSString *captionString;
@property (nonatomic, assign) BOOL shouldCompress;

+ (instancetype)newControllerForImage:(UIImage *)img shouldCompress:(BOOL)compressing editedPostId:(NSString *)postId captionString:(NSString *)captionString delegate:(id<STSharePostDelegate>)delegate;

@end
