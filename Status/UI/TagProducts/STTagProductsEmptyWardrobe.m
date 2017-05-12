//
//  STTagProductsEmptyWardrobe.m
//  Status
//
//  Created by Cosmin Andrus on 05/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagProductsEmptyWardrobe.h"

@interface STTagProductsEmptyWardrobe ()

@end

@implementation STTagProductsEmptyWardrobe

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)onWizzardButtonPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(wizzardOptionSelected)]) {
        [_delegate wizzardOptionSelected];
    }
}
- (IBAction)onManualButtonPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(manualOptionSelected)]) {
        [_delegate manualOptionSelected];
    }
}


@end
