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
#import "STLoginService.h"

@interface STPostHeader ()
@property (weak, nonatomic) IBOutlet UIImageView *userThumbnail;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreButton;
@property (weak, nonatomic) IBOutlet UIButton *selectionButton;
//@property (weak, nonatomic) IBOutlet UIButton *messageButton;

@end

@implementation STPostHeader

- (void)configureCellWithPost:(STPost *)post{
    _userNameLabel.text = post.userName;
    [_userThumbnail sd_setImageWithURL: [NSURL URLWithString:post.smallPhotoUrl] placeholderImage:[UIImage imageNamed:@"boy"]
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 CGRect rect = self.userThumbnail.frame;
                                 self.userThumbnail.layer.cornerRadius = rect.size.width/2;
                                 self.userThumbnail.layer.backgroundColor = [[UIColor clearColor] CGColor];
                                 self.userThumbnail.layer.masksToBounds = YES;
                             }];
}

- (void)configureForSection:(NSInteger)sectionIndex{
    _moreButton.tag = sectionIndex;
    _selectionButton.tag = sectionIndex;
//    _messageButton.tag = sectionIndex;

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
