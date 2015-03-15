//
//  STSharePhotoViewController.h
//  Status
//
//  Created by Andrus Cosmin on 23/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STSharePhotoDelegate <NSObject>

-(void)imageWasPosted;

@end

@interface STSharePhotoViewController : UIViewController
@property (nonatomic, strong) NSData *imgData;
@property (nonatomic, weak) id <STSharePhotoDelegate> delegate;
@end
