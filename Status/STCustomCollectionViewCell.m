//
//  STCustomCollectionViewCell.m
//  Status
//
//  Created by silviu on 2/16/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//


#import "STCustomCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "STConstants.h"
#import "STImageCacheController.h"
#import "STWebServiceController.h"

@interface STCustomCollectionViewCell()
@property (weak, nonatomic) IBOutlet UIButton *profileNameBtn;
@property (weak, nonatomic) IBOutlet UIImageView *bigPictureImageView;
@property (weak, nonatomic) IBOutlet UIImageView *smallPictureImageView;
//@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIButton *likesNumberBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NSDictionary *setUpDict;

@end

@implementation STCustomCollectionViewCell
@synthesize bigPictureImageView = _bigPictureImageView;
@synthesize smallPictureImageView = _smallPictureImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setUpWithDictionary:(NSDictionary *)setupDict forFlowType:(int)flowType{
    [self setUpVisualsForFlowType:flowType];
    
    self.setUpDict = setupDict;
    
    //self.profileNameLabel.text = setupDict[@"user_name"];
    
    int numberOfLikes = [setupDict[@"number_of_likes"] intValue];
    NSString * likesString = (numberOfLikes == 1) ? @"Like" : @"Likes";
    
    [self.profileNameBtn setTitle:setupDict[@"user_name"] forState:UIControlStateNormal];
    [self.likesNumberBtn setTitle:[NSString stringWithFormat:@"%d %@", numberOfLikes, likesString] forState:UIControlStateNormal];
    self.likesNumberBtn.titleLabel.numberOfLines = 2;
    BOOL isLiked = [setupDict[@"post_liked_by_current_user"] boolValue];
    
    //[self.likeBtn setSelected:isLiked];
    if (isLiked) {
        [self.likeBtn setImage:[UIImage imageNamed:@"btn_liked"] forState:UIControlStateNormal];
        [self.likeBtn setImage:[UIImage imageNamed:@"btn_liked_pressed"] forState:UIControlStateHighlighted];
    }else{
        [self.likeBtn setImage:[UIImage imageNamed:@"btn_like_normal"] forState:UIControlStateNormal];
        [self.likeBtn setImage:[UIImage imageNamed:@"btn_like_pressed"] forState:UIControlStateHighlighted];
    }
    
    [self.likeBtn setNeedsDisplay];
    
    switch (flowType) {
        case STFlowTypeSinglePost:
        case STFlowTypeAllPosts:{
            [self setUpWithPicturesURLs:@[setupDict[@"full_photo_link"]]];
            break;
        }
        case STFlowTypeMyProfile:
        case STFlowTypeUserProfile:{
            [self setUpWithPicturesURLs:@[setupDict[@"full_photo_link"], setupDict[@"small_photo_link"]]];
            //self.profileNameLabel.text = [NSString stringWithFormat:@"%@ Profile ", self.profileNameLabel.text];
            [self.profileNameBtn setTitle:[NSString stringWithFormat:@"%@ Profile ", setupDict[@"user_name"]] forState:UIControlStateNormal];
            break;
        }
            
        default:
            break;
    }
    
    
}

- (void)setUpVisualsForFlowType: (int)flowType{
    
    // TO DO : highlight buttons or images for marking the flow
    
    switch (flowType) {
        case STFlowTypeSinglePost:
        case STFlowTypeAllPosts:{
            //self.profileNameLabel.hidden = NO;
            self.profileNameBtn.hidden = NO;
            //self.backBtn.hidden = YES;
            self.likesNumberBtn.hidden = NO;
            break;
        }
        case STFlowTypeMyProfile:
        case STFlowTypeUserProfile:{
            //self.profileNameLabel.hidden = NO;
            self.profileNameBtn.hidden = NO;
            self.backBtn.hidden = NO;
            self.likesNumberBtn.hidden = NO;
            break;
        }
        default:
            break;
    }
}


- (void)updateLikeBtn{

}

- (void)setUpWithPicturesURLs:(NSArray *)urlArray{
    
    __weak STCustomCollectionViewCell *weakSelf = self;
    
    if (urlArray.count == 1) {
        [[STImageCacheController sharedInstance] loadImageWithName:urlArray[0] andCompletion:^(UIImage *img) {
            weakSelf.bigPictureImageView.image=img;
            [weakSelf.activityIndicator stopAnimating];
            weakSelf.smallPictureImageView.hidden = YES;
        }];
    }
    else
    {
        [[STImageCacheController sharedInstance] loadImageWithName:urlArray[0] andCompletion:^(UIImage *img) {
            weakSelf.bigPictureImageView.image = img;
            [weakSelf.activityIndicator stopAnimating];
        }];
        [[STImageCacheController sharedInstance] loadImageWithName:urlArray[1] andCompletion:^(UIImage *img) {
            weakSelf.smallPictureImageView.hidden = FALSE;
            weakSelf.smallPictureImageView.image = img;
        }];
    }
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.bigPictureImageView.image = [UIImage imageNamed:@"placeholder"];
    [self.activityIndicator startAnimating];
    self.smallPictureImageView.image = nil;
    self.setUpDict = nil;
    self.bigPictureImageView.hidden = NO;
    self.smallPictureImageView.hidden = NO;
    self.likesNumberBtn.selected = NO;
}

- (NSString *)reuseIdentifier{
    return @"FlowCollectionCellIdentifier";
}

@end
