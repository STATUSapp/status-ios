//
//  STSharePhotoViewController.m
//  Status
//
//  Created by Andrus Cosmin on 23/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STSharePhotoViewController.h"
#import "STNetworkQueueManager.h"
#import <MessageUI/MessageUI.h>
#import <FacebookSDK/FacebookSDK.h>
#import "STFacebookLoginController.h"
#import "STConstants.h"
#import "STFacebookAlbumsLoader.h"
#import "STUpdatePostCaptionRequest.h"

#import "STUploadPostRequest.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface STSharePhotoViewController ()<MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>{
    NSDictionary *editResponseDict;
    
    BOOL _shouldPostToFacebook;
    BOOL _shouldPostToTwitter;
    
    BOOL _donePostingToFacebook;
    BOOL _donePostingToTwitter;
    
    NSError *_fbError;
    NSError *_twitterError;
    
}
@property (weak, nonatomic) IBOutlet UIImageView *sharedImageView;
@property (weak, nonatomic) IBOutlet UINavigationBar *transparentNavBar;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBlurImgView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UITextView *captiontextView;

@property (strong, nonatomic) ACAccountStore * accountStore;
@property (strong, nonatomic) ACAccountType * accountType;

@property (assign, nonatomic) BOOL isTwitterAvailable;
@property (weak, nonatomic) IBOutlet UILabel *writeCaptionPlaceholder;
@property (weak, nonatomic) IBOutlet UIView *shareView;

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
//    _sharedImageView.layer.contentsRect = CGRectMake(0, 0, 1, 0.25);

    _backgroundBlurImgView.image = [UIImage imageWithData:_bluredImgData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    if (_captionString!=nil && _captionString.length > 0) {
        _captiontextView.text = _captionString;
    }
    else{
        _captiontextView.text = @"";
    }
    _captiontextView.delegate = self;
    _writeCaptionPlaceholder.hidden = _captiontextView.text.length>0;
    _shareView.hidden = (_controllerType == STShareControllerEditCaption) ;
    _captiontextView.userInteractionEnabled = (_controllerType != STShareControllerEditPost);
}

- (void)appplicationIsActive:(NSNotification *)notification {
    NSLog(@"Application Did Become Active");
    [self twitterAccess];
}


- (void)twitterAccess {
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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self twitterAccess];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    _shouldPostToFacebook = btn.selected;
}

- (IBAction)onClickTwitter:(id)sender {
    if (_isTwitterAvailable) {
        UIButton *btn = (UIButton *) sender;
        btn.selected = !btn.selected;
        _shouldPostToTwitter = btn.selected;
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Twitter issue"
                                    message:@"In order to post to Twitter you have to setup an account in your device's settings and grant access to STATUS app."
                                   delegate:nil cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)onClickShare:(id)sender {
    _shareButton.enabled = FALSE;
    __weak STSharePhotoViewController *weakSelf = self;
    if (_controllerType == STShareControllerAddPost ||
        _controllerType == STShareControllerEditPost) {
        STRequestCompletionBlock completion = ^(id response, NSError *error){
            if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
                if (weakSelf.editPostId!=nil) {
                    editResponseDict = [NSDictionary dictionaryWithDictionary:response];
                }
                if (_shouldPostToFacebook==YES || _shouldPostToTwitter == YES) {
                    [weakSelf startPostingWithPostId:_editPostId];
                }
                else
                {
                    [weakSelf callTheDelegateIfNeededForPostId:_editPostId];
                }
                
            }
            if (_shouldPostToFacebook==YES || _shouldPostToTwitter == YES) {
                [weakSelf startPostingWithPostId:response[@"post_id"]];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. You can try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                weakSelf.shareButton.enabled = TRUE;
                
            }
        };
        
        STRequestFailureBlock failBlock = ^(NSError *error){
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. You can try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            weakSelf.shareButton.enabled = TRUE;
        };
        [STUploadPostRequest uploadPostForId:_editPostId
                                    withData:_imgData
                                  andCaption:_captionString
                              withCompletion:completion
                                     failure:failBlock];
    }
    else
    {
        [_captiontextView resignFirstResponder];
        
        __weak STSharePhotoViewController *weakSelf = self;
        if (_editPostId!=nil) {
            [STUpdatePostCaptionRequest setPostCaption:_captionString
                                             forPostId:_editPostId
                                        withCompletion:^(id response, NSError *error) {
                                            if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                                                [weakSelf.delegate captionWasEditedForPost:@{@"post_id":_editPostId} withNewCaption:_captionString];
                                                [weakSelf onClickBack:nil];
                                            }
                                            else{
                                                [self showErrorAlert];
                                            }
                                        } failure:^(NSError *error) {
                                            NSLog(@"Error: %@", error.debugDescription);
                                            [self showErrorAlert];
                                        }];
            
            
        }
    }
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

