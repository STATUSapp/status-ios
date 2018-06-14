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
#import "STLoginService.h"
#import "STNavigationService.h"

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

        _items = [[[CoreManager contactsService] contactsList] filteredArrayUsingPredicate:predicate];
        
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
        if([MFMessageComposeViewController canSendText])
        {
            MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
            NSString *bodyString = [NSString stringWithFormat:@"Your friend %@ invites you on Get STATUS. Download the app from App Store: http://bit.ly/STATUSiOS  or Google Play: http://bit.ly/STATUSAndroid", [[CoreManager loginService] currentUserFullName]];
            controller.body = bodyString;
            controller.recipients = numbers;
            controller.messageComposeDelegate = viewController;
            [viewController presentViewController:controller animated:YES completion:nil];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Your device is not able to send messages." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            
            [[CoreManager navigationService] presentAlertController:alert];
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
