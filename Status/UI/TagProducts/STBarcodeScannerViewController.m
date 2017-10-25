//
//  STBarcodeScannerViewController.m
//  Status
//
//  Created by Cosmin Andrus on 17/09/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBarcodeScannerViewController.h"
#import <AVFoundation/AVFoundation.h>

NSInteger const verificationCount = 3;

@interface STBarcodeScannerViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) NSString *scannedBarcode;
@property (nonatomic, assign) NSInteger barcodeCount;
@property (nonatomic, strong) UIAlertController *barcodeAlert;

@end

@implementation STBarcodeScannerViewController

-(BOOL)hidesBottomBarWhenPushed{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    @try {
        self.captureSession = [[AVCaptureSession alloc] init];
        AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
//        videoCaptureDevice.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
        NSError *error = nil;
        AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
        if(videoInput)
            [self.captureSession addInput:videoInput];
        else
            NSLog(@"Error: %@", error);
        
        AVCaptureMetadataOutput *metadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [self.captureSession addOutput:metadataOutput];
        [metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
        [metadataOutput setMetadataObjectTypes:@[AVMetadataObjectTypeEAN13Code]];
        
        AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        previewLayer.frame = self.view.layer.bounds;
        [self.view.layer addSublayer:previewLayer];
        
        [self.captureSession startRunning];

    } @catch (NSException *exception) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your device can not record." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
        [self.parentViewController presentViewController:alert animated:YES completion:nil];
    } @finally {
        
    }
}

+ (STBarcodeScannerViewController *)newController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TagProductsScene" bundle:nil];
    STBarcodeScannerViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"BARCODE_SCANNER_VC"];
    return vc;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for(AVMetadataObject *metadataObject in metadataObjects)
    {
        AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)metadataObject;
        
        if ([metadataObject.type isEqualToString:AVMetadataObjectTypeEAN13Code])
        {
            NSString *barcode = readableObject.stringValue;
            if ([_scannedBarcode isEqualToString:barcode]) {
                _barcodeCount ++;
                if (_barcodeCount == verificationCount && _scannedBarcode) {
                    NSLog(@"EAN 13 = %@", barcode);
                    if (_delegate && [_delegate respondsToSelector:@selector(barcodeScannerDidScanCode:)]) {
                        [_delegate barcodeScannerDidScanCode:_scannedBarcode];
                        _scannedBarcode = nil;
                    }
                }
                
            }else{
                _scannedBarcode = barcode;
                _barcodeCount = 0;
            }
        }
    }
}


@end
