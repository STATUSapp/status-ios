//
//  STInviteFriendsByEmailRequest.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseRequest.h"

@interface STInviteFriendsByEmailRequest : STBaseRequest
@property (nonatomic, strong) NSArray *friends;
- (void)inviteFriends:(NSArray *)friends
       withCompletion:(STRequestCompletionBlock)completion;
@end
