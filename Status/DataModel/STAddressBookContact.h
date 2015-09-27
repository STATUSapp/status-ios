//
//  STAddressBookContact.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

@interface STAddressBookContact : NSObject
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSArray *emails;
@property (nonatomic, strong) NSArray *phones;
@property (nonatomic, strong) NSData *thumbnail;
@property (nonatomic, strong) NSNumber *selected;
+(STAddressBookContact *)contactWithPerson:(ABRecordRef) person;

-(NSNumber *)hasEmails;
-(NSNumber *)hasPhones;
-(NSString *)fullName;
@end
