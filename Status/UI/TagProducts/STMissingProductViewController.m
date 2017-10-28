//
//  STBarcodeProductNotIndexedViewController.m
//  Status
//
//  Created by Cosmin Andrus on 25/09/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STMissingProductViewController.h"
#import "STMissingProductTVCTableViewController.h"

@interface STMissingProductViewController ()<STProductNotIndexedTVCProtocol>

@property (nonatomic, strong) STMissingProductTVCTableViewController *childTVC;

@end

@implementation STMissingProductViewController

-(BOOL)hidesBottomBarWhenPushed{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self.navigationController.tabBarController.tabBar setHidden:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"MISSING_PRODUCT_TVC"]) {
        _childTVC = (STMissingProductTVCTableViewController *)segue.destinationViewController;
        _childTVC.delegate = self;
    }
}


#pragma mark - IBActions

- (IBAction)onSendPressed:(id)sender {
    if ([_childTVC validate]) {
        //call the delegate
        if (_delegate && [_delegate respondsToSelector:@selector(viewDidSendInfoWithBrandName:productName:productURK:)]) {
            [_delegate viewDidSendInfoWithBrandName:[_childTVC brandName]
                                        productName:[_childTVC productName]
                                         productURK:[_childTVC productURL]];
        }
    }
}

#pragma mark - STProductNotIndexedTVCProtocol

-(void)missingProductTVCDidPressCancel{
    //call the delegate
    if (_delegate && [_delegate respondsToSelector:@selector(viewDidCancel)]) {
        [_delegate viewDidCancel];
    }
}

-(void)missingProductTVCDidPressSend{
    [self onSendPressed:nil];
}
@end
