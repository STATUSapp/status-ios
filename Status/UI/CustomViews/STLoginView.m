//
//  STLoginView.m
//  Status
//
//  Created by Cosmin Andrus on 11/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STLoginView.h"
#import "STNavigationService.h"
#import "STGDPRViewController.h"

NSInteger const kLoginViewTag = 1001;
CGFloat const kLoginButtonViewDefaultHeight = 397.f;
CGFloat const kAnimationDuration = 0.25f;
@interface STLoginView ()

@property (weak, nonatomic) IBOutlet UILabel *agrementLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (weak, nonatomic) id<STLoginViewDelegate>delegate;

@end

@implementation STLoginView

+ (STLoginView *)loginViewWithDelegate:(id<STLoginViewDelegate>)delegate{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"STLoginView" owner:delegate options:nil];
    STLoginView *loginView = [views objectAtIndex:0];
    loginView.delegate = delegate;
    loginView.tag = kLoginViewTag;
    [loginView setInitialState];
    return loginView;
}

- (void)animateIn{
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeAreaInsets = self.safeAreaInsets;
    }
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height - safeAreaInsets.top - safeAreaInsets.bottom;
    self.topConstraint.constant = screenHeight - kLoginButtonViewDefaultHeight;
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                         self.shadowView.alpha = 0.5;
                         [self layoutIfNeeded];
                         
                     }];
    
}
- (void)animateOut{
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    self.topConstraint.constant = screenHeight;
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                         self.shadowView.alpha = 0;
                         [self layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

#pragma mark - Private

-(void)setInitialState{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    CGRect rect = self.frame;
    rect.size = screenSize;
    self.frame = rect;
    self.topConstraint.constant = screenSize.height;
    self.shadowView.alpha = 0.f;
    self.agrementLabel.attributedText = [self bottomString];
    [self layoutIfNeeded];
}

- (NSAttributedString *)bottomString{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@"By signing up, you confirm that you agree to\nour Terms of Use and have read and\nunderstood our Privacy Policy." attributes:@{
                                                                                                                                                                                                                                     NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size: 12.0f],
                                                                                                                                                                                                                                     NSForegroundColorAttributeName: [UIColor colorWithWhite:194.0f / 255.0f alpha:1.0f],
                                                                                                                                                                                                                                     NSKernAttributeName: @(-0.3)
                                                                                                                                                                                                                                     }];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:140.0f / 255.0f alpha:1.0f] range:NSMakeRange(49, 12)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:140.0f / 255.0f alpha:1.0f] range:NSMakeRange(95, 14)];
    
    return attributedString;
}
#pragma mark - IBActions

- (IBAction)onCloseButtonPressed:(id)sender {
    [self animateOut];
}
- (IBAction)onFacebookButtonPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginViewDidSelectFacebook)]) {
        [self.delegate loginViewDidSelectFacebook];
    }
    [self onCloseButtonPressed:nil];
}
- (IBAction)onInstagramButtonPressed:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(loginViewDidSelectInstagram)]) {
        [self.delegate loginViewDidSelectInstagram];
    }
    [self onCloseButtonPressed:nil];
}
- (IBAction)onTermsOfUsePressed:(id)sender {
    UINavigationController *navCtrl = [STGDPRViewController GDPRControllerWithType:STGDPRTypeTermsOfUse];
    UIViewController *viewController = [STNavigationService viewControllerForSelectedTab];
    [viewController presentViewController:navCtrl animated:YES completion:nil];
    [self onCloseButtonPressed:nil];
}
- (IBAction)onPrivacyPolicyPressed:(id)sender {
    UINavigationController *navCtrl = [STGDPRViewController GDPRControllerWithType:STGDPRTypePrivacyPolicy];
    UIViewController *viewController = [STNavigationService viewControllerForSelectedTab];
    [viewController presentViewController:navCtrl animated:YES completion:nil];
    [self onCloseButtonPressed:nil];
}

@end
