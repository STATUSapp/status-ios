//
//  LoginViewController.m
//  Status
//
//  Created by Andrus Cosmin on 17/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STLoginViewController.h"
#import "STImageCacheController.h"
#import "STConstants.h"
#import "STFacebookLoginController.h"
#import "STNetworkQueueManager.h"
#import <FBSDKLoginKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "STTutorialViewController.h"

//NSInteger const kLoginButtonTag = 121;

@interface STLoginViewController ()<STTutorialDelegate>
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *splashBackground;
@property (weak, nonatomic) IBOutlet UIButton *fBLoginButton;

@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation STLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedIn) name:kNotificationFacebokDidLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedOut) name:kNotificationFacebokDidLogout object:nil];

    
    self.view.backgroundColor = [UIColor clearColor];
    _splashBackground.image = [STUIHelper splashImageWithLogo:NO];
    _closeButton.hidden = !_showCloseButton;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"Segue.identifier: %@", segue.identifier);
    [(STTutorialViewController *)segue.destinationViewController setSkipFirstItem:NO];
    [(STTutorialViewController *)segue.destinationViewController setDelegate:self];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - STTutorialDelegate

-(void)loginButtonPressed:(id)sender{
    [self onFacebookButtonPressed:sender];
}

-(void)multipleTapOnShopStyle{
    //show change base url alert
    
    __weak STLoginViewController *weakSelf = self;
    _alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    [_alertController addTextFieldWithConfigurationHandler:nil];
    [_alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf = [weakSelf.alertController.textFields firstObject];
        NSString *newBaseUrl = tf.text;
        if (newBaseUrl) {
            NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"BaseUrl"];
            [ud setValue:newBaseUrl forKey:@"BASE_URL"];
            [ud synchronize];
            [[CoreManager networkService] reset];
        }
    }]];
    [_alertController addAction:[UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"BaseUrl"];
        [ud setValue:kBaseURL forKey:@"BASE_URL"];
        [ud synchronize];
        [[CoreManager networkService] reset];

    }]];
    
    [self presentViewController:_alertController animated:YES completion:nil];
    
}
#pragma mark - IBActions
- (IBAction)onFacebookButtonPressed:(id)sender {
    FBSDKLoginButton *loginButton = [[CoreManager loginService] facebookLoginButton];
    [loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];

}
- (IBAction)onCloseButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - NSNotifications
- (void)userDidLoggedIn{
//    FBSDKLoginButton *loginButton = [self.view viewWithTag:kLoginButtonTag];
//    loginButton.hidden = YES;
    _fBLoginButton.hidden = YES;
}

- (void)userDidLoggedOut{
//    FBSDKLoginButton *loginButton = [self.view viewWithTag:kLoginButtonTag];
//    loginButton.hidden = NO;
    _fBLoginButton.hidden = NO;

}
@end
