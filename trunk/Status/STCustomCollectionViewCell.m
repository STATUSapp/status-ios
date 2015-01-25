//
//  STCustomCollectionViewCell.m
//  Status
//
//  Created by silviu on 2/16/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//


#import "STCustomCollectionViewCell.h"
#import "STConstants.h"
#import "STImageCacheController.h"
#import "STNetworkQueueManager.h"
#import "STFlowTemplateViewController.h"
#import "STFacebookLoginController.h"

static const NSInteger kCaptionShadowTag = 101;

@interface STCustomCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIButton *profileNameBtn;
@property (weak, nonatomic) IBOutlet UIImageView *fullBlurImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fitImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *likesNumberBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *bigCameraProfileBtn;
@property (weak, nonatomic) IBOutlet UILabel *noPhotosLabel;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIButton *captionButton;
@property (weak, nonatomic) IBOutlet UIView *captionView;

@property (strong, nonatomic) NSDictionary *setUpDict;

@end

@implementation STCustomCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)updateLikeBtnAndLblWithDict:(NSDictionary *)setUpDict {
    int numberOfLikes = [setUpDict[@"number_of_likes"] intValue];
    [self.likesNumberBtn setTitle:[NSString stringWithFormat:@"%d", numberOfLikes] forState:UIControlStateNormal];
    self.likesNumberBtn.titleLabel.numberOfLines = 2;
    BOOL isLiked = [setUpDict[@"post_liked_by_current_user"] boolValue];
    
    if (isLiked) {
        [self.likeBtn setImage:[UIImage imageNamed:@"btn_liked"] forState:UIControlStateNormal];
        [self.likeBtn setImage:[UIImage imageNamed:@"btn_liked_pressed"] forState:UIControlStateHighlighted];
    }else{
        [self.likeBtn setImage:[UIImage imageNamed:@"btn_like_normal"] forState:UIControlStateNormal];
        [self.likeBtn setImage:[UIImage imageNamed:@"btn_like_pressed"] forState:UIControlStateHighlighted];
    }
    
    [self.likeBtn setNeedsDisplay];
}

- (void)setUpWithDictionary:(NSDictionary *)setupDict forFlowType:(int)flowType{
    // if setupDict is nil, the cell will be setted as a placeholder
    if ([setupDict[@"type"] isEqualToString:@"placeholder"]) {
        if ([setupDict[@"content_loaded"] boolValue] == YES) {
            [self setupAsPlaceholderForFlowType:flowType];
            return;
        }
        else
        {
            [self.contentView bringSubviewToFront:_fullBlurImageView];
            [self.contentView bringSubviewToFront:_activityIndicator];
            [self.activityIndicator startAnimating];
            return;
        }
    }
    [self.contentView sendSubviewToBack:_fullBlurImageView];
//    [_activityIndicator stopAnimating];

    [self setUpVisualsForFlowType:flowType];
    
    self.setUpDict = setupDict;
    [self setUpCaptionForEdit:NO];
    [self.profileNameBtn setTitle:setupDict[@"user_name"] forState:UIControlStateNormal];
    [self updateLikeBtnAndLblWithDict:setupDict];
    
    switch (flowType) {
        case STFlowTypeSinglePost:
        case STFlowTypeAllPosts:{
            [self setUpWithPicturesURLs:@[setupDict[@"full_photo_link"]]];
            break;
        }
        case STFlowTypeDiscoverNearby:{
            [self setUpWithPicturesURLs:@[setupDict[@"full_photo_link"], setupDict[@"small_photo_link"]]];
            [self.profileNameBtn setTitle:[NSString stringWithFormat:@"%@", setupDict[@"user_name"]] forState:UIControlStateNormal];
            break;
        }
        case STFlowTypeMyProfile:
        case STFlowTypeUserProfile:{
            [self setUpWithPicturesURLs:@[setupDict[@"full_photo_link"], setupDict[@"small_photo_link"]]];
            [self.profileNameBtn setTitle:[NSString stringWithFormat:@"%@ Profile ", setupDict[@"user_name"]] forState:UIControlStateNormal];
            break;
        }
            
        default:
            break;
    }
    NSString *appVersion = setupDict[@"app_version"];
    if (appVersion == nil ||
        [appVersion isKindOfClass:[NSNull class]] ||
        [appVersion rangeOfString:@"1.0."].location == NSNotFound ||
        flowType == STFlowTypeMyProfile ||
        flowType == STFlowTypeSinglePost) {
        _chatButton.hidden = YES;
    }
    else
        _chatButton.hidden = NO;
    
    
}

- (void)setUpVisualsForFlowType: (STFlowType)flowType{
    
    self.profileNameBtn.layer.shadowOpacity = 1.0;
    self.profileNameBtn.layer.shadowRadius = 2;
    self.profileNameBtn.layer.shadowOffset = CGSizeMake(3.0f, 1.0f);
    
    switch (flowType) {
        case STFlowTypeSinglePost:
        case STFlowTypeAllPosts:{
            self.profileNameBtn.hidden = NO;
            self.likesNumberBtn.hidden = NO;
            break;
        }
        case STFlowTypeDiscoverNearby:
        case STFlowTypeMyProfile:
        case STFlowTypeUserProfile:{
            self.profileNameBtn.hidden = NO;
            self.likesNumberBtn.hidden = NO;
            break;
        }
        default:
            break;
    }
    
    self.bigCameraProfileBtn.hidden = YES;
    self.noPhotosLabel.hidden = YES;
}

