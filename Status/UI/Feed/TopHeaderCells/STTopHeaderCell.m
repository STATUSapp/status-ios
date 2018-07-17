//
//  STTopHeaderCell.m
//  Status
//
//  Created by Cosmin Andrus on 17/07/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STTopHeaderCell.h"
#import "UIImageView+Mask.h"
#import "UIImageView+WebCache.h"
#import "STPost.h"

@interface STTopHeaderCell ()
@property (weak, nonatomic) IBOutlet UIImageView *topOneImageView;
@property (weak, nonatomic) IBOutlet UILabel *topOneNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *topOneLikesLable;
@property (weak, nonatomic) IBOutlet UIImageView *topTwoImageView;
@property (weak, nonatomic) IBOutlet UILabel *topTwoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *topTwoLikesLabel;
@property (weak, nonatomic) IBOutlet UIImageView *topThreeImageView;
@property (weak, nonatomic) IBOutlet UILabel *topThreeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *topThreeLikesLabel;

@end

@implementation STTopHeaderCell


- (void)configureWithPosts:(NSArray <STPost *> *)posts
                     topId:(NSString *)topId{
    STPost *topOnePost = posts[0];
    STPost *topTwoPost =posts[1];
    STPost *topThreePost = posts[2];
    
    [self.topOneImageView topOneMask];
    NSURL *topOneImageURL = [NSURL URLWithString:topOnePost.smallPhotoUrl];
    [self.topOneImageView sd_setImageWithURL:topOneImageURL];
    self.topOneNameLabel.text = topOnePost.userName;
    STTopBase *topOne = [topOnePost topForTopId:topId];
    self.topOneLikesLable.text = [NSString stringWithFormat:@"%@", topOne.likesCount?:@(0)];
    
    [self.topTwoImageView topTwoMask];
    NSURL *topTwoImageURL = [NSURL URLWithString:topTwoPost.smallPhotoUrl];
    [self.topTwoImageView sd_setImageWithURL:topTwoImageURL];
    self.topTwoNameLabel.text = topTwoPost.userName;
    STTopBase *topTwo = [topTwoPost topForTopId:topId];
    self.topTwoLikesLabel.text = [NSString stringWithFormat:@"%@", topTwo.likesCount?:@(0)];
    [self.topTwoLikesLabel setTransform:CGAffineTransformMakeRotation(-M_PI / 30)];

    [self.topThreeImageView topThreeMask];
    NSURL *topThreeImageURL = [NSURL URLWithString:topThreePost.smallPhotoUrl];
    [self.topThreeImageView sd_setImageWithURL:topThreeImageURL];
    self.topThreeNameLabel.text = topThreePost.userName;
    STTopBase *topThree = [topThreePost topForTopId:topId];
    self.topThreeLikesLabel.text = [NSString stringWithFormat:@"%@", topThree.likesCount?:@(0)];
    [self.topThreeLikesLabel setTransform:CGAffineTransformMakeRotation(M_PI / 30)];

}
+ (CGSize)cellSize{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return CGSizeMake(screenSize.width, 372.f);
}
@end
