//
//  STCoreDataMessageSync.m
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STCoreDataMessageSync.h"
#import "Message+CoreDataClass.h"

@implementation STCoreDataMessageSync

-(Message *)fetchObjectForUuid:(NSString *)objectuuid
                             inContext:(NSManagedObjectContext *)context{
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    STCoreDataRequestManager *rqm = [[STDAOEngine sharedManager] fetchRequestManagerForEntity:[self entityName] sortDescritors:@[sd1] predicate:[NSPredicate predicateWithFormat:@"uuid like %@", objectuuid] sectionNameKeyPath:nil delegate:nil inManagedObjectContext:context];
    
    Message *message = [[rqm allObjects] lastObject];
    return message;

}

-(NSString *)entityName{
    return @"Message";
}

-(void)configureManagedObject:(Message *)object
                    withData:(NSDictionary *)serverData{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSDate* date = [dateFormatter dateFromString:serverData[@"date"]];
    object.date = date;
    object.message = serverData[@"message"];
    object.received = serverData[@"received"];
    object.roomID = serverData[@"roomID"];
    object.seen = serverData[@"seen"];
    object.userId = [CreateDataModelHelper validStringIdentifierFromValue:serverData[@"userId"]];
    object.uuid = [CreateDataModelHelper validStringIdentifierFromValue: serverData[@"id"]];

}
@end
