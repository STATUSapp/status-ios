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
#import "DGActivityIndicatorView.h"
#import "UIView+AnimatedZoom.h"
#import "UILabel+TopRanking.h"

CGFloat likeAnimationDuration = 0.9f;
CGFloat likeAnimationZoomInProportion = 1.f/4.f;

@interface STPostImageCell ()
@property (weak, nonatomic) IBOutlet UIImageView *postImage;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurEffectView;
@property (weak, nonatomic) IBOutlet DGActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *postLikeButton;
@property (weak, nonatomic) IBOutlet UIButton *postShopButton;
@property (weak, nonatomic) IBOutlet UIImageView *downShadow;
@property (weak, nonatomic) IBOutlet UIImageView *likedImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkedImageWidthConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *linkButtonWidthConstr;
@property (weak, nonatomic) IBOutlet UILabel *topBadge;

@property (assign, nonatomic) BOOL likeImageAnimationInProgress;
@end

@implementation STPostImageCell

-(void)awakeFromNib{
    [super awakeFromNib];
    _activityIndicator.tintColor = [UIColor blackColor];
    _activityIndicator.type = DGActivityIndicatorAnimationTypeBallClipRotate;
    [_activityIndicator startAnimating];
    _likedImage.hidden = YES;
}

-(void)prepareForReuse{
    _blurEffectView.hidden = NO;
    _likeImageAnimationInProgress = NO;
    [self setBottomItemsHidden:YES];
    [self.postImage sd_cancelCurrentAnimationImagesLoad];
    [self.activityIndicator startAnimating];
}

-(void)setBottomItemsHidden:(BOOL)hidded{
    _postLikeButton.hidden = _postShopButton.hidden = _downShadow.hidden = hidded;
}
- (void) configureCellWithPost:(STPost *)post{
    [self setBottomItemsHidden:NO];
    STTopBase *relevantTop = [post bestOfTops];
    [self.topBadge configureWithTop:relevantTop];
    __weak typeof(self) weakSelf = self;
    [self.postImage sd_setImageWithURL:[NSURL URLWithString:post.mainImageUrl]
                      placeholderImage:nil
                               options:SDWebImageProgressiveDownload
                             completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                   if (image) {
                                       __strong typeof(weakSelf) strongSelf = weakSelf;
                                       [strongSelf.activityIndicator stopAnimating];
                                       strongSelf.blurEffectView.hidden = YES;
                                       [UIView transitionWithView:strongSelf.postImage
                                                         duration:0.2f
                                                          options:UIViewAnimationOptionTransitionCrossDissolve
                                                       animations:^{
                                                           strongSelf.postImage.image = image;
                                                       } completion:nil];
                                   }
                               }];
    _postLikeButton.selected = post.postLikedByCurrentUser;
    _postShopButton.hidden = (post.shopProducts.count == 0);
    _postShopButton.selected = post.showShopProducts;
    
}

- (void)configureForSection:(NSInteger)sectionIndex{
    _postLikeButton.tag = sectionIndex;
    _postShopButton.tag = sectionIndex;
}

-(void)animateShopButton{
    [self.postShopButton animateZoom:1.1];
}

-(void) animateLikedImage{
    if (_likeImageAnimationInProgress) {
        NSLog(@"Animation skipped since there is one in progress!!!");
        return;
    }
    _linkedImageWidthConstr.constant = 0.f;
    _likedImage.hidden = NO;
    _likedImage.alpha = 1.f;
    [self.contentView layoutIfNeeded];
    _linkedImageWidthConstr.constant = 80.f;
    _likeImageAnimationInProgress = YES;
    CGFloat zoomInDuration = likeAnimationZoomInProportion * likeAnimationDuration;
    CGFloat zoomOutDuration = (1.f - likeAnimationZoomInProportion)/likeAnimationDuration;
    [UIView animateWithDuration:zoomInDuration
                          delay:0.f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         [self.contentView layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.linkedImageWidthConstr.constant = 70.f;
                         [UIView animateWithDuration:zoomOutDuration
                                               delay:0.f
                                             options:UIViewAnimationOptionBeginFromCurrentState
                                          animations:^{
                                              [self.contentView layoutIfNeeded];
                                              self.likedImage.alpha = 0.7;

                                          } completion:^(BOOL finished) {
                                              self.likeImageAnimationInProgress = NO;
                                              self.likedImage.hidden = YES;
                                          }];
                     }];
}

+ (CGSize)celSizeForPost:(STPost *)post{
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat shrinkFactor = [post.imageRatio doubleValue];
    if (shrinkFactor == 0) {
        return CGSizeMake(size.width, 0.f);
    }
    CGFloat inflatedHeight = size.width * (1.f/shrinkFactor);
    return CGSizeMake(size.width, inflatedHeight);
    
}

@end
