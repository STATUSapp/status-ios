//
//  STPostDetailsCell.m
//  Status
//
//  Created by Cosmin Andrus on 11/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STPostDetailsCell.h"
#import "STPost.h"
#import "NSDate+Additions.h"
#import "NSString+HashTags.h"

CGFloat const kDefaultCellHeigth = 98.f;
CGFloat const kDefaultTextWidthDelta = 20.f;

@interface STPostDetailsCell ()
@property (weak, nonatomic) IBOutlet UIButton *postLikesButton;
@property (weak, nonatomic) IBOutlet UILabel *postDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;

@end

@implementation STPostDetailsCell

- (void) configureCellWithPost:(STPost *)post{
    [_postLikesButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ likes", nil), post.numberOfLikes] forState:UIControlStateNormal];
    //add the space between title and image
    _postLikesButton.titleEdgeInsets = UIEdgeInsetsMake(0.f, 10.f, 0.f, 0.f);
    
    
    _postDescriptionLabel.attributedText = [STPostDetailsCell formattedCaptionStringForPost:post];

    if (post.postDate)
        _postDateLabel.text = [[NSDate timeAgoFromDate:post.postDate] uppercaseString];
    else
        _postDateLabel.text = NSLocalizedString(@"NA", nil);
}

+ (NSAttributedString *)formattedCaptionStringForPost:(STPost *)post{
    
    NSString *formattedString = [NSString stringWithFormat:@"%@\n%@", post.userName, post.caption];
    NSInteger nameLengh = [post.userName length];

    if (post.caption.length == 0) {
        formattedString = @"";
        nameLengh = 0;
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:formattedString];
    NSMutableAttributedString *mutableAttrString = [attributedString mutableCopy];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing: 3.0f];
    
    NSDictionary *nameAttributes = @{
                                 NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Semibold" size:14.0],
                                 NSForegroundColorAttributeName:[UIColor colorWithRed:26.f/255.f
                                                                                green:26.f/255.f
                                                                                 blue:26.f/255.f
                                                                                alpha:1.f],
                                 NSParagraphStyleAttributeName: paragraphStyle
};
    [mutableAttrString addAttributes:nameAttributes range:NSMakeRange(0, nameLengh)];

    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont fontWithName:@"ProximaNova-Regular" size:14.0],
                                 NSForegroundColorAttributeName:[UIColor colorWithRed:26.f/255.f
                                                                                green:26.f/255.f
                                                                                 blue:26.f/255.f
                                                                                alpha:1.f],
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    NSDictionary *hashTagAttributes = @{
                                        NSForegroundColorAttributeName: [UIColor colorWithRed:56.f/255.f
                                                                                        green:117.f/255.f
                                                                                         blue:242.f/255.f
                                                                                        alpha:1.f]};
    
    [mutableAttrString addAttributes:attributes range:NSMakeRange(nameLengh, attributedString.length - nameLengh)];
    
    NSArray *hasTags = [formattedString hashTags];
    for (NSString *hash in hasTags) {
        NSRange range = [formattedString rangeOfString:hash];
        [mutableAttrString addAttributes:hashTagAttributes range:range];
        
    }

    return mutableAttrString;
}

- (void)configureForSection:(NSInteger)sectionIndex{
    _postLikesButton.tag = sectionIndex;
    
}

+ (CGSize)cellSizeForPost:(STPost *)post{
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat captionHeight = 0.f;
    if (post.caption.length > 0) {
        NSAttributedString *formattedString = [STPostDetailsCell formattedCaptionStringForPost:post];
        CGRect paragraphRect =
        [formattedString boundingRectWithSize:CGSizeMake(size.width - kDefaultTextWidthDelta, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      context:nil];
        captionHeight = paragraphRect.size.height;

    }

    CGFloat inflatedHeight = kDefaultCellHeigth + captionHeight;
    if (inflatedHeight < 0) {
        inflatedHeight = 0.f;
    }
    return CGSizeMake(size.width, inflatedHeight);
}

@end
