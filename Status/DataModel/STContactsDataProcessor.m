//
//  STContactsDataProcessor.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STContactsDataProcessor.h"
#import "STContactsManager.h"
#import "STAddressBookContact.h"
#import "STInviteFriendsByEmailRequest.h"

@interface STContactsDataProcessor()
@property (nonatomic) STContactsProcessorType processorType;
@end

@implementation STContactsDataProcessor
-(instancetype)initWithType:(STContactsProcessorType) processorType{
    self = [super init];
    if (self) {
        _processorType = processorType;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"hasEmails == 1"];
        if (_processorType == STContactsProcessorTypePhones) {
            predicate = [NSPredicate predicateWithFormat:@"hasPhones == 1"];
        }

        _items = [[[STContactsManager sharedInstance] allContacts] filteredArrayUsingPredicate:predicate];
        
        NSLog(@"Items: %@", [_items valueForKey:@"firstName"]);
    }
    return self;
}

-(void)switchSelectionForObjectAtIndex:(NSInteger)index{
    if (index >= [_items count]) {
        return;
    }
    STAddressBookContact *contact = [_items objectAtIndex:index];
    contact.selected = @(![contact.selected boolValue]);
}

-(STAddressBookContact *)objectAtindex:(NSInteger)index{
    if (index >= [_items count]) {
        return nil;
    }
    return [_items objectAtIndex:index];
}

-(void) commitForViewController:(UIViewController <MFMessageComposeViewControllerDelegate> *)viewController{
    if (_processorType == STContactsProcessorTypeEmails) {
        //sent to the server
        [self inviteFriendsToJoinStatus];
    }
    else if (_processorType == STContactsProcessorTypePhones){
        //open sms with all seleted numbers
        [self inviteFriendsViaSmsForViewController:viewController];
    }
}

-(void)inviteFriendsViaSmsForViewController:(UIViewController<MFMessageComposeViewControllerDelegate> *) viewController{
    NSMutableArray *numbers = [NSMutableArray new];
    for (STAddressBookContact *contact in _items) {
        if ([contact.selected boolValue] == YES) {
            [numbers addObjectsFromArray:contact.phones];
        }
    }
    if (numbers.count > 0) {
        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
        if([MFMessageComposeViewController canSendText])
        {
            //TODO: add another custom message
            controller.body = @"SMS message here";
            controller.recipients = numbers;
            controller.messageComposeDelegate = viewController;
            [viewController presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device is not able to send messages" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }
}

-(void) inviteFriendsToJoinStatus{
    NSMutableArray *friends = [NSMutableArray new];
    for (STAddressBookContact *contact in _items) {
        if ([contact.selected boolValue]==YES) {
            for (NSString *email in contact.emails) {
                NSDictionary *dict = @{@"email":email, @"name": [contact fullName]};
                [friends addObject:dict];
            }
        }
    }
    if (friends.count > 0) {
        [[STInviteFriendsByEmailRequest new] inviteFriends:friends withCompletion:^(id response, NSError *error) {
            NSLog(@"response: %@", response);
            
        }];
    }
}
@end
