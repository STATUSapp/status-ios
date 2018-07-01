//
//  LoginViewController.m
//  Status
//
//  Created by Andrus Cosmin on 17/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STLoginViewController.h"
#import "STConstants.h"
#import "STLoginService.h"
#import <FBSDKLoginKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "STTutorialViewController.h"
#import "STResetBaseUrlService.h"

//NSInteger const kLoginButtonTag = 121;

@interface STLoginViewController ()<STTutorialDelegate>
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIImageView *splashBackground;
@property (weak, nonatomic) IBOutlet UIButton *fBLoginButton;

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

-(void)multipleTapOnShopStyle{
    //show change base url alert
    UIAlertController *alertController = [[CoreManager resetBaseUrlService] resetBaseUrlAlert];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
#pragma mark - IBActions
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
