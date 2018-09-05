//
//  STShareTopViewControler.m
//  Status
//
//  Created by Cosmin Andrus on 01/09/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STShareTopViewControler.h"
#import "STTopBase.h"
#import "STNotificationObj.h"
#import "STDataAccessUtils.h"
#import "STLoadingView.h"
#import "STPost.h"
#import "UILabel+TopRanking.h"
#import "STPost.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import "STFacebookHelper.h"
#import "STInstagramShareService.h"

CGFloat kMinVerticalMarginForImage = 21.f;

@interface STShareTopViewControler ()
@property (weak, nonatomic) IBOutlet UILabel *topShareDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *topShareRankBadge;
@property (weak, nonatomic) IBOutlet UIImageView *topSharePostImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topShareImageTopConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topShareImageBottomConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topShareImageLeadingConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topShareImageTrailingConstr;
@property (strong, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UILabel *shareDetailsLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareRankBadge;
@property (weak, nonatomic) IBOutlet UIImageView *sharePostImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareImageTopConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareImageBottomConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareImageLeadingConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareImageTrailingConstr;

@property (nonatomic, strong) STLoadingView *customLoadingView;

@property (nonatomic, assign) BOOL facebookSelected;
@property (nonatomic, assign) BOOL instagramSelected;

@property (nonatomic, strong) UIImage *shareImage;

@property (nonatomic, strong) STTopBase *top;
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong) STPost *post;

@end

@implementation STShareTopViewControler

+ (STShareTopViewControler *)shareTopViewControllerWithNotification:(STNotificationObj *)no{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ShareTopsScene" bundle:nil];
    STShareTopViewControler *vc = [storyboard instantiateViewControllerWithIdentifier:@"SHARE_TOP_VC"];
    vc.top = no.top;
    vc.postId = no.postId;
    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.customLoadingView = [STLoadingView loadingViewWithSize:self.view.frame.size];
    [self.view addSubview:self.customLoadingView];
    
    __weak typeof(self) weakSelf = self;
    [STDataAccessUtils getPostWithPostId:self.postId
                          withCompletion:^(NSArray *objects, NSError *error) {
                              typeof(self) strongSelf = weakSelf;
                              if (!strongSelf) {
                                  return ;
                              }
                              if (error || [objects count] == 0) {
                                  [strongSelf onCloseButtonPressed:nil];
                              }else{
                                  [strongSelf.customLoadingView removeFromSuperview];
                                  strongSelf.post = [objects firstObject];
                                  [strongSelf customizeScreen];
                                  [strongSelf customizeShareView];
                              }
                          }];
    
}

- (void)customizeScreen{
    //configure details string
    NSString *rankString = [NSString stringWithFormat:@"number %@", _top.rank];
    NSString *topName = @"Top Best Dressed People";
    NSString *likesString = [NSString stringWithFormat:@"%@", _top.likesCount];
    NSString *topTypeString = [self.top topTypeString];
    NSString *detailsString = [NSString stringWithFormat:@"Your outfit is %@ \nin %@ \n%@ with %@ likes!", rankString, topName, topTypeString, likesString];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:detailsString attributes:@{
                                                                                                                                                                                                    NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size: 16.0f],
                                                                                                                                                                                                    NSForegroundColorAttributeName: [UIColor colorWithWhite:0.0f alpha:1.0f],
                                                                                                                                                                                                    NSKernAttributeName: @(0.0)
                                                                                                                                                                                                    }];
    NSRange rankStringRange = [detailsString rangeOfString:rankString];
    NSRange topNameRange = [detailsString rangeOfString:topName];
    NSRange likesStringRange = [detailsString rangeOfString:likesString];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size: 16.0f] range:rankStringRange];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size: 16.0f] range:topNameRange];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size: 16.0f] range:likesStringRange];
    self.topShareDetailsLabel.attributedText = attributedString;
    
    //configure rank badge
    [self.topShareRankBadge configureWithTop:self.top];
    
    //configure post Image
    CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.post.imageSize, self.topSharePostImage.frame);
    
    CGFloat adjustedX = rect.origin.x - self.topSharePostImage.frame.origin.x;
    CGFloat adjustedY = rect.origin.y - self.topSharePostImage.frame.origin.y;
    
    self.topShareImageTopConstr.constant = self.topShareImageTopConstr.constant + adjustedY;
    self.topShareImageBottomConstr.constant = self.topShareImageBottomConstr.constant + adjustedY;
    self.topShareImageLeadingConstr.constant = self.topShareImageLeadingConstr.constant + adjustedX;
    self.topShareImageTrailingConstr.constant = self.topShareImageTrailingConstr.constant + adjustedX;
    
    [self.topSharePostImage sd_setImageWithURL:[NSURL URLWithString:self.post.mainImageUrl]completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        NSLog(@"error: %@", error);
    }];
    
    [self.view layoutSubviews];
}

