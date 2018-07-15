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
#import "STShopProduct.h"
#import "STPostsPool.h"
#import "NSString+HashTags.h"

@interface STPost()

@property (nonatomic, strong) NSAttributedString *attributesString;
@property (nonatomic, strong, readwrite) NSArray *hashtagRangeArray;

@property (nonatomic, strong, readwrite) STTopBase *dailyTop;
@property (nonatomic, strong, readwrite) STTopBase *weeklyTop;
@property (nonatomic, strong, readwrite) STTopBase *monthlyTop;

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
    NSString *shortUrl = [CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"short_url"];
    _shareShortUrl = [shortUrl stringByAddingHttp];
    
    self.shopProducts = @[];

    //super properties
    self.mainImageUrl = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"full_photo_link"] stringByReplacingHttpWithHttps];
    CGFloat imageHeight = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"post_image_height"] doubleValue];
    CGFloat imageWidth = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"post_image_width"] doubleValue];
    CGFloat imageRatio = [[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"post_image_ratio"] doubleValue];
    [self saveDimentionsWithImageHeight:imageHeight
                             imageRatio:imageRatio
                             imageWidth:imageWidth];
    NSArray *products = self.infoDict[@"shop_style_products"];
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
        _showShopProducts = (self.shopProducts.count > 0);
    }
    
    self.dailyTop = [STTopBase dailyTopWithInfo:[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"daily_top"]];
    self.weeklyTop = [STTopBase weeklyTopWithInfo:[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"weekly_top"]];
    self.monthlyTop = [STTopBase monthlyTopWithInfo:[CreateDataModelHelper validObjectFromDict:self.infoDict forKey:@"monthly_top"]];
    
    self.dailyTop = [STTopBase mockDailyTop];
    self.weeklyTop = [STTopBase mockWeeklyTop];
    self.monthlyTop = [STTopBase mockMonthlyTop];
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
//        NSDictionary *hashTagAttributes = @{
//                                            NSForegroundColorAttributeName: [UIColor colorWithRed:56.f/255.f
//                                                                                            green:117.f/255.f
//                                                                                             blue:242.f/255.f
//                                                                                            alpha:1.f]};
        
        [mutableAttrString addAttributes:attributes range:NSMakeRange(nameLengh, attributedString.length - nameLengh)];
        
        NSArray *hasTags = [formattedString hashTags];
        NSMutableArray *ranges = [@[] mutableCopy];
        for (NSString *hash in hasTags) {
            NSRange range = [formattedString rangeOfString:hash];
            [ranges addObject:NSStringFromRange(range)];
            [mutableAttrString addAttribute:NSLinkAttributeName value:@"hashtag" range:range];
//            [mutableAttrString addAttributes:hashTagAttributes range:range];

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

-(STTopBase *)bestOfTops{
    NSMutableArray <STTopBase *> *ranks = [NSMutableArray new];
    
    if (self.dailyTop) {
        [ranks addObject:self.dailyTop];
    }
    if (self.weeklyTop) {
        [ranks addObject:self.weeklyTop];
    }
    if (self.monthlyTop) {
        [ranks addObject:self.monthlyTop];
    }
    NSLog(@"Top ranks: %@", [ranks valueForKey:@"rank"]);
    [ranks sortUsingComparator:^NSComparisonResult(STTopBase *obj1, STTopBase *obj2) {
        return [obj1 compare:obj2];
    }];

    return [ranks firstObject];
}

@end
