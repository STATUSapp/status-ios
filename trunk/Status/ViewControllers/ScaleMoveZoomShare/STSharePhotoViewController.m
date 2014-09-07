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
#import "STFacebookAlbumsLoader.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface STSharePhotoViewController ()<MFMailComposeViewControllerDelegate, UINavigationControllerDelegate>{
    NSDictionary *editResponseDict;
}
@property (weak, nonatomic) IBOutlet UIButton *facebookBtn;
@property (weak, nonatomic) IBOutlet UIButton *twitterBtn;
@property (weak, nonatomic) IBOutlet UIImageView *sharedImageView;
@property (weak, nonatomic) IBOutlet UINavigationBar *transparentNavBar;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBlurImgView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@property (strong, nonatomic) ACAccountStore * accountStore;
@property (strong, nonatomic) ACAccountType * accountType;

@property (assign, nonatomic) BOOL isTwitterAvailable;

@end

@implementation STSharePhotoViewController

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
    [_transparentNavBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    _transparentNavBar.shadowImage = [UIImage new];
    _transparentNavBar.translucent = YES;

	_sharedImageView.image = [UIImage imageWithData:_imgData];
    _backgroundBlurImgView.image = [UIImage imageWithData:_bluredImgData];
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // setup twitter account
    
    _accountStore = [[ACAccountStore alloc] init];
    _accountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    __weak STSharePhotoViewController * weakSelf = self;
    
    
    [_accountStore requestAccessToAccountsWithType:_accountType
                                           options:nil
                                        completion:^(BOOL granted, NSError *error)
     {
         if (granted == YES)
         {
             weakSelf.isTwitterAvailable = ([weakSelf.accountStore accountsWithAccountType:weakSelf.accountType].count > 0);
         } else {
             weakSelf.isTwitterAvailable = NO;
         }
     }];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBACTIONS
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
    [emailShareController addAttachmentData:_imgData mimeType:@"image/jpeg" fileName:fileName];

    [self presentViewController:emailShareController animated:YES completion:nil];
}
- (IBAction)onClickFacebook:(id)sender {

    UIButton *btn = (UIButton *) sender;
    btn.selected = !btn.selected;
}

- (IBAction)onClickTwitter:(id)sender {
    if (_isTwitterAvailable) {
        UIButton *btn = (UIButton *) sender;
        btn.selected = !btn.selected;
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Twitter issue"
                                    message:@"In order to post to Twitter you have to setup an account in your device's settings"
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)onClickShare:(id)sender {
    _shareButton.enabled = FALSE;
    __weak STSharePhotoViewController *weakSelf = self;
    [[STWebServiceController sharedInstance] uploadPostForId:_editPostId withData:_imgData withCompletion:^(NSDictionary *response) {
        
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            if (_editPostId!=nil) {
                editResponseDict = [NSDictionary dictionaryWithDictionary:response];
            }
            if (weakSelf.facebookBtn.selected==TRUE) {
                //add publish stream permissions if does not exists
                [STFacebookAlbumsLoader loadPermissionsWithBlock:^(NSArray *newObjects) {
                    NSLog(@"Permissions: %@", newObjects);
                    if (![newObjects containsObject:@"publish_actions"]) {
                        [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"]
                                                                defaultAudience:FBSessionDefaultAudienceFriends
                                                              completionHandler:^(FBSession *session, NSError *error) {
                                                                  [self postCurrentPhotoToFacebook];
                                                              }];
                        
                    }
                    else
                        [self postCurrentPhotoToFacebook];
                    
                }];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Your photo was posted on STATUS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                [weakSelf callTheDelegate];
            }

        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. You can try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            weakSelf.shareButton.enabled = TRUE;
            
        }
 
    } orError:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. You can try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        weakSelf.shareButton.enabled = TRUE;
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

#pragma mark - Helper
- (void)postCurrentPhotoToFacebook {
    __weak STSharePhotoViewController *weakSelf = self;
    [[STFacebookController sharedInstance] shareImageWithData:self.imgData andCompletion:^(id result, NSError *error) {
        if(error==nil)
        {
            [[[UIAlertView alloc] initWithTitle:@"Success" message:@"Your photo was posted on STATUS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [weakSelf callTheDelegate];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"Your photo was posted on STATUS, but not shared on Facebook. You can try sharing it on Facebook from your profile." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            [weakSelf callTheDelegate];
        }
    }];
}

- (void)postCurrentPhotoToTwitter {
    NSString * status = [NSString stringWithFormat:@"what's YOUR status? via %@",STInviteLink];
    UIImage * imgToPost = [UIImage imageWithData:self.imgData];
    
    [self twitterAccountPostImage:imgToPost withStatus:status];
    
}


- (void)twitterAccountPostImage:(UIImage *)image withStatus:(NSString *)status
{
    ACAccountType *twitterType =
    [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    SLRequestHandler requestHandler =
    ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        if (responseData) {
            NSInteger statusCode = urlResponse.statusCode;
            if (statusCode >= 200 && statusCode < 300) {
                NSDictionary *postResponseData =
                [NSJSONSerialization JSONObjectWithData:responseData
                                                options:NSJSONReadingMutableContainers
                                                  error:NULL];
                NSLog(@"[SUCCESS!] Created Tweet with ID: %@", postResponseData[@"id_str"]);
            }
            else {
                NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        }
        else {
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
        }
    };
    
    ACAccountStoreRequestAccessCompletionHandler accountStoreHandler =
    ^(BOOL granted, NSError *error) {
        if (granted) {
            NSArray *accounts = [self.accountStore accountsWithAccountType:twitterType];
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                          @"/1.1/statuses/update_with_media.json"];
            NSDictionary *params = @{@"status" : status};
            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                    requestMethod:SLRequestMethodPOST
                                                              URL:url
                                                       parameters:params];
            NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
            [request addMultipartData:imageData
                             withName:@"media[]"
                                 type:@"image/jpeg"
                             filename:@"image.jpg"];
            [request setAccount:[accounts lastObject]];
            [request performRequestWithHandler:requestHandler];
        }
        else {
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
        }
    };
    
    [self.accountStore requestAccessToAccountsWithType:twitterType
                                               options:NULL
                                            completion:accountStoreHandler];
}


-(void)callTheDelegate{
    if (_editPostId!=nil) {
        [_delegate imageWasEdited:editResponseDict];
    }
    else
        [_delegate imageWasPosted];
}
@end
