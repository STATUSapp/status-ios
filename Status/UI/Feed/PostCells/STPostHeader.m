//
//  STPostHeader.m
//  Status
//
//  Created by Cosmin Andrus on 11/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STPostHeader.h"
#import "STPost.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Mask.h"
#import "CoreManager.h"
#import "STFacebookLoginController.h"

@interface STPostHeader ()
@property (weak, nonatomic) IBOutlet UIImageView *userThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *selectionButton;
@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@end

@implementation STPostHeader

- (void)configureCellWithPost:(STPost *)post{
    _userNameLabel.text = post.userName;
    BOOL currentUser = [post.userId isEqualToString:[CoreManager loginService].currentUserUuid];
    _messageButton.hidden = currentUser;
    [_userThumbnail sd_setImageWithURL: [NSURL URLWithString:post.smallPhotoUrl]completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        CGRect rect = _userThumbnail.frame;
        _userThumbnail.layer.cornerRadius = rect.size.width/2;
        _userThumbnail.layer.backgroundColor = [[UIColor clearColor] CGColor];
        _userThumbnail.layer.masksToBounds = YES;
    }];
}

- (void)configureForSection:(NSInteger)sectionIndex{
    _moreButton.tag = sectionIndex;
    _selectionButton.tag = sectionIndex;
    _messageButton.tag = sectionIndex;

}

-(void)prepareForReuse{
    [super prepareForReuse];
    _userNameLabel.text = @"";
    _userThumbnail.image = nil;
}

+ (CGSize)headerSize{
    CGSize size = [UIScreen mainScreen].bounds.size;

    return CGSizeMake(size.width, 58.f);
}
@end
