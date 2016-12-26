//
//  STPostImageCell.m
//  Status
//
//  Created by Cosmin Andrus on 11/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STPostImageCell.h"
#import "STPost.h"
#import "UIImageView+WebCache.h"
#import "STImageCacheController.h"
#import "DGActivityIndicatorView.h"

@interface STPostImageCell ()
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurEffectView;
@property (weak, nonatomic) IBOutlet DGActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *postLikeButton;
@property (weak, nonatomic) IBOutlet UIButton *postShopButton;
@property (weak, nonatomic) IBOutlet UIImageView *downShadow;

@end

@implementation STPostImageCell

-(void)awakeFromNib{
    [super awakeFromNib];
    _activityIndicator.tintColor = [UIColor blackColor];
    _activityIndicator.type = DGActivityIndicatorAnimationTypeBallClipRotate;
    [_activityIndicator startAnimating];
}

-(void)prepareForReuse{
    _postImage.image = nil;
    _blurEffectView.hidden = NO;
    [self setBottomItemsHidden:YES];
    
}

-(void)setBottomItemsHidden:(BOOL)hidded{
    _postLikeButton.hidden = _postShopButton.hidden = _downShadow.hidden = hidded;
}
- (void) configureCellWithPost:(STPost *)post{
    if (post.mainImageDownloaded) {
        [self setBottomItemsHidden:NO];
        [[CoreManager imageCacheService] loadPostImageWithName:post.mainImageUrl withPostCompletion:^(UIImage *origImg) {
            [_activityIndicator stopAnimating];
            _blurEffectView.hidden = YES;
            _postImage.image = origImg;
        }];
    }
    else if (post.thumbnailImageDownloaded)
    {
        [self setBottomItemsHidden:NO];
        [[CoreManager imageCacheService] loadPostImageWithName:post.thumbnailPhotoUrl withPostCompletion:^(UIImage *origImg) {
            [_activityIndicator startAnimating];
            _blurEffectView.hidden = NO;
            _postImage.image = origImg;
        }];
        
    }
    _postLikeButton.selected = post.postLikedByCurrentUser;
    _postShopButton.hidden = (post.shopProducts.count == 0);
    _postShopButton.selected = post.showShopProducts;
    
}

- (void)configureForSection:(NSInteger)sectionIndex{
    _postLikeButton.tag = sectionIndex;
    _postShopButton.tag = sectionIndex;
}

+ (CGSize)celSizeForPost:(STPost *)post{
    CGSize size = [UIScreen mainScreen].applicationFrame.size;

//    if (!post.mainImageDownloaded &&
//        !post.thumbnailImageDownloaded) {
//        return CGSizeMake(size.width, 0.f);
//    }
    if (!post.mainImageDownloaded) {
        return CGSizeMake(size.width, size.width);
    }
    
    CGFloat shrinkFactor = size.width/post.imageSize.width;
    CGFloat inflatedHeight = post.imageSize.height * shrinkFactor;
    if (inflatedHeight < 0) {
        inflatedHeight = 0;
    }
    return CGSizeMake(size.width, inflatedHeight);
    
}

@end
