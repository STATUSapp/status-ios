//
//  STCoreDataBrandSync.m
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STCoreDataBrandSync.h"
#import "Brand+CoreDataClass.h"
#import "NSString+Links.h"
#import "NSString+Letters.h"

@implementation STCoreDataBrandSync
-(NSManagedObject *)fetchObjectForUuid:(NSString *)objectuuid
                             inContext:(NSManagedObjectContext *)context{
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"uuid" ascending:YES];
    STCoreDataRequestManager *rqm = [[STDAOEngine sharedManager] fetchRequestManagerForEntity:[self entityName] sortDescritors:@[sd1] predicate:[NSPredicate predicateWithFormat:@"uuid like %@", objectuuid] sectionNameKeyPath:nil delegate:nil inManagedObjectContext:context];
    
    Brand *brand = [[rqm allObjects] lastObject];
    return brand;
    
}

-(NSString *)entityName{
    return @"Brand";
}

-(void)configureManagedObject:(Brand *)object
                     withData:(NSDictionary *)serverData{
    object.uuid = [CreateDataModelHelper validStringIdentifierFromValue: serverData[@"id"]];
    object.name = [serverData[@"name"] capitalizedString];
    object.image_url = [serverData[@"image_url"] stringByReplacingHttpWithHttps];
    object.indexString = [self indexStringFromName:object.name];
}

#pragma mark - Helpers

-(NSString *)indexStringFromName:(NSString *)name{
    NSArray *letters = [NSString allCapsLetters];
    NSString *firstNameLetter = @"";
    if (name && [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length >=1) {
        firstNameLetter = [name substringToIndex:1];
    }
    if ([letters containsObject:firstNameLetter]) {
        return [firstNameLetter uppercaseString];
    }
    return @"#";
}

-(void)dealloc{
    NSLog(@"Core data brand sync dealoc");
}
@end
