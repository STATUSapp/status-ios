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
@property (weak, nonatomic) IBOutlet UIImageView *splashBackground;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
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

    
    _splashBackground.image = [STUIHelper splashImageWithLogo:NO];
//    FBSDKLoginButton *loginButton = [[CoreManager loginService] facebookLoginButton];
//    loginButton.tag = kLoginButtonTag;
//    [loginButton setTranslatesAutoresizingMaskIntoConstraints:NO];
//    [loginButton setBackgroundImage:[UIImage imageNamed:@"fb-login-base"] forState:UIControlStateNormal];
//    [loginButton setBackgroundImage:[UIImage imageNamed:@"fb-login-base-pressed"] forState:UIControlStateHighlighted];
//    [loginButton setImage:[UIImage imageNamed:@"fb-icon"] forState:UIControlStateNormal];
//    [loginButton.titleLabel setText:@"FACEBOOK LOGIN"];
//    
//    CGRect frame = loginButton.frame;
//    frame.size.width = 245.f;
//    frame.size.height = 69.f;
//    frame.origin.y = 0.f;
//    loginButton.frame = frame;
//    
//    loginButton.hidden = NO;
//    [self.view addSubview:loginButton];
//    NSLayoutConstraint *bottomConstraint =[NSLayoutConstraint
//                                           constraintWithItem:loginButton
//                                           attribute:NSLayoutAttributeBottom
//                                           relatedBy:NSLayoutRelationEqual
//                                           toItem:self.view
//                                           attribute:NSLayoutAttributeBottom
//                                           multiplier:1.f
//                                           constant:-65];
//    NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:loginButton
//                                                                        attribute:NSLayoutAttributeCenterX
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:self.view
//                                                                        attribute:NSLayoutAttributeCenterX
//                                                                       multiplier:1.f
//                                                                         constant:1.f];
//    
//    NSLayoutConstraint *widthContraint = [NSLayoutConstraint constraintWithItem:loginButton
//                                                                        attribute:NSLayoutAttributeWidth
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:nil
//                                                                        attribute:NSLayoutAttributeNotAnAttribute
//                                                                       multiplier:1.f
//                                                                         constant:245.f];
//    
//    NSLayoutConstraint *heightContraint = [NSLayoutConstraint constraintWithItem:loginButton
//                                                                      attribute:NSLayoutAttributeHeight
//                                                                      relatedBy:NSLayoutRelationEqual
//                                                                         toItem:nil
//                                                                      attribute:NSLayoutAttributeNotAnAttribute
//                                                                     multiplier:1.f
//                                                                       constant:69.f];
//
//
//    
//    
//     [self.view addConstraints:@[bottomConstraint, centerConstraint, widthContraint, heightContraint]];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"Segue.identifier: %@", segue.identifier);
    [(STTutorialViewController *)segue.destinationViewController setSkipFirstItem:NO];
    [(STTutorialViewController *)segue.destinationViewController setDelegate:self];
    
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

#pragma mark - IBActions
- (IBAction)onFacebookButtonPressed:(id)sender {
    FBSDKLoginButton *loginButton = [[CoreManager loginService] facebookLoginButton];
    [loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];

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
