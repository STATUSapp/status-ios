//
//  STWhiteNavBarViewController.m
//  Status
//
//  Created by Cosmin Andrus on 19/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STWhiteNavBarViewController.h"

CGFloat const kWhiteNavBarHeight = 49.f;

@interface STWhiteNavBarViewController ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIButton *leftButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *barHeightConstraint;

@end

@implementation STWhiteNavBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!_navigationBar) {
        NSAssert(NO, @"STWhiteNavBarViewController.navigationBar is NULL");
    }
    if (!_leftButton) {
        NSAssert(NO, @"STWhiteNavBarViewController.leftButton is NULL");
    }
    if (!_barHeightConstraint) {
        NSAssert(NO, @"STWhiteNavBarViewController.barHeightConstraint is NULL");
    }

    _barHeightConstraint.constant = kWhiteNavBarHeight;
    if ([self shouldHideLeftButton]) {
        _leftButton.hidden = YES;
    }
    else
    {
        CGRect rect = _leftButton.frame;
        rect.origin.y = 0;
        rect.size.height = kWhiteNavBarHeight;
        rect.size.width = kWhiteNavBarHeight;
        _leftButton.frame = rect;
        _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _leftButton.contentEdgeInsets = UIEdgeInsetsMake(0.f, 0.f, 3.f, 0.f);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setNavigationTitle:(NSString *)title{
    self.navigationBar.topItem.title = title;
}

#pragma mark - Hook Methods

-(BOOL)shouldHideLeftButton{
    return NO;
}

@end
