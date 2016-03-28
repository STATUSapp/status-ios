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
+(STAddressBookContact *)contactWithPerson:(ABRecordRef) person{
    STAddressBookContact *returnObject = [STAddressBookContact new];
    NSArray *emails = [STAddressBookContact emailsFromPerson:person];
    returnObject.emails = emails;
    
    NSArray *phones = [STAddressBookContact phonesFromPerson:person];
    returnObject.phones = phones;
    
    returnObject.firstName = [STAddressBookContact firstNameForPerson:person];
    returnObject.lastName = [STAddressBookContact lastNameForPerson:person];
    
    returnObject.thumbnail = [STAddressBookContact thumbnailForPerson:person];
    
    returnObject.selected = @(0);
    return returnObject;

}

+(NSArray *)emailsFromPerson:(ABRecordRef) person{
    NSMutableArray *contactEmails = [NSMutableArray new];
    ABMultiValueRef multiEmails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    for (CFIndex i=0; i<ABMultiValueGetCount(multiEmails); i++) {
        @autoreleasepool {
            CFStringRef contactEmailRef = ABMultiValueCopyValueAtIndex(multiEmails, i);
            NSString *contactEmail = CFBridgingRelease(contactEmailRef);
            if (contactEmail != nil)[contactEmails addObject:contactEmail];
        }
    }
    
    if (multiEmails != NULL) {
        CFRelease(multiEmails);
    }
    return [NSArray arrayWithArray:contactEmails];
}

+(NSArray *)phonesFromPerson:(ABRecordRef) person{
    NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];
    ABMultiValueRef multiPhones = ABRecordCopyValue(person, kABPersonPhoneProperty);
    
    for(CFIndex i=0; i<ABMultiValueGetCount(multiPhones); i++) {
        @autoreleasepool {
            CFStringRef phoneNumberRef = ABMultiValueCopyValueAtIndex(multiPhones, i);
            NSString *phoneNumber = CFBridgingRelease(phoneNumberRef);
            if (phoneNumber != nil)[phoneNumbers addObject:phoneNumber];
        }
    }
    
    if (multiPhones != NULL) {
        CFRelease(multiPhones);
    }
    return [NSArray arrayWithArray:phoneNumbers];
}

+(NSString *)firstNameForPerson:(ABRecordRef)person{
    CFStringRef firstName = (CFStringRef)ABRecordCopyValue(person,kABPersonFirstNameProperty);
    NSString *firstNameStr = [(__bridge NSString*)firstName copy];
    
    if (firstName != NULL) {
        CFRelease(firstName);
    }
    return firstNameStr;
}

+(NSString *)lastNameForPerson:(ABRecordRef) person{
    CFStringRef lastName = (CFStringRef)ABRecordCopyValue(person,kABPersonLastNameProperty);
    NSString *lastNameStr = [(__bridge NSString*)lastName copy];
    
    if (lastName != NULL) {
        CFRelease(lastName);
    }
    return lastNameStr;
}

+(NSData *)thumbnailForPerson:(ABRecordRef)person{
    CFDataRef imgData = ABPersonCopyImageData(person);
    NSData *imageData = [NSData dataWithData:(__bridge NSData *)imgData];
    
    if (imgData != NULL) {
        CFRelease(imgData);
    }
    return imageData;
}
@end
