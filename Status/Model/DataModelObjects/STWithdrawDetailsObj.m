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
    STWithdrawDetailsObj *wd = [STWithdrawDetailsObj new];
    //TODO: add configuration here
    NSLog(@"Withdraw dict %@", dict);
    return wd;
}

+ (STWithdrawDetailsObj *)mockObject{
    STWithdrawDetailsObj *withdrawDetailsObj = [STWithdrawDetailsObj new];
//    withdrawDetailsObj.firstname = @"Andrus";
//    withdrawDetailsObj.lastname = @"Cosmin-Adelin";
//    withdrawDetailsObj.email = @"andrus.cosmin@yahoo.com";
//    withdrawDetailsObj.phone_number = @"0765510112";
//    withdrawDetailsObj.company = @"Andrus SRL";
//    withdrawDetailsObj.vat_number = @"13567864";
//    withdrawDetailsObj.register_number = @"437584-AC";
//    withdrawDetailsObj.country = @"Romania";
//    withdrawDetailsObj.city = @"Bucharest";
//    withdrawDetailsObj.address = @"intr.Ciulin, nr.6, Berceni";
//    withdrawDetailsObj.iban = @"RO34INGB000023628273";

    return withdrawDetailsObj;
}
@end
