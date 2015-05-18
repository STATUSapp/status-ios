//
//  STSuggestedUser.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@interface STSuggestedUser : STBaseObj
@property(nonatomic) BOOL followedByCurrentUser;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *thumbnail;
+(STSuggestedUser *)suggestedUserWithDict:(NSDictionary *)dict;
@end
