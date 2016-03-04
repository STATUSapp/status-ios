//
//  STTakeAPhotoViewController.m
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STTakeAPhotoViewController.h"

@interface STTakeAPhotoViewController ()

@end

@implementation STTakeAPhotoViewController

+ (instancetype)newController {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"TakeAPhoto" bundle:[NSBundle mainBundle]];
    STTakeAPhotoViewController * vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([STTakeAPhotoViewController class])];
    return vc;
}

#pragma mark - IBActions

- (IBAction)takeAPhotoWithCamera:(id)sender {
}

- (IBAction)uploadPhotoFromLibrary:(id)sender {
}

- (IBAction)postPhotoFromFacebook:(id)sender {
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
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

@end
