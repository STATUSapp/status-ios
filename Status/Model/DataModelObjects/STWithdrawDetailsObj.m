//
//  STWithdrawDetailsObj.m
//  Status
//
//  Created by Cosmin Andrus on 08/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STWithdrawDetailsObj.h"

@implementation STWithdrawDetailsObj

+ (STWithdrawDetailsObj *)withdrawDetailsObjWithDictionary:(NSDictionary *)dict{
    STWithdrawDetailsObj *withdrawDetailsObj = [STWithdrawDetailsObj new];
    NSLog(@"Withdraw dict %@", dict);
    withdrawDetailsObj.firstname = [CreateDataModelHelper validObjectFromDict:dict forKey:@"firstname"];
    withdrawDetailsObj.lastname = [CreateDataModelHelper validObjectFromDict:dict forKey:@"lastname"];
    withdrawDetailsObj.email = [CreateDataModelHelper validObjectFromDict:dict forKey:@"email"];
    withdrawDetailsObj.phone_number = [CreateDataModelHelper validObjectFromDict:dict forKey:@"phone_number"];
    withdrawDetailsObj.company = [CreateDataModelHelper validObjectFromDict:dict forKey:@"company"];
    withdrawDetailsObj.vat_number = [CreateDataModelHelper validObjectFromDict:dict forKey:@"vat_number"];
    withdrawDetailsObj.register_number = [CreateDataModelHelper validObjectFromDict:dict forKey:@"register_number"];
    withdrawDetailsObj.country = [CreateDataModelHelper validObjectFromDict:dict forKey:@"country"];
    withdrawDetailsObj.city = [CreateDataModelHelper validObjectFromDict:dict forKey:@"city"];
    withdrawDetailsObj.address = [CreateDataModelHelper validObjectFromDict:dict forKey:@"address"];
    withdrawDetailsObj.iban = [CreateDataModelHelper validObjectFromDict:dict forKey:@"iban"];

    return withdrawDetailsObj;
}

+ (STWithdrawDetailsObj *)mockObject{
    STWithdrawDetailsObj *withdrawDetailsObj = [STWithdrawDetailsObj new];
    withdrawDetailsObj.firstname = @"Andrus";
    withdrawDetailsObj.lastname = @"Cosmin-Adelin";
    withdrawDetailsObj.email = @"andrus.cosmin@yahoo.com";
    withdrawDetailsObj.phone_number = @"0765510112";
    withdrawDetailsObj.company = @"Andrus SRL";
    withdrawDetailsObj.vat_number = @"13567864";
    withdrawDetailsObj.register_number = @"437584-AC";
    withdrawDetailsObj.country = @"Romania";
    withdrawDetailsObj.city = @"Bucharest";
    withdrawDetailsObj.address = @"intr.Ciulin, nr.6, Berceni";
    withdrawDetailsObj.iban = @"RO34INGB000023628273";

    return withdrawDetailsObj;
}
@end
