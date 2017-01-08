//
//  STConversationUser.h
//  Status
//
//  Created by Andrus Cosmin on 21/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@interface STConversationUser : STBaseObj
@property (nonatomic, assign) BOOL isOnline;
@property (nonatomic, strong) NSString *lastMessage;
@property (nonatomic, strong) NSDate *lastMessageDate;
@property (nonatomic, assign) BOOL messageRead;
@property (nonatomic, assign) NSInteger unreadMessageCount;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, assign) STProfileGender gender;

+(STConversationUser *)conversationUserFromDict:(NSDictionary *)dict;
@end
