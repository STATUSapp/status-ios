//
//  FeedCell.m
//  Status
//
//  Created by Cosmin Home on 06/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "FeedCell.h"
#import "STPost.h"
#import "NSString+VersionComparison.h"
#import "NSDate+Additions.h"
#import "STImageCacheController.h"
#import "STFacebookLoginController.h"

CGFloat const kCaptionMargins = 28.f;
CGFloat const kCaptionDefaultHeight = 21.f;
CGFloat const kSeeMoreButtonWidthConstant = 56.f;
CGFloat const kUserNameWidthOffset = 180.f;

@interface FeedCell ()

@property (nonatomic, strong) STPost *currentPost;

@property (weak, nonatomic) IBOutlet UIImageView *blurImageView;
@property (weak, nonatomic) IBOutlet UIImageView *normalImage;
@property (weak, nonatomic) IBOutlet UIButton *nameButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UIButton *seeMoreButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *seeMoreButtonWidthConstr;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *likesButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userNameWidthConstr;
@end

@implementation FeedCell

-(void)configureCellWithPost:(STPost *)post{
    _currentPost = post;
    UIFont *font = _nameButton.titleLabel.font;
    
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    
    CGFloat maxTextWidth = mainWindow.frame.size.width-kUserNameWidthOffset;
    
    CGRect rect = [_currentPost.userName boundingRectWithSize:CGSizeMake(maxTextWidth, _nameButton.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];

    _userNameWidthConstr.constant = round(rect.size.width) + 8.f;
    
    [_nameButton setTitle:_currentPost.userName forState:UIControlStateNormal];
    
    [_likeButton setTitle:_currentPost.postLikedByCurrentUser?NSLocalizedString(@"LIKED", nil):NSLocalizedString(@"LIKE", nil) forState:UIControlStateNormal];

    _messageButton.enabled = [_currentPost.appVersion isGreaterThanEqualWithVersion:kChatMinimumVersion];
    [self configureBottomView];
    
    __weak FeedCell *weakSelf = self;
    
    [[CoreManager imageCacheService] loadPostImageWithName:post.mainImageUrl withPostCompletion:^(UIImage *img) {
        
        if (img!=nil) {
            weakSelf.normalImage.image = img;
            
        }
    } andBlurCompletion:^(UIImage *bluredImg) {
        if (bluredImg!=nil) {
            weakSelf.blurImageView.image=bluredImg;
        }
    }];
    
    if ([post.userId isEqualToString:[CoreManager loginService].currentUserUuid]) {
        _likeButton.hidden = _messageButton.hidden = YES;
    }
    else
    {
        _likeButton.hidden = _messageButton.hidden = NO;
        
    }
}

-(void)configureBottomView{
    //calculate the layout
    UIFont *font = [UIFont fontWithName:@"ProximaNova-Regular" size:13.f];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    
    CGFloat textWidth = mainWindow.frame.size.width-kCaptionMargins;

    CGRect rect = [_currentPost.caption boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
    
    if (rect.size.height <= kCaptionDefaultHeight){
        _seeMoreButton.hidden = YES;
        _seeMoreButtonWidthConstr.constant = 0.f;
    }
    else
    {
        _seeMoreButton.hidden = NO;
        _seeMoreButtonWidthConstr.constant = kSeeMoreButtonWidthConstant;
        
    }

    [_seeMoreButton invalidateIntrinsicContentSize];

    _captionLabel.text = _currentPost.caption;
    [_likesButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ likes", nil), _currentPost.numberOfLikes] forState:UIControlStateNormal];
    if (_currentPost.postDate)
        _timeLabel.text = [NSDate timeStringForLastMessageDate:_currentPost.postDate];
    else
        _timeLabel.text = NSLocalizedString(@"NA", nil);

}

@end
