//
//  STLikeUser.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 31/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STSuggestedUser.h"

@interface STListUser : STSuggestedUser
+(STListUser *)listUserWithDict:(NSDictionary *)dict;
@end
