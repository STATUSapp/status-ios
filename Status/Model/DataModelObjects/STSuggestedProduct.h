//
//  STSuggestedProduct.h
//  Status
//
//  Created by Cosmin Andrus on 17/05/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STProductBase.h"

@interface STSuggestedProduct : STProductBase

+ (instancetype)suggestedProductWithDict:(NSDictionary *)postDict;

@end
