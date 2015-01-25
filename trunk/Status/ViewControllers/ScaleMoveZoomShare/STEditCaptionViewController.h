//
//  STEditCaptionViewController.h
//  Status
//
//  Created by Cosmin Andrus on 25/01/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STMoveScaleViewController.h"

@protocol STEditCaptionDelegate <NSObject>

-(void)captionWasEditedForPost:(NSDictionary *)postDict withNewCaption:(NSString *)newCaption;

@end

@interface STEditCaptionViewController : UIViewController
@property (nonatomic, strong) NSDictionary *postDict;
@property (nonatomic, weak) id <STEditCaptionDelegate> delegate;
@property (nonatomic, weak) id <STSharePostDelegate> postDelegate;
@property(nonatomic, strong) NSData *imageData;
@property(nonatomic, strong) NSData *blurredImageData;
@end
