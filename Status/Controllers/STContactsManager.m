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

@implementation STContactsManager
+(instancetype) sharedInstance{
    static STContactsManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        [_sharedManager updateContactsList];
    });
    
    return _sharedManager;
}
- (void)fetchAllContacts {
    CFErrorRef *error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
    //TODO: add notification update
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
    CFRelease(allPeople);
    CFRelease(addressBook);
    CFRelease(source);
    
    _allContacts = [NSArray arrayWithArray:items];
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
}
@end