- (void)startPostingWithPostId:(NSString *)postId {
    if (_shouldPostToFacebook) {
        //add publish stream permissions if does not exists
        __weak STSharePhotoViewController *weakSelf = self;
        [STFacebookAlbumsLoader loadPermissionsWithBlock:^(NSArray *newObjects) {
            NSLog(@"Permissions: %@", newObjects);
            if (![newObjects containsObject:@"publish_actions"]) {
                [[FBSession activeSession] requestNewPublishPermissions:@[@"publish_actions"]
                                                        defaultAudience:FBSessionDefaultAudienceFriends
                                                      completionHandler:^(FBSession *session, NSError *error) {
                                                          if (error!=nil) {
                                                              _fbError = error;
                                                          }
                                                          else
                                                              [weakSelf postCurrentPhotoToFacebookWithPostId:postId];
                                                      }];
                
            }
            else
                [weakSelf postCurrentPhotoToFacebookWithPostId:postId];
            
        }];
    }
    
    if (_shouldPostToTwitter) {
        [self postCurrentPhotoToTwitterWithPostId:postId];
    }

}
- (void)postCurrentPhotoToFacebookWithPostId:(NSString *)postId {
    __weak STSharePhotoViewController *weakSelf = self;
    [[STFacebookLoginController sharedInstance] shareImageWithData:self.imgData andCompletion:^(id result, NSError *error) {
        _donePostingToFacebook = YES;
        if (error) {
            _fbError = error;
        }
        [weakSelf callTheDelegateIfNeededForPostId:postId];
    }];
}

- (void)postCurrentPhotoToTwitterWithPostId:(NSString *)postId {
    NSString * status = [NSString stringWithFormat:@"what's YOUR status? via %@",STInviteLink];
    UIImage * imgToPost = [UIImage imageWithData:self.imgData];
    
    [self twitterAccountPostImage:imgToPost withStatus:status andPostId:postId];
    
}


- (void)twitterAccountPostImage:(UIImage *)image withStatus:(NSString *)status andPostId:(NSString *)postId
{
    __weak STSharePhotoViewController *weakSelf = self;
    ACAccountType *twitterType =
    [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    SLRequestHandler requestHandler =
    ^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        _donePostingToTwitter = YES;
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
                _twitterError = [NSError errorWithDomain:@"com.twiter.post" code:statusCode userInfo:nil];
                NSLog(@"[ERROR] Server responded: status code %ld %@", (long)statusCode,
                      [NSHTTPURLResponse localizedStringForStatusCode:statusCode]);
            }
        }
        else {
            _twitterError = error;
            NSLog(@"[ERROR] An error occurred while posting: %@", [error localizedDescription]);
        }
        [weakSelf callTheDelegateIfNeededForPostId:postId];
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
            _donePostingToTwitter = YES;
            _twitterError = error;
            [weakSelf callTheDelegateIfNeededForPostId:postId];
            NSLog(@"[ERROR] An error occurred while asking for user authorization: %@",
                  [error localizedDescription]);
        }
    };
    
    [self.accountStore requestAccessToAccountsWithType:twitterType
                                               options:NULL
                                            completion:accountStoreHandler];
}


- (void)showMessagesAndCallDelegatesForPostId:(NSString *)postId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *alertTitle = nil;
        NSString *alertMessage = nil;
        if (_fbError !=nil || _twitterError !=nil) {
            if (_fbError!=nil && _twitterError !=nil) {
                alertTitle = @"Warning";
                alertMessage = @"Your photo was posted on STATUS, but not shared on Facebook and Twitter.";
            }
            else if (_fbError!=nil){
                alertTitle = @"Warning";
                alertMessage = @"Your photo was posted on STATUS, but not shared on Facebook. You can try sharing it on Facebook from your profile.";
            }
            else if (_twitterError!=nil){
                alertTitle = @"Warning";
                alertMessage = @"Your photo was posted on STATUS, but not shared on Twitter.";
            }
        }
        else
        {
            alertTitle = @"Success";
            alertMessage = @"Your photo was posted on STATUS";
        }
        if (alertMessage!=nil) {
            [[[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            
        }
        if (_editPostId!=nil) {
            [_delegate imageWasEdited:editResponseDict];
        }
        else
            [_delegate imageWasPostedWithPostId:postId];
    });

}

-(void)callTheDelegateIfNeededForPostId:(NSString *)postId{
    
    if (_shouldPostToFacebook == YES && _donePostingToFacebook == YES) {
        if (_shouldPostToTwitter == YES && _donePostingToTwitter == NO) {
            return;
        }
        else
            [self showMessagesAndCallDelegatesForPostId:postId];
    }
    else if (_shouldPostToTwitter == YES && _donePostingToTwitter == YES){
        if (_shouldPostToFacebook == YES && _donePostingToFacebook == NO) {
            return;
        }
        else
            [self showMessagesAndCallDelegatesForPostId:postId];
    }
    else
        [self showMessagesAndCallDelegatesForPostId:postId];
    
}

-(void)showErrorAlert{
    [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}


#pragma mark - UITextViewDelegate

-(void)textViewDidEndEditing:(UITextView *)textView{
    _captionString = textView.text;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    NSInteger textLenght = textView.text.length;
    if (text.length > 0) {
        textLenght = textLenght + text.length;
    }
    else
        textLenght--;//delete pressed
    _writeCaptionPlaceholder.hidden = (textLenght>0);
    
    return YES;
}
@end