- (void)customizeShareView{
    //configure details string
    NSString *rankString = [NSString stringWithFormat:@"number %@", _top.rank];
    NSString *topName = @"Top Best Dressed People";
    NSString *likesString = [NSString stringWithFormat:@"%@", _post.numberOfLikes];
    NSString *topTypeString = [self.top topTypeString];
    NSString *detailsString = [NSString stringWithFormat:@"My outfit is %@ \nin %@ \n%@ with %@ likes!", rankString, topName, topTypeString, likesString];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:detailsString attributes:@{
                                                                                                                               NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size: 16.0f],
                                                                                                                               NSForegroundColorAttributeName: [UIColor colorWithWhite:0.0f alpha:1.0f],
                                                                                                                               NSKernAttributeName: @(0.0)
                                                                                                                               }];
    NSRange rankStringRange = [detailsString rangeOfString:rankString];
    NSRange topNameRange = [detailsString rangeOfString:topName];
    NSRange likesStringRange = [detailsString rangeOfString:likesString];
    
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size: 16.0f] range:rankStringRange];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size: 16.0f] range:topNameRange];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Semibold" size: 16.0f] range:likesStringRange];
    self.shareDetailsLabel.attributedText = attributedString;
    
    //configure rank badge
    [self.shareRankBadge configureWithTop:self.top];
    
    //configure post Image
    CGRect rect = AVMakeRectWithAspectRatioInsideRect(self.post.imageSize, self.sharePostImage.frame);
    
    CGFloat adjustedX = rect.origin.x - self.sharePostImage.frame.origin.x;
    CGFloat adjustedY = rect.origin.y - self.sharePostImage.frame.origin.y;
    
    self.shareImageTopConstr.constant = self.shareImageTopConstr.constant + adjustedY;
    self.shareImageBottomConstr.constant = self.shareImageBottomConstr.constant + adjustedY;
    self.shareImageLeadingConstr.constant = self.shareImageLeadingConstr.constant + adjustedX;
    self.shareImageTrailingConstr.constant = self.shareImageTrailingConstr.constant + adjustedX;
    
    [self.sharePostImage sd_setImageWithURL:[NSURL URLWithString:self.post.mainImageUrl]];
    [self.shareView layoutSubviews];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

- (UIImage *) imageWithView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 2.0f);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage * snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return snapshotImage;
}

#pragma mark - IBActions

- (IBAction)onCloseButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onFacebookPressed:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    self.facebookSelected = btn.selected;
}
- (IBAction)onInstagramPressed:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = !btn.selected;
    self.instagramSelected = btn.selected;

}
- (IBAction)onSharePressed:(id)sender {
    if (self.facebookSelected ||
        self.instagramSelected) {
        self.shareImage = [self imageWithView:self.shareView];
    }
    if (self.facebookSelected) {
        [[CoreManager facebookService] shareTopImage:self.shareImage];
    }
    if (self.instagramSelected) {
        [[CoreManager instagramShareService] shareImageToStory:self.shareImage
                                                    contentURL:@"https://getstatus.co/" completion:^(STInstagramShareError error) {
                                                        if (error == STInstagramShareErrorNoInstragramApp) {
                                                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your phone does not appear to have Instagram app installed. Please install or update Instagram app on this device." preferredStyle:UIAlertControllerStyleAlert];
                                                            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                                                            [self presentViewController:alert animated:YES completion:nil];
                                                        }
                                                    }];
    }
}
@end
