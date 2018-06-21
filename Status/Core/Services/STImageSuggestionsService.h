//
//  STImageSuggestionsService.h
//  Status
//
//  Created by Cosmin Andrus on 28/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class STSuggestedProduct;
@class STShopProduct;
typedef NS_ENUM(NSUInteger, STSuggestionsStatus) {
    STSuggestionsStatusLoading = 0,
    STSuggestionsStatusLoadedWithError,
    STSuggestionsStatusLoadedNoProducts,
    STSuggestionsStatusLoaded,
    STSuggestionsStatusCount
};
typedef void (^STImageSuggestionsServiceCompletion)(NSArray *objects);
typedef void (^STImageSuggestionsCommitCompletion)(NSError *error, NSArray *objects);

@class STShopProduct;

@interface STImageSuggestionsService : NSObject

-(void)startServiceWithImage:(UIImage *)image;
-(BOOL)canCommitCurrentPost;
-(void)commitCurrentPostWithCaption:(NSString *)caption
                              image:(UIImage *)image
                       shopProducts:(NSArray<STShopProduct *> *)shopProducts
                         completion:(STImageSuggestionsCommitCompletion)completion;

-(void)setSuggestionsCompletionBlock:(STImageSuggestionsServiceCompletion)completion;
-(void)setSimilarCompletionBlock:(STImageSuggestionsServiceCompletion)completion
                      forProduct:(STSuggestedProduct *)product;

-(void)changeBaseSuggestion:(STSuggestedProduct *)baseSuggestion
             withSuggestion:(STSuggestedProduct *)suggestion;
-(void)removeSuggestion:(STSuggestedProduct *)suggestion;
-(STSuggestionsStatus)getServiceStatus;
-(void)changePostImage:(UIImage *)newPostImage;
-(void)retry;

-(CGFloat)temporaryProgressValue;
-(NSTimeInterval)temporaryProgressTimeframe;

@end
