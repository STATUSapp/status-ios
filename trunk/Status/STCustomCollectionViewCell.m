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
#import "UIImageView+Mask.h"
#import "UIImageView+WebCache.h"

static const NSInteger kCaptionShadowTag = 101;
static NSString *kLikeButtonName = @"like button";
static NSString *kLikeButtonPressedName = @"like button pressed";
static NSString *kLikedButtonName = @"liked";
static NSString *kLikedButtonPressedName = @"liked pressed";


@interface STCustomCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIButton *profileNameBtn;
@property (weak, nonatomic) IBOutlet UIImageView *fullBlurImageView;
@property (weak, nonatomic) IBOutlet UIImageView *fitImageView;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *likesNumberBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *chatButton;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIButton *captionButton;
@property (weak, nonatomic) IBOutlet UIView *captionView;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileImg;

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

-(void)awakeFromNib{
    [self.contentView bringSubviewToFront:_fullBlurImageView];
    [self.contentView bringSubviewToFront:_activityIndicator];
}

- (void)updateLikeBtnAndLblWithDict:(NSDictionary *)setUpDict {
    int numberOfLikes = [setUpDict[@"number_of_likes"] intValue];
    [self.likesNumberBtn setTitle:[NSString stringWithFormat:@"%d", numberOfLikes] forState:UIControlStateNormal];
    self.likesNumberBtn.titleLabel.numberOfLines = 2;
    BOOL isLiked = [setUpDict[@"post_liked_by_current_user"] boolValue];
    
    if (isLiked) {
        [self.likeBtn setImage:[UIImage imageNamed:kLikedButtonName] forState:UIControlStateNormal];
        [self.likeBtn setImage:[UIImage imageNamed:kLikedButtonPressedName] forState:UIControlStateHighlighted];
    }else{
        [self.likeBtn setImage:[UIImage imageNamed:kLikeButtonName] forState:UIControlStateNormal];
        [self.likeBtn setImage:[UIImage imageNamed:kLikeButtonPressedName] forState:UIControlStateHighlighted];
    }
    
    [self.likeBtn setNeedsDisplay];
}

- (void)setUpWithDictionary:(NSDictionary *)setupDict forFlowType:(int)flowType{
    [self.contentView sendSubviewToBack:_fullBlurImageView];

    [self setUpVisualsForFlowType:flowType];
    
    self.setUpDict = setupDict;
    [self setUpCaptionForEdit:NO];
    [self.profileNameBtn setTitle:setupDict[@"user_name"] forState:UIControlStateNormal];
    [self updateLikeBtnAndLblWithDict:setupDict];
    
    switch (flowType) {
        case STFlowTypeSinglePost:
        case STFlowTypeAllPosts:{
            [self setUpWithPicturesURLs:@[setupDict[@"full_photo_link"],setupDict[@"small_photo_link"]]];
            break;
        }
        case STFlowTypeDiscoverNearby:{
            [self setUpWithPicturesURLs:@[setupDict[@"full_photo_link"], setupDict[@"small_photo_link"]]];
            [self.profileNameBtn setTitle:[NSString stringWithFormat:@"%@", setupDict[@"user_name"]] forState:UIControlStateNormal];
            break;
        }
        case STFlowTypeMyGallery:
        case STFlowTypeUserGallery:{
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
        flowType == STFlowTypeMyGallery ||
        flowType == STFlowTypeSinglePost) {
        _chatButton.hidden = YES;
    }
    else
        _chatButton.hidden = NO;
    
    
}

- (void)setUpVisualsForFlowType: (STFlowType)flowType{
    
//    self.profileNameBtn.layer.shadowOpacity = 1.0;
//    self.profileNameBtn.layer.shadowRadius = 2;
//    self.profileNameBtn.layer.shadowOffset = CGSizeMake(3.0f, 1.0f);
    
    switch (flowType) {
        case STFlowTypeSinglePost:
        case STFlowTypeAllPosts:{
            self.profileNameBtn.hidden = NO;
            self.likesNumberBtn.hidden = NO;
            break;
        }
        case STFlowTypeDiscoverNearby:
        case STFlowTypeMyGallery:
        case STFlowTypeUserGallery:{
            self.profileNameBtn.hidden = NO;
            self.likesNumberBtn.hidden = NO;
            break;
        }
        default:
            break;
    }
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
    
    [_userProfileImg sd_setImageWithURL:[NSURL URLWithString:urlArray[1]] placeholderImage:[UIImage imageNamed:@"btn_nrLIkes_normal"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [weakSelf.userProfileImg maskImage:image];
        [weakSelf.contentView bringSubviewToFront:_captionView];

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
        _captionButton.tag = 111;
        if (![self.setUpDict[@"user_id"] isEqualToString:[STFacebookLoginController sharedInstance].currentUserId])
            _captionButton.hidden = YES;
        else
            [_captionButton setTitle:@"Edit" forState:UIControlStateNormal];
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

    self.likeBtn.hidden = NO;
    [self setUpCaptionForEdit:NO];
    self.likesNumberBtn.hidden = NO;
    self.shareBtn.hidden = NO;
    _heightConstraint.constant = 75.f;
    UIButton *captionBt = (UIButton *)[self.contentView viewWithTag:kCaptionShadowTag];
    [captionBt removeFromSuperview];
    //this is for the cell to show loading
    [self.contentView bringSubviewToFront:_fullBlurImageView];
    [self.contentView bringSubviewToFront:_activityIndicator];

}

- (NSString *)reuseIdentifier{
    return @"FlowCollectionCellIdentifier";
}

@end
