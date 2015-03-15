//
//  STTutorialPresenterViewController.m
//  Status
//
//  Created by Cosmin Andrus on 12/02/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STTutorialPresenterViewController.h"
#import "STTutorialViewController.h"

@interface STTutorialPresenterViewController ()

@end

@implementation STTutorialPresenterViewController

+(STTutorialPresenterViewController *)newInstance{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LoginScene" bundle:nil];
    STTutorialPresenterViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"TUTORIAL_PRESENTER"];
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onClosePressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"Segue.identifier: %@", segue.identifier);
    [(STTutorialViewController *)segue.destinationViewController setSkipFirstItem:YES];
}

@end
