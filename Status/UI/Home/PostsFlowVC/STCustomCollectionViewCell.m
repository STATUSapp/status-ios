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
#import "NSDate+Additions.h"
#import "CreateDataModelHelper.h"
#import "STChatController.h"

static const NSInteger kCaptionShadowTag = 101;
static NSString *kLikeButtonName = @"like button";
static NSString *kLikeButtonPressedName = @"like button pressed";
static NSString *kLikedButtonName = @"liked";
static NSString *kLikedButtonPressedName = @"liked pressed";
NSInteger const kCaptionMarginOffset = 25.f;    //modify this according with the layout changes


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
@property (weak, nonatomic) IBOutlet UIView *postDateView;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editPostWidthContraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seeMoreWidthContraint;
@property (weak, nonatomic) IBOutlet UIButton *editPostButton;

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
    
    NSString *postTimeString = setupDict[@"post_date"];
    if (postTimeString!=nil && ![postTimeString isKindOfClass:[NSNull class]]) {
        NSDate *postDate = [NSDate dateFromServerDateTime:postTimeString];
        _postDateLabel.text = [NSDate timeStringForLastMessageDate:postDate];
    }
    else
        _postDateLabel.text = @"NA";
    
    switch (flowType) {
        case STFlowTypeSinglePost:
        case STFlowTypePopular:
        case STFlowTypeHome:
        case STFlowTypeRecent:
        {
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
    BOOL canChatWithUser = [STChatController allowChatWithVersion:appVersion];
    if (appVersion == nil ||
        [appVersion isKindOfClass:[NSNull class]] ||
        flowType == STFlowTypeMyGallery ||
        flowType == STFlowTypeSinglePost) {
        _chatButton.hidden = YES;
    }
    else
        _chatButton.hidden = !canChatWithUser;
    
    
}

- (void)setUpVisualsForFlowType: (STFlowType)flowType{
    
//    self.profileNameBtn.layer.shadowOpacity = 1.0;
//    self.profileNameBtn.layer.shadowRadius = 2;
//    self.profileNameBtn.layer.shadowOffset = CGSizeMake(3.0f, 1.0f);
    
    switch (flowType) {
        case STFlowTypeSinglePost:
        case STFlowTypePopular:
        case STFlowTypeRecent:
        case STFlowTypeHome:
        {
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
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:14.f];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    
    CGFloat textWidth = mainWindow.frame.size.width-kCaptionMarginOffset;
    CGRect rect = [caption boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];

    _captionLabel.text = caption;
    NSString *userId = [CreateDataModelHelper validStringIdentifierFromValue:self.setUpDict[@"user_id"]];
    if (editFlag == NO) {//SeeMore
        _captionButton.hidden = NO;
        _seeMoreWidthContraint.constant = 66.f;
        _editPostButton.hidden = YES;
        _editPostWidthContraint.constant = 0.f;
        BOOL wrapped = NO;
        if (rect.size.height > _captionLabel.bounds.size.height){
            wrapped = YES;
        }
        if ([userId isEqualToString:[[CoreManager loginService] currentUserUuid]]) {
            if (caption.length == 0 || wrapped == NO) {
                _captionButton.hidden = YES;
                _seeMoreWidthContraint.constant = 0.f;
                _editPostButton.hidden = NO;
                _editPostWidthContraint.constant = 90.f;
            }
        }
        _captionButton.hidden = !wrapped;
        if(wrapped==NO)
            _seeMoreWidthContraint.constant = 0.f;
    }
    else
    {
        if (![userId isEqualToString:[[CoreManager loginService] currentUserUuid]])
        {
            _captionButton.hidden = YES;
            _seeMoreWidthContraint.constant = 12.f;
            _editPostButton.hidden = YES;
            _editPostWidthContraint.constant = 0.f;
        }
        else{
            _captionButton.hidden = YES;
            _seeMoreWidthContraint.constant = 12.f;
            _editPostButton.hidden = NO;
            _editPostWidthContraint.constant = 90.f;

        }
    }
}

-(void)addCaptionShadowWithExtraSpace:(CGFloat)extrHeight{
    
    CGSize bounds = self.bounds.size;
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    button.tag = kCaptionShadowTag;
    [button addTarget:self action:@selector(captionShadowPressed:) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = [UIColor blackColor];
    button.alpha = 0.0;
    [self.contentView addSubview:button];
    [self.contentView bringSubviewToFront:_captionView];
    [self setUpCaptionForEdit:YES];
    _heightConstraint.constant = 70.f + extrHeight;
    [UIView animateWithDuration:0.33 animations:^{
        button.alpha = 0.5f;
        [self layoutIfNeeded];
    } completion:nil];
    

}

-(void)captionShadowPressed:(id)sender{
    UIButton *captionBt = (UIButton *)[self.contentView viewWithTag:kCaptionShadowTag];
    _heightConstraint.constant = 90.f;
    [self layoutIfNeeded];
    [self setUpCaptionForEdit:NO];
    [UIView animateWithDuration:0.33 animations:^{
        captionBt.alpha = 0.f;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [captionBt removeFromSuperview];
    }];
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
    _heightConstraint.constant = 90.f;
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
