//
//  STContactsManager.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STContactsManager.h"
#import <AddressBook/AddressBook.h>
#import "STAddressBookContact.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "STFacebookHelper.h"
#import "STSyncContactsRequest.h"

@interface STContactsManager ()

@property (nonatomic, strong) NSArray *allContacts;

@end

@implementation STContactsManager

-(instancetype)init{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSArray *) contactsList{
    return _allContacts;
}

- (void)fetchAllContacts {
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);

    ABRecordRef source = ABAddressBookCopyDefaultSource(addressBook);
    CFArrayRef allPeople = (ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, source, kABPersonSortByFirstName));
    //CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    CFIndex nPeople = CFArrayGetCount(allPeople); // bugfix who synced contacts with facebook
    NSMutableArray* items = [NSMutableArray arrayWithCapacity:nPeople];
    
    if (!allPeople || !nPeople) {
        NSLog(@"people nil");
    }
    
    
    for (int i = 0; i < nPeople; i++) {
        
        @autoreleasepool {
            
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
            STAddressBookContact *contact = [STAddressBookContact contactWithPerson:person];
            [items addObject:contact];
            
        }
    }
    if (allPeople)
        CFRelease(allPeople);
    
    CFRelease(addressBook);
    CFRelease(source);
    
    _allContacts = [NSArray arrayWithArray:items];
    [self syncContactsWithTheServer];
}

-(void)updateContactsList{
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    __weak STContactsManager *weakSelf = self;
    void(^statusCompletion)(bool, CFErrorRef) = ^void(bool granted, CFErrorRef error){
        if (granted==YES) {
            [weakSelf fetchAllContacts];
        }
    };
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, statusCompletion);
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        
        [self fetchAllContacts];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Warning" message:@"You should grant access to the contacts list for STATUS App" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];

    }
    
    CFRelease(addressBookRef);
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