- (void)setupAsPlaceholderForFlowType:(STFlowType)type{
    [self.contentView sendSubviewToBack:_fullBlurImageView];
    self.bigCameraProfileBtn.hidden = NO;
    self.fullBlurImageView.hidden = NO;
    self.fullBlurImageView.image = [UIImage imageNamed:@"placeholder STATUS loading"];
    
    self.likeBtn.hidden = YES;
    self.captionButton.hidden = YES;
    self.likesNumberBtn.hidden = YES;
    self.shareBtn.hidden = YES;
    _chatButton.hidden = YES;
    self.noPhotosLabel.hidden = NO;
    [self.profileNameBtn setTitle:[NSString stringWithFormat:@"%@ Profile ", self.username] forState:UIControlStateNormal];
    
    [self.activityIndicator stopAnimating];
    
    switch (type) {
        case STFlowTypeMyProfile:{
            self.noPhotosLabel.text = @"You don't have any photo. Take a photo";
            break;
        }
        case STFlowTypeUserProfile:{
            self.noPhotosLabel.text = [NSString stringWithFormat:@"Ask %@ to take a photo", self.username];
            break;
        }
        default:
            break;
    }
}

-(void)setUpPlaceholderBeforeLoading{
    [self.contentView bringSubviewToFront:_fullBlurImageView];
    self.fullBlurImageView.image = [UIImage imageNamed:@"placeholder STATUS loading"];
}

- (void)setUpWithPicturesURLs:(NSArray *)urlArray{
    __weak STCustomCollectionViewCell *weakSelf = self;
    
    [[STImageCacheController sharedInstance] loadPostImageWithName:urlArray[0] withPostCompletion:^(UIImage *img) {
        
        if (img!=nil) {
            weakSelf.fitImageView.image = img;
            [weakSelf.activityIndicator stopAnimating];
            
        }
    } andBlurCompletion:^(UIImage *bluredImg) {
        if (bluredImg!=nil) {
            weakSelf.fullBlurImageView.image=bluredImg;
        }
    }];
}

-(void)setUpCaptionForEdit:(BOOL)editFlag{
    NSString *caption = self.setUpDict[@"caption"];
    if (caption == nil || ![caption isKindOfClass:[NSString class]]) {
        caption = @"";
    }
    _captionLabel.text = caption;
    if (editFlag == NO) {//SeeMore
        [_captionButton setTitle:@"See more" forState:UIControlStateNormal];
        _captionButton.tag = 110;
        _captionButton.hidden = NO;
        
        if ([self.setUpDict[@"user_id"] isEqualToString:[STFacebookLoginController sharedInstance].currentUserId]) {
            if (caption.length == 0) {
                [_captionButton setTitle:@"Edit" forState:UIControlStateNormal];
                _captionButton.tag = 111;
            }
        }
        else
            _captionButton.hidden = caption.length == 0;
    }
    else
    {
        [_captionButton setTitle:@"Edit" forState:UIControlStateNormal];
        _captionButton.tag = 111;
        if (![self.setUpDict[@"user_id"] isEqualToString:[STFacebookLoginController sharedInstance].currentUserId])
            _captionButton.hidden = YES;


    }
}

-(void)addCaptionShadow{
    
    CGSize bounds = self.bounds.size;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    button.tag = kCaptionShadowTag;
    [button addTarget:self action:@selector(captionShadowPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor blackColor];
    button.alpha = 0.5;
    [self.contentView addSubview:button];
    [self.contentView bringSubviewToFront:_captionView];
    [self setUpCaptionForEdit:YES];
}

-(void)captionShadowPressed:(id)sender{
    UIButton *captionBt = (UIButton *)[self.contentView viewWithTag:kCaptionShadowTag];
    [captionBt removeFromSuperview];
    [self setUpCaptionForEdit:NO];
    [UIView animateWithDuration:0.3 animations:^{
        _heightConstraint.constant = 75.f;
    } completion:nil];
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.fullBlurImageView.image = [UIImage imageNamed:@"placeholder STATUS loading"];
    self.fitImageView.image = nil;
    [self.activityIndicator startAnimating];
    self.setUpDict = nil;
    self.likesNumberBtn.selected = NO;
    self.fullBlurImageView.hidden = NO;
    self.fitImageView.hidden = NO;

    self.bigCameraProfileBtn.hidden = YES;
    self.likeBtn.hidden = NO;
    [self setUpCaptionForEdit:NO];
    self.likesNumberBtn.hidden = NO;
    self.shareBtn.hidden = NO;
    self.noPhotosLabel.hidden = YES;
    _heightConstraint.constant = 75.f;
    UIButton *captionBt = (UIButton *)[self.contentView viewWithTag:kCaptionShadowTag];
    [captionBt removeFromSuperview];

}

- (NSString *)reuseIdentifier{
    return @"FlowCollectionCellIdentifier";
}

@end
