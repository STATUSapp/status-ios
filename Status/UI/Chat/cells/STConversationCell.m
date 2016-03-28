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
#import "STConversationUser.h"

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

-(void)configureCellWithConversationUser:(STConversationUser *)cu{
    NSString *imageUrl = cu.thumbnail;
    [_profileImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [_profileImageView maskImage:image];
    }];
    NSString *lastMessage = cu.lastMessage;
    _lastMessageLbl.text = lastMessage;
    _fullNameLbl.text = cu.userName;
    BOOL isOnline = cu.isOnline;
    _userChatStatus.image = [UIImage imageNamed:isOnline==YES?kOnlineImageName:kOfflineImageName];
    if (cu.lastMessageDate) {
        _dateLbl.text = [NSDate timeStringForLastMessageDate:cu.lastMessageDate];
    }
    else
        _dateLbl.text = @"NA";
    
    NSInteger numberOfUnreadMessages = cu.unreadMessageCount;
    if (numberOfUnreadMessages > 0) {
        [_numberOfUnreadMessages setTitle:[NSString stringWithFormat:@"%ld", (long)numberOfUnreadMessages] forState:UIControlStateNormal];
        _numberOfUnreadMessages.hidden = NO;
    }
    else
        _numberOfUnreadMessages.hidden = YES;

}

@end
