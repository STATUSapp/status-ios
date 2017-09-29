//
//  STBarcodeProductNotIndexedViewController.h
//  Status
//
//  Created by Cosmin Andrus on 25/09/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STProductNotIndexedProtocol <NSObject>

-(void)viewDidCancel;
-(void)viewDidSendInfoWithBrandName:(NSString *)brandName
                        productName:(NSString *)productName
                         productURK:(NSString *)productURL;

@end

@interface STMissingProductViewController : UIViewController

@property (nonatomic, weak) id<STProductNotIndexedProtocol>delegate;

@end
