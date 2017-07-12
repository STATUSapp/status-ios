//
//  STWithdrawDetailsObj.h
//  Status
//
//  Created by Cosmin Andrus on 08/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@interface STWithdrawDetailsObj : STBaseObj

@property (nonatomic, strong) NSString *firstname;
@property (nonatomic, strong) NSString *lastname;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *phone_number;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *vat_number;
@property (nonatomic, strong) NSString *register_number;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *iban;

+ (STWithdrawDetailsObj *)withdrawDetailsObjWithDictionary:(NSDictionary *)dict;

@end
