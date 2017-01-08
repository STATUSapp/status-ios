//
//  STSuggestedUser.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@interface STSuggestedUser : STBaseObj
@property(nonatomic, strong) NSNumber *followedByCurrentUser;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *thumbnail;
@property (nonatomic, assign) STProfileGender gender;

+(STSuggestedUser *)suggestedUserWithDict:(NSDictionary *)dict;

- (NSString *)genderImage;
@end
