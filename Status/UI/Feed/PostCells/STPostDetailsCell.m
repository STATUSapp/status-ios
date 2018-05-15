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

CGFloat const kDefaultCellHeigth = 98.f;
CGFloat const kDefaultTextWidthDelta = 20.f;

@interface STPostDetailsCell ()
@property (weak, nonatomic) IBOutlet UIButton *postLikesButton;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *postDescriptionTextView;
@end

@implementation STPostDetailsCell

- (void) configureCellWithPost:(STPost *)post{
    [_postLikesButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"%@ likes", nil), post.numberOfLikes] forState:UIControlStateNormal];
    //add the space between title and image
    _postLikesButton.titleEdgeInsets = UIEdgeInsetsMake(0.f, 10.f, 0.f, 0.f);
    
    
    _postDescriptionTextView.attributedText = [post formattedCaptionString];
    _postDescriptionTextView.editable = NO;
    NSDictionary *hashTagAttributes = @{
                                        NSForegroundColorAttributeName: [UIColor colorWithRed:56.f/255.f
                                                                                        green:117.f/255.f
                                                                                         blue:242.f/255.f
                                                                                        alpha:1.f]};
    _postDescriptionTextView.linkTextAttributes = hashTagAttributes;
    if (post.postDate)
        _postDateLabel.text = [[NSDate timeAgoFromDate:post.postDate] uppercaseString];
    else
        _postDateLabel.text = NSLocalizedString(@"NA", nil);
}

- (void)configureForSection:(NSInteger)sectionIndex{
    _postLikesButton.tag = sectionIndex;
    _postDescriptionTextView.tag = sectionIndex;
    
}

+ (CGSize)cellSizeForPost:(STPost *)post{
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat captionHeight = 0.f;
    if (post.caption.length > 0) {
        NSAttributedString *formattedString = [post formattedCaptionString];
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
