//
//  STBarcodeScannerViewController.h
//  Status
//
//  Created by Cosmin Andrus on 17/09/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STBarcodeScannerProtocol <NSObject>

-(void)barcodeScannerDidScanCode:(NSString *)barcode;

@end

@interface STBarcodeScannerViewController : UIViewController

@property (nonatomic, weak) id<STBarcodeScannerProtocol>delegate;

@end
