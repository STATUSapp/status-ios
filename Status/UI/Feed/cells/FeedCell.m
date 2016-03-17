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

NSString *const kChatMinimumVersion = @"1.0.4";
CGFloat const kCaptionMargins = 28.f;
CGFloat const kCaptionDefaultHeight = 21.f;
CGFloat const kSeeMoreButtonWidthConstant = 56.f;

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
@end

@implementation FeedCell

-(void)configureCellWithPost:(STPost *)post{
    _currentPost = post;
    [_nameButton setTitle:_currentPost.userName forState:UIControlStateNormal];
    [_likeButton setTitle:_currentPost.postLikedByCurrentUser?NSLocalizedString(@"LIKED", nil):NSLocalizedString(@"LIKE", nil) forState:UIControlStateNormal];
    _messageButton.enabled = [_currentPost.appVersion isGreaterThanEqualWithVersion:kChatMinimumVersion];
    [self configureBottomView];
    
    __weak FeedCell *weakSelf = self;
    
    [[CoreManager imageCacheService] loadPostImageWithName:post.fullPhotoUrl withPostCompletion:^(UIImage *img) {
        
        if (img!=nil) {
            weakSelf.normalImage.image = img;
            
        }
    } andBlurCompletion:^(UIImage *bluredImg) {
        if (bluredImg!=nil) {
            weakSelf.blurImageView.image=bluredImg;
        }
    }];
    
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
