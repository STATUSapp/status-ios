//
//  STProductSuggestRequest.h
//  Status
//
//  Created by Cosmin Andrus on 21/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STProductSuggestRequest : STBaseRequest

+ (void)suggestProductWithBarcode:(NSString *)barcodeString
                            brand:(NSString *)brand
                      productName:(NSString *)productName
                            store:(NSString *)store
                    andCompletion:(STRequestCompletionBlock)completion
                          failure:(STRequestFailureBlock)failure;

@end
