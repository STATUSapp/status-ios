//
//  STBarcodeProductNotIndexedViewController.m
//  Status
//
//  Created by Cosmin Andrus on 25/09/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STMissingProductViewController.h"

@interface STMissingProductViewController ()
@property (weak, nonatomic) IBOutlet UITextField *brandNameField;
@property (weak, nonatomic) IBOutlet UITextField *productNameField;
@property (weak, nonatomic) IBOutlet UITextField *productURLField;

@end

@implementation STMissingProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController.tabBarController.tabBar setHidden:YES];
    NSLog(@"NAV.CTRL>VCS = %@", self.navigationController.viewControllers);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Helpers

-(BOOL)validateFields{
    NSString *errorMessage;
    if (_brandNameField.text.length == 0) {
        errorMessage = NSLocalizedString(@"Brand Name is required.", nil);
    }
    if (_productNameField.text.length == 0) {
        errorMessage = NSLocalizedString(@"Product Name is required.", nil);
    }
    if (_productURLField.text.length == 0) {
        errorMessage = NSLocalizedString(@"Product URL is required.", nil);
    }
    
    if (errorMessage) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        
        [self presentViewController:alert animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

#pragma mark - IBActions

- (IBAction)onSendPressed:(id)sender {
    if ([self validateFields]) {
        //call the delegate
        if (_delegate && [_delegate respondsToSelector:@selector(viewDidSendInfoWithBrandName:productName:productURK:)]) {
            [_delegate viewDidSendInfoWithBrandName:_brandNameField.text productName:_productNameField.text productURK:_productURLField.text];
        }
    }
}
- (IBAction)onCancelPressed:(id)sender {
    //reset the fields
    _brandNameField.text = @"";
    _productNameField.text = @"";
    _productURLField.text = @"";
    
    //then call the delegate
    if (_delegate && [_delegate respondsToSelector:@selector(viewDidCancel)]) {
        [_delegate viewDidCancel];
    }

}

@end
