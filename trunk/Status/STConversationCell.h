//
//  STConversationCell.h
//  Status
//
//  Created by Silviu on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STConversationCell : UITableViewCell

- (void)setupWithProfileImageUrl:(NSString *)imageUrl
                     profileName:(NSString *)profileName
                     lastMessage:(NSString *)lastMessage
               dateOfLastMessage:(NSDate *)date
                   showsYouLabel:(BOOL)showsYouLabel
                     andIsUnread:(BOOL)isUnread;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@end
