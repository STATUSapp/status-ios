//
//  LaunchViewController.m
//  Status
//
//  Created by Cosmin Home on 29/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "LaunchViewController.h"
#import "STNavigationService.h"
#import "STFacebookLoginController.h"

@interface LaunchViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *launchImage;

@end

@implementation LaunchViewController

+(LaunchViewController *)launchVC{
    UIStoryboard *scene = [UIStoryboard storyboardWithName:@"LaunchScene" bundle:nil];
    LaunchViewController *vc = [scene instantiateInitialViewController];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [STUIHelper splashImageWithLogo:YES];
    _launchImage.image = image;
    
    if ([CoreManager shouldLogin])
        [[CoreManager navigationService] presentLoginScreen];
    [[CoreManager loginService] startLoginIfPossible];
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
