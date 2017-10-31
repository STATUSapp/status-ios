//
//  STMissingProductTVCTableViewController.m
//  Status
//
//  Created by Cosmin Andrus on 24/10/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STMissingProductTVCTableViewController.h"
@interface STMissingProductTVCTableViewController ()<UITextFieldDelegate>
{
    NSArray *fieldsArray;
}
@property (weak, nonatomic) IBOutlet UITextField *brandNameField;
@property (weak, nonatomic) IBOutlet UITextField *productNameField;
@property (weak, nonatomic) IBOutlet UITextField *productURLField;

@end

@implementation STMissingProductTVCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    fieldsArray = @[_brandNameField, _productNameField, _productURLField];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSInteger indexOfField = [fieldsArray indexOfObject:textField];
    if (indexOfField < fieldsArray.count - 1) {
        //go next
        UITextField *nextField = [fieldsArray objectAtIndex:(indexOfField+1)];
        [nextField becomeFirstResponder];
    }else{
        //done
        [textField resignFirstResponder];
        if (_delegate && [_delegate respondsToSelector:@selector(missingProductTVCDidPressSend)]) {
            [_delegate missingProductTVCDidPressSend];
        }

    }
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (_delegate && [_delegate respondsToSelector:@selector(missingProductDetailsEdited)]) {
        [_delegate missingProductDetailsEdited];
    }
}
#pragma mark - Helpers

-(BOOL)validateFields{
    NSString *errorMessage;
    if (_brandNameField.text.length == 0) {
        errorMessage = NSLocalizedString(@"Brand Name is required.", nil);
    }
    if (!errorMessage && _productNameField.text.length == 0) {
        errorMessage = NSLocalizedString(@"Product Name is required.", nil);
    }
    if (!errorMessage && _productURLField.text.length == 0) {
        errorMessage = NSLocalizedString(@"Product Store Link is required.", nil);
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

- (IBAction)onCancelPressed:(id)sender {
    //reset the fields
    [self invalidateFields];
    //then call the delegate
    if (_delegate && [_delegate respondsToSelector:@selector(missingProductTVCDidPressCancel)]) {
        [_delegate missingProductTVCDidPressCancel];
    }
}

#pragma mark - Private
-(void)invalidateFields{
    //reset the fields
    _brandNameField.text = @"";
    _productNameField.text = @"";
    _productURLField.text = @"";
}

#pragma mark - Public

-(BOOL)validate{
    return [self validateFields];
}
-(NSString *)brandName{
    return self.brandNameField.text;
}
-(NSString *)productName{
    return self.productNameField.text;
}
-(NSString *)productURL{
    return self.productURLField.text;
}

@end
