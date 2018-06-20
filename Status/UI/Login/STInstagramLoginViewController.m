//
//  STInstagramLoginViewController.m
//  Status
//
//  Created by Cosmin Andrus on 17/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STInstagramLoginViewController.h"
#import "STInstagramLoginService.h"
#import <WebKit/WebKit.h>

@interface STInstagramLoginViewController ()<WKUIDelegate, WKNavigationDelegate>
@property (strong, nonatomic) WKWebView *webView;

@end

@implementation STInstagramLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame];
    _webView.allowsBackForwardNavigationGestures = YES;
    self.view = _webView;
//    [self.view addSubview:_webView];
//    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
//    _webView.translatesAutoresizingMaskIntoConstraints = NO;

//    [self.view addConstraints:
//     @[
//       [NSLayoutConstraint constraintWithItem:self.webView
//                                    attribute:NSLayoutAttributeTop
//                                    relatedBy:NSLayoutRelationEqual
//                                       toItem:self.view
//                                    attribute:NSLayoutAttributeTop
//                                   multiplier:1.0
//                                     constant:0.0],
//
//       [NSLayoutConstraint constraintWithItem:self.webView
//                                    attribute:NSLayoutAttributeBottom
//                                    relatedBy:NSLayoutRelationEqual
//                                       toItem:self.view
//                                    attribute:NSLayoutAttributeBottom
//                                   multiplier:1.0
//                                     constant:0.0],
//
//       [NSLayoutConstraint constraintWithItem:self.webView
//                                    attribute:NSLayoutAttributeLeading
//                                    relatedBy:NSLayoutRelationEqual
//                                       toItem:self.view
//                                    attribute:NSLayoutAttributeLeading
//                                   multiplier:1.0
//                                     constant:0.0],
//
//       [NSLayoutConstraint constraintWithItem:self.webView
//                                    attribute:NSLayoutAttributeTrailing
//                                    relatedBy:NSLayoutRelationEqual
//                                       toItem:self.view
//                                    attribute:NSLayoutAttributeTrailing
//                                   multiplier:1.0
//                                     constant:0.0],
//       ]];

    NSURL *instagramURL = [[CoreManager instagramLoginService] getInstagramOauthURL];
    if (instagramURL) {
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        NSURLRequest *request = [NSURLRequest requestWithURL:instagramURL];;
        [_webView loadRequest:request];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    if (@available(iOS 11.0, *)) {
        [self.webView.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull arrCookies) {
            
            for (NSHTTPCookie *cookie in arrCookies) {
                NSLog(@"Cookie: \n%@ \n\n", cookie);
            }
        }];
    } else {
        // Fallback on earlier versions
        NSArray *cookieStore = NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies;
        for (NSHTTPCookie *cookie in cookieStore) {
            NSLog(@"Cookie: \n%@ \n\n", cookie);
        }
    }

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

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSInteger statusCode = ((NSHTTPURLResponse *)navigationResponse.response).statusCode;
    NSURL *url = navigationResponse.response.URL;
    NSString *urlString = url.absoluteString;
    NSString *urlHost = url.host;
    if ([urlHost isEqualToString:kReachableURL] &&
        [urlString containsString:@"instagram_authentication"]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[CoreManager instagramLoginService] instagramLoginFeedbackRedirectWithStatus:statusCode];
        }];
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}
- (IBAction)onCloseButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[CoreManager instagramLoginService] instagramLoginFeedbackRedirectWithStatus:kClientCancelLoginCode];
    }];
}
@end
