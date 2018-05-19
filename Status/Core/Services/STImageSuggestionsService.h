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

typedef void (^STImageSuggestionsServiceCompletion)(NSArray *objects);
typedef void (^STImageSuggestionsCommitCompletion)(NSError *error, NSArray *objects);

@class STShopProduct;

@interface STImageSuggestionsService : NSObject

-(void)startServiceWithImage:(UIImage *)image;
-(BOOL)canCommitCurrentPost;
-(void)commitCurrentPostWithCaption:(NSString *)caption
                          imageData:(NSData *)imageData
                       shopProducts:(NSArray<STShopProduct *> *)shopProducts
                         completion:(STImageSuggestionsCommitCompletion)completion;

-(void)setSuggestionsCompletionBlock:(STImageSuggestionsServiceCompletion)completion;
-(void)setSimilarCompletionBlock:(STImageSuggestionsServiceCompletion)completion
                      forProduct:(STSuggestedProduct *)product;

-(void)changeBaseSuggestion:(STSuggestedProduct *)baseSuggestion
             withSuggestion:(STSuggestedProduct *)suggestion;
-(void)removeSuggestion:(STSuggestedProduct *)suggestion;
@end
