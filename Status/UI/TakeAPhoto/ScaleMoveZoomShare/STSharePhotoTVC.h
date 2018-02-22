//
//  STSharePhotoTVC.h
//  Status
//
//  Created by Cosmin Andrus on 13/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSharePhotoHeader.h"

@class STPost;
@class STShopProduct;

@interface STSharePhotoTVC : UITableViewController

@property (nonatomic, strong) NSData *imgData;
@property (nonatomic, strong) STPost *post;
@property (nonatomic) STShareControllerType controllerType;

//public methods
-(NSData *)postImageData;
-(NSString *)postCaptionString;
-(NSArray<STShopProduct *> *)postShopProducts;
-(BOOL)postShouldBePostedOnFacebook;
@end
