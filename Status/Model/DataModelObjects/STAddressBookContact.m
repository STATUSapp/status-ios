//
//  STAddressBookContact.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STAddressBookContact.h"

@implementation STAddressBookContact
-(NSNumber *)hasEmails{
    return @([_emails count] > 0);
}
-(NSNumber *)hasPhones{
    return @([_phones count] > 0);
}
-(NSString *)fullName{
    NSString *firstName = @"";
    if (_firstName !=nil) {
        firstName = _firstName;
    }
    NSString *lastName = @"";
    if (_lastName!=nil) {
        lastName = _lastName;
    }
    NSString * fullName = [NSString stringWithFormat:@"%@%@%@", firstName, [firstName length]> 0?@" ":@"", lastName];
    
    if (fullName.length == 0) {
        
        if (_phones.count > 0) {
            return [NSString stringWithFormat:@"%@", _phones.firstObject];
        }
        
        return @"No Name";
    }
    
    return fullName;
}
+(STAddressBookContact *)contactWithPerson:(CNContact*) contact{
    STAddressBookContact *returnObject = [STAddressBookContact new];
    NSArray *emails = [STAddressBookContact emailsFromPerson:contact];
    returnObject.emails = emails;
    
    NSArray *phones = [STAddressBookContact phonesFromPerson:contact];
    returnObject.phones = phones;
    
    returnObject.firstName = [STAddressBookContact firstNameForPerson:contact];
    returnObject.lastName = [STAddressBookContact lastNameForPerson:contact];
    
    returnObject.thumbnail = [STAddressBookContact thumbnailForPerson:contact];
    
    returnObject.selected = @(0);
    return returnObject;

}

+(NSArray *)emailsFromPerson:(CNContact *) contact{
    
    NSMutableArray *items = [NSMutableArray new];
    for (CNLabeledValue *item in contact.emailAddresses) {
        [items addObject:item.value];
    }
    return items;
}

+(NSArray *)phonesFromPerson:(CNContact *) contact{
    NSMutableArray *items = [NSMutableArray new];
    for (CNLabeledValue *item in contact.phoneNumbers) {
        CNPhoneNumber *number = item.value;
        [items addObject:number.stringValue];
    }
    return items;
}

+(NSString *)firstNameForPerson:(CNContact *)contact{
    return contact.familyName;
}

+(NSString *)lastNameForPerson:(CNContact *) contact{
    return contact.givenName;
}

+(NSData *)thumbnailForPerson:(CNContact *)contact{
    return contact.imageData;
}
@end
