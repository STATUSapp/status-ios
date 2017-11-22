//
//  STPost.m
//  Status
//
//  Created by Cosmin Home on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

/*
 
 {
 "app_version" = "1.0.17";
 caption = "vine, vine, primavara#STATUS ";
 "full_photo_link" = "http://d22t200r9sgmit.cloudfront.net/img/x84nn5dnesnyphxyvij-56bf6b0f8b5da.jpg";
 "is_owner" = 0;
 "number_of_likes" = 6;
 "post_date" = "2016-02-13 19:42:45";
 "post_id" = 11734;
 "post_liked_by_current_user" = 0;
 "report_status" = 1;
 "small_photo_link" = "http://d22t200r9sgmit.cloudfront.net/img/nc2e4hcooaduaibtl99z-56c235e2eb1d1.jpg";
 "user_id" = 188;
 "user_name" = "Nadie Todirica";
 }
 
 */

#import "STPost.h"
#import "NSDate+Additions.h"
#import "STImageCacheController.h"
#import "STShopProduct.h"
#import "STPostsPool.h"
#import "NSString+HashTags.h"

@interface STPost()

@property (nonatomic, strong) NSAttributedString *attributesString;
@property (nonatomic, strong, readwrite) NSArray *hashtagRangeArray;

@end

@implementation STPost
+ (instancetype)postWithDict:(NSDictionary *)postDict {
    STPost * post = [STPost new];
    post.infoDict = postDict;
    [post setup];
    
    return post;
}

-(void)setup{
    self.appVersion = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"app_version"];
    _caption = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"caption"];
    if (_caption == nil) {
        _caption = @"";
    }
    _isOwner = [self.infoDict[@"is_owner"] boolValue];
    _numberOfLikes = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"number_of_likes"];
    
    _postDate = [NSDate dateFromServerDateTime:self.infoDict[@"post_date"]];
    self.uuid = [CreateDataModelHelper validStringIdentifierFromValue:self.infoDict[@"post_id"]];
    _postLikedByCurrentUser = [self.infoDict[@"post_liked_by_current_user"] boolValue];
    _reportStatus = self.infoDict[@"report_status"];
    _smallPhotoUrl = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"small_photo_link"];
    _userId = [CreateDataModelHelper validStringIdentifierFromValue:self.infoDict[@"user_id"]];
    _userName = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"user_name"];
    _postSeen = [self.infoDict[@"post_seen"] boolValue];
    _shareShortUrl = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"short_url"];
    
    self.shopProducts = @[];

    //super properties
    self.mainImageUrl = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"full_photo_link"] stringByReplacingHttpWithHttps];
    self.mainImageDownloaded = [STImageCacheController imageDownloadedForUrl:self.mainImageUrl];
    self.imageSize = [STImageCacheController imageSizeForUrl:self.mainImageUrl];
    
//#ifdef DEBUG
//    self.userName = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit.";
//    self.caption = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed auctor vitae eros imperdiet placerat. Integer lacinia quam elit, et ultrices dui scelerisque ultricies. Vestibulum quis ultrices enim, vitae blandit turpis. In in lorem lacus. Integer malesuada nisl rhoncus elit dignissim placerat. Praesent ut dui fermentum, condimentum lacus ac, rhoncus quam. Cras eget neque sed sapien facilisis maximus. Quisque leo tortor, tempus a maximus ut, interdum vel risus.";
//#endif
    
    NSArray *products = self.infoDict[@"shop_style_products"];
//#ifdef DEBUG
//    NSMutableArray *mockProducts = [NSMutableArray new];
//    NSInteger productsCount = [self.uuid integerValue] % 10;
//    for (int i =0; i<productsCount; i++) {
//        NSDictionary *product = @{@"link": @"http://www.emag.ro/",
//                         @"image": @"http://is4.barenecessities.com/is/image/BareNecessities/le945_almond1?$Main375x440$"};
//        [mockProducts addObject:product];
//    }
//    products = [NSArray arrayWithArray:mockProducts];
//#endif
    if (products && products.count) {
        NSMutableArray *productsArray = [NSMutableArray new];
        
        for (NSDictionary *productDict in products) {
            STShopProduct *product = [STShopProduct shopProductWithDict:productDict];
            [productsArray addObject:product];
        }
        self.shopProducts = [NSArray arrayWithArray:productsArray];
    }
    

    STPost *postFromPool = [[CoreManager postsPool] getPostWithId:self.uuid];
    if (postFromPool) {
        //copy local variable from present pool object
        _showFullCaption = postFromPool.showFullCaption;
        _showShopProducts = postFromPool.showShopProducts;

    }
    else{
        _showFullCaption = NO;
        _showShopProducts = NO;
    }

}

-(BOOL)isAdPost{
    return NO;
}

- (NSAttributedString *)formattedCaptionString{
    if (!_attributesString) {
        NSString *formattedString = [NSString stringWithFormat:@"%@\n%@", _userName, _caption];
        NSInteger nameLengh = [_userName length];
        
        if (_caption.length == 0) {
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
        NSMutableArray *ranges = [@[] mutableCopy];
        for (NSString *hash in hasTags) {
            NSRange range = [formattedString rangeOfString:hash];
            [ranges addObject:NSStringFromRange(range)];
            [mutableAttrString addAttributes:hashTagAttributes range:range];
            [mutableAttrString addAttribute:NSLinkAttributeName value:@"hashtag" range:range];

        }
        
        _hashtagRangeArray = [NSArray arrayWithArray:ranges];
        _attributesString = [[NSAttributedString alloc] initWithAttributedString:mutableAttrString];
    }
    return _attributesString;
}

-(void)resetCaptionAndHashtags{
    _hashtagRangeArray = nil;
    _attributesString = nil;
}

-(NSString *)hasttagForRange:(NSRange )range{
    return [[_attributesString attributedSubstringFromRange:range] string];
}

@end
