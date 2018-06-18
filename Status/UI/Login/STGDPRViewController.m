//
//  GDPRViewController.m
//  Status
//
//  Created by Cosmin Andrus on 18/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STGDPRViewController.h"
#import <WebKit/WebKit.h>

@interface STGDPRViewController ()

@property (nonatomic, assign) STGDPRType type;
@property (strong, nonatomic) WKWebView *webView;

@end

@implementation STGDPRViewController

+ (UINavigationController *)GDPRControllerWithType:(STGDPRType)type{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginScene" bundle:nil];
    UINavigationController *navCtrl = [storyboard instantiateViewControllerWithIdentifier:@"GDPR_NAV"];
    STGDPRViewController *vc = [[navCtrl viewControllers] firstObject];
    vc.type = type;
    return navCtrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.type == STGDPRTypeTermsOfUse) {
        self.title = NSLocalizedString(@"Terms of Use", nil);
    }else if (self.type == STGDPRTypePrivacyPolicy){
        self.title = NSLocalizedString(@"Privacy Policy", nil);
    }
    
    self.navigationController.navigationBarHidden = NO;
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    _webView.translatesAutoresizingMaskIntoConstraints = YES;
    [self.view addSubview:_webView];
    NSString *urlString;
    if (self.type == STGDPRTypeTermsOfUse) {
        urlString = @"https://getstatus.co/terms/";
    }else if (self.type == STGDPRTypePrivacyPolicy){
        urlString = @"https://getstatus.co/privacy/";
    }
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)onClosePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
