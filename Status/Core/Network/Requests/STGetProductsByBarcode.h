//
//  STGetProductsByBarcode.h
//  Status
//
//  Created by Cosmin Andrus on 20/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STGetProductsByBarcode : STBaseRequest

+ (void)getProductsByBarcode:(NSString *)barcodeString
                andPageIndex:(NSInteger)pageIndex
               andCompletion:(STRequestCompletionBlock)completion
                     failure:(STRequestFailureBlock)failure;
@end
