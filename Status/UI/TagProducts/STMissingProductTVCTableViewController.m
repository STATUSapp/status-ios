//
//  STMissingProductTVCTableViewController.m
//  Status
//
//  Created by Cosmin Andrus on 24/10/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STMissingProductTVCTableViewController.h"
@interface STMissingProductTVCTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *brandNameField;
@property (weak, nonatomic) IBOutlet UITextField *productNameField;
@property (weak, nonatomic) IBOutlet UITextField *productURLField;

@end

@implementation STMissingProductTVCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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

- (IBAction)onCancelPressed:(id)sender {
    //reset the fields
    [self invalidateFields];
    //then call the delegate
    if (_delegate && [_delegate respondsToSelector:@selector(missingProductTVCDidCancel)]) {
        [_delegate missingProductTVCDidCancel];
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
    return [self validate];
}
-(NSString *)brandName{
    return self.brandNameField.text;
}
-(NSString *)productName{
    return self.productNameField.text;
}
-(NSString *)productURL{
    return self.productNameField.text;
}

@end
