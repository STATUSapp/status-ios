//
//  STFacebookAddCell.m
//  Status
//
//  Created by Cosmin Andrus on 09/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STFacebookAddCell.h"
#import "STAdPost.h"
#import "STFacebookAdModel.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Mask.h"
#import "NSString+HashTags.h"

CGFloat const kFacebookAdHeaderHeight = 58.f;
CGFloat const kFacebookAdMediaRation = 320.f/167.f;
CGFloat const kFacebookAdCTAHeight = 46.f;
CGFloat const kFacebookAdCaptionVerticalOffset = 16.f;
CGFloat const kFacebookAdCaptionHorizontalOffset = 32.f;

@interface STFacebookAddCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstr;
@property (weak, nonatomic) IBOutlet UIImageView *adIcon;
@property (weak, nonatomic) IBOutlet UILabel *adTitle;
@property (weak, nonatomic) IBOutlet UIImageView *adMediaImage;
@property (weak, nonatomic) IBOutlet UIButton *CTAButton;
@property (weak, nonatomic) IBOutlet UILabel *adBody;

@end

@implementation STFacebookAddCell

-(void)configureWithAdPost:(STAdPost *)adPost{
    _headerHeightConstr.constant = kFacebookAdHeaderHeight;
    NSURL *adIconUrl = adPost.adModel.nativeAd.icon.url;
    __weak STFacebookAddCell *weakSelf = self;
    [_adIcon sd_setImageWithURL: adIconUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong STFacebookAddCell *strongSelf = weakSelf;
        CGRect rect = strongSelf.adIcon.frame;
        strongSelf.adIcon.layer.cornerRadius = rect.size.width/2;
        strongSelf.adIcon.layer.backgroundColor = [[UIColor clearColor] CGColor];
        strongSelf.adIcon.layer.masksToBounds = YES;

    }];
    _adTitle.text = adPost.adModel.nativeAd.title;
    NSURL *mediaUrl = adPost.adModel.nativeAd.coverImage.url;
    [_adMediaImage sd_setImageWithURL:mediaUrl];
    [_CTAButton setTitle:adPost.adModel.nativeAd.callToAction forState:UIControlStateNormal];
    _adBody.attributedText = [STFacebookAddCell formattedCaptionStringForPostCaption:adPost];
    [adPost.adModel.nativeAd registerViewForInteraction:self.contentView withViewController:nil];
}

+ (NSAttributedString *)formattedCaptionStringForPostCaption:(STAdPost *)adPost{
    
    NSString *formattedString = [NSString stringWithFormat:@"%@", adPost.adModel.nativeAd.rawBody];
    
//    NSString *bodyString = adPost.adModel.nativeAd.body;
//    
//    NSLog(@"RawBody: %@\nBody:%@", formattedString, bodyString);
    if (formattedString.length == 0) {
        formattedString = @"";
    }
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:formattedString];
    NSMutableAttributedString *mutableAttrString = [attributedString mutableCopy];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [paragraphStyle setLineSpacing: 3.0f];
    
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
    
    [mutableAttrString addAttributes:attributes range:NSMakeRange(0, attributedString.length)];
    
    NSArray *hasTags = [formattedString hashTags];
    for (NSString *hash in hasTags) {
        NSRange range = [formattedString rangeOfString:hash];
        [mutableAttrString addAttributes:hashTagAttributes range:range];
        
    }
    
    return mutableAttrString;
}

+(CGSize)cellSizeWithAdPost:(STAdPost *)adPost{
    if (adPost.adModel.adLoaded) {
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        NSAttributedString *formattedString = [STFacebookAddCell formattedCaptionStringForPostCaption:adPost];
        CGRect paragraphRect =
        [formattedString boundingRectWithSize:CGSizeMake(screenSize.width - kFacebookAdCaptionHorizontalOffset, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                      context:nil];
        CGFloat mediaHeight = screenSize.width / kFacebookAdMediaRation;
        CGFloat height = kFacebookAdHeaderHeight + mediaHeight + kFacebookAdCTAHeight + kFacebookAdCaptionVerticalOffset + paragraphRect.size.height;
        return CGSizeMake(screenSize.width, height+1);
    }
    return CGSizeZero;
}
@end
