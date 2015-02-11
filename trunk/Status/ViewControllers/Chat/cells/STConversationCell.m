//
//  STConversationCell.m
//  Status
//
//  Created by Silviu on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STConversationCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+Mask.h"
#import "NSDate+Additions.h"

static NSString *kOfflineImageName = @"offline chat";
static NSString *kOnlineImageName = @"online chat";

@interface STConversationCell()

@property (weak, nonatomic) IBOutlet UILabel *fullNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLbl;
@property (weak, nonatomic) IBOutlet UIImageView *userChatStatus;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageTime;
@property (weak, nonatomic) IBOutlet UIButton *numberOfUnreadMessages;


@end

@implementation STConversationCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    _profileImageView.image = nil;
    _fullNameLbl.text = nil;
    _dateLbl.text = nil;
    _lastMessageLbl.text = nil;
    _userChatStatus.image = nil;
    _numberOfUnreadMessages.hidden = YES;
    
}

#pragma mark - Setup cell

- (void)setupWithProfileImageUrl:(NSString *)imageUrl
                     profileName:(NSString *)profileName
                     lastMessage:(NSString *)lastMessage
               dateOfLastMessage:(NSDate *)date
                   showsYouLabel:(BOOL)showsYouLabel
                     andIsUnread:(BOOL)isUnread {
    _fullNameLbl.text = profileName;
    _lastMessageLbl.text = lastMessage;
}

-(void)configureCellWithInfo:(NSDictionary *)info{
    NSString *imageUrl = info[@"small_photo_link"];
    if (![imageUrl isEqual:[NSNull null]]) {
        [_profileImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [_profileImageView maskImage:image];
        }];
    }
    NSString *lastMessage = info[@"last_message"];
    if (![lastMessage isKindOfClass:[NSString class]]) {
        lastMessage = @"";
    }
    _lastMessageLbl.text = lastMessage;
    _fullNameLbl.text = info[@"user_name"];
    BOOL isOnline = [info[@"is_online"] boolValue];
    _userChatStatus.image = [UIImage imageNamed:isOnline==YES?kOnlineImageName:kOfflineImageName];
    NSString *lastMessageTimeString = info[@"last_message_date"];
    if (lastMessageTimeString!=nil && ![lastMessageTimeString isKindOfClass:[NSNull class]]) {
        NSDate *lastMessageDate = [NSDate dateFromServerDate:lastMessageTimeString];
        _dateLbl.text = [NSDate timeStringForLastMessageDate:lastMessageDate];
    }
    else
        _dateLbl.text = @"NA";
    
    NSInteger numberOfUnreadMessages = [info[@"unread_messages_count"] integerValue];
    if (numberOfUnreadMessages > 0) {
        [_numberOfUnreadMessages setTitle:[NSString stringWithFormat:@"%ld", (long)numberOfUnreadMessages] forState:UIControlStateNormal];
        _numberOfUnreadMessages.hidden = NO;
    }
    else
        _numberOfUnreadMessages.hidden = YES;

}

@end
