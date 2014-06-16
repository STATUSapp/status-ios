//
//  STConversationCell.m
//  Status
//
//  Created by Silviu on 01/06/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STConversationCell.h"
#import "UIImageView+AFNetworking.h"

@interface STConversationCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *dateLbl;
@property (weak, nonatomic) IBOutlet UILabel *lastMessageLbl;
@property (weak, nonatomic) IBOutlet UILabel *youLbl;
@property (weak, nonatomic) IBOutlet UIImageView *readStateImageView;


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
    _youLbl.hidden = YES;
    _readStateImageView.hidden = YES;
}

#pragma mark - Setup cell

- (void)setupWithProfileImageUrl:(NSString *)imageUrl
                     profileName:(NSString *)profileName
                     lastMessage:(NSString *)lastMessage
               dateOfLastMessage:(NSDate *)date
                   showsYouLabel:(BOOL)showsYouLabel
                     andIsUnread:(BOOL)isUnread {
    [_profileImageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
    _fullNameLbl.text = profileName;
    _lastMessageLbl.text = lastMessage;
    _youLbl.hidden = !showsYouLabel;
    _readStateImageView.hidden = !isUnread;
    
    // TODO: setup cell
    // find a placeholder image
    // set date
    
    
}

@end
