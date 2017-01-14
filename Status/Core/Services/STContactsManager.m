//
//  STContactsManager.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STContactsManager.h"
#import <Contacts/Contacts.h>
#import "STAddressBookContact.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "STFacebookHelper.h"
#import "STSyncContactsRequest.h"

@interface STContactsManager ()

@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) CNContactStore *contactStore;


@end

@implementation STContactsManager

-(instancetype)init{
    self = [super init];
    if (self) {
        _contactStore =[[CNContactStore alloc] init];
    }
    return self;
}

- (NSArray *) contactsList{
    return _allContacts;
}

- (void)fetchAllContacts {
    
    NSMutableArray* items = [NSMutableArray new];

    NSError *error = nil;
    
    NSArray *keys = [[NSArray alloc]initWithObjects:
                     CNContactIdentifierKey, CNContactEmailAddressesKey,
                     CNContactImageDataKey, CNContactPhoneNumbersKey,
                     CNContactGivenNameKey, CNContactMiddleNameKey,
                     CNContactFamilyNameKey, nil];
    
    // Create a request object
    CNContactFetchRequest *request = [[CNContactFetchRequest alloc] initWithKeysToFetch:keys];
    request.predicate = nil;
    
    [_contactStore enumerateContactsWithFetchRequest:request
                                              error:&error
                                         usingBlock:^(CNContact* __nonnull contact, BOOL* __nonnull stop)
     {
         if (contact) {
             STAddressBookContact *person = [STAddressBookContact contactWithPerson:contact];
             [items addObject:person];
         }
     }];
    _allContacts = [NSArray arrayWithArray:items];
    [self syncContactsWithTheServer];

}

-(void)updateContactsList{
    
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    
    if (status == CNAuthorizationStatusNotDetermined)
    {
        __weak STContactsManager *weakSelf = self;
        [_contactStore requestAccessForEntityType:CNEntityTypeContacts
                                completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                    if (granted) {
                                        [weakSelf fetchAllContacts];
                                    }
                                }];

    }
    else if( status == CNAuthorizationStatusDenied ||
       status == CNAuthorizationStatusRestricted)
    {
        NSLog(@"access denied");
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"You should grant access to the contacts list for STATUS App" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else
    {
        [self fetchAllContacts];
    }
}

-(void) syncContactsWithTheServer{
    [[CoreManager facebookService] loadUserFriendsWithCompletion:^(NSArray *newObjects) {
        NSLog(@"Final array %@", newObjects);
        NSArray *fbData = [NSArray arrayWithArray:newObjects];
        NSMutableArray *facebookFriends = [NSMutableArray new];
        for (NSDictionary *dict in fbData) {
            NSDictionary *serverDict = @{@"facebook_id":dict[@"id"]};
            [facebookFriends addObject:serverDict];
        }
        NSMutableArray *contactsEmails = [NSMutableArray new];
        for (STAddressBookContact *adrContact in _allContacts) {
            if ([[adrContact hasEmails] boolValue] == YES) {
                for (NSString *email in adrContact.emails) {
                    NSDictionary *dict = @{@"email": email};
                    [contactsEmails addObject:dict];
                }
            }
        }
        
        [STSyncContactsRequest syncLocalContacts:contactsEmails
                              andfacebookFriends:facebookFriends
                                  withCompletion:^(id response, NSError *error) {
                                      NSLog(@"Sync contacts success: %@", response);
            
        } failure:^(NSError *error) {
            NSLog(@"Error on sync the contacts: %@", error.debugDescription);
        }];
    }];
}
@end
