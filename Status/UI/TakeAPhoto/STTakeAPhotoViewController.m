//
//  STTakeAPhotoViewController.m
//  Status
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STTakeAPhotoViewController.h"
#import "CoreManager.h"

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


@end
