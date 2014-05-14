//
//  STSharePhotoViewController.m
//  Status
//
//  Created by Andrus Cosmin on 23/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STSharePhotoViewController.h"
#import "STWebServiceController.h"
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import "STFacebookController.h"
#import "STConstants.h"

@interface STSharePhotoViewController ()<MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UIImageView *sharedImageView;
@end

@implementation STSharePhotoViewController
@synthesize imgData;

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
	self.sharedImageView.image = [UIImage imageWithData:imgData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onClickEmail:(id)sender {
    MFMailComposeViewController *emailShareController = [[MFMailComposeViewController alloc] init];
    [emailShareController setTitle:@"STATUS"];
    [emailShareController setSubject:@"Share Photo on STATUS"];
    [emailShareController setDelegate:self];
    [emailShareController setMailComposeDelegate:self];
    
    NSString *fileName = @"image_status";
    fileName = [fileName stringByAppendingPathExtension:@"jpeg"];
    [emailShareController addAttachmentData:imgData mimeType:@"image/jpeg" fileName:fileName];

    [self presentViewController:emailShareController animated:YES completion:nil];
}
- (void)postCurrentPhoto {
    __weak STSharePhotoViewController *weakSelf = self;
    [[STFacebookController sharedInstance] shareImageWithData:self.imgData andCompletion:^(id result, NSError *error) {
        if(error==nil)
        {
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Your photo was posted on STATUS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [weakSelf.delegate performSelector:@selector(imageWasPosted)];
            //[weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (IBAction)onClickFacebook:(id)sender {

    UIButton *btn = (UIButton *) sender;
    btn.selected = !btn.selected;
}

- (IBAction)onClickShare:(id)sender {
    
    __block UIButton *btn = (UIButton *) sender;
    btn.enabled = FALSE;
    __weak STSharePhotoViewController *weakSelf = self;
    [[STWebServiceController sharedInstance] uploadPictureWithData:imgData withCompletion:^(NSDictionary *response) {
        
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            
            if (weakSelf.facebookBtn.selected==TRUE) {
                //add publish stream permissions if does not exists
                if (![[[FBSession activeSession] permissions] containsObject:@"publish_actions"]) {
                    [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"]
                                                            defaultAudience:FBSessionDefaultAudienceFriends
                                                          completionHandler:^(FBSession *session, NSError *error) {
                                                              [self postCurrentPhoto];
                                                          }];
                    
                }
                else
                    [self postCurrentPhoto];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Your photo was posted on STATUS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                [weakSelf.delegate performSelector:@selector(imageWasPosted)];
                //[weakSelf.navigationController popViewControllerAnimated:YES];
            }

        }
        else
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. You can try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
        btn.enabled = TRUE;
        
        
    } orError:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. You can try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        btn.enabled = TRUE;
    }];
}

#pragma mark - MFMailControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultSent) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email sent" message:@"Your message was shared." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}
@end
