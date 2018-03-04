//
//  STImageSuggestionsService.h
//  Status
//
//  Created by Cosmin Andrus on 28/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^STImageSuggestionsServiceCompletion)(NSArray *objects);
@class STShopProduct;

@interface STImageSuggestionsService : NSObject

-(void)startServiceWithImage:(UIImage *)image;
-(void)setSuggestionsCompletionBlock:(STImageSuggestionsServiceCompletion)completion;
-(void)setSimilarCompletionBlock:(STImageSuggestionsServiceCompletion)completion
                      forProduct:(STShopProduct *)product;

@end
