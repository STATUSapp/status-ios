//
//  STConversationUser.m
//  Status
//
//  Created by Andrus Cosmin on 21/03/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STConversationUser.h"
#import "CreateDataModelHelper.h"
#import "NSDate+Additions.h"

@implementation STConversationUser
+(STConversationUser *)conversationUserFromDict:(NSDictionary *)dict{
    STConversationUser *cu = [STConversationUser new];
    cu.uuid = [CreateDataModelHelper validStringIdentifierFromValue:dict[@"user_id"]];
    cu.infoDict = dict;
    cu.isOnline = [dict[@"is_online"] boolValue];
    cu.lastMessage = [CreateDataModelHelper validObjectFromDict:cu.infoDict forKey:@"last_message"];
    NSString *dateString = [CreateDataModelHelper validObjectFromDict:cu.infoDict forKey:@"last_message_date"];
    if (dateString) {
        NSDate *date = [NSDate dateFromServerDateTime:dateString];
        cu.lastMessageDate = date;
    }
    cu.thumbnail = [CreateDataModelHelper validObjectFromDict:cu.infoDict forKey:@"small_photo_link"];
    cu.unreadMessageCount = [cu.infoDict[@"unread_messages_count"] integerValue];
    cu.userName = [CreateDataModelHelper validObjectFromDict:cu.infoDict forKey:@"user_name"];
    
    return cu;
    
}
@end
