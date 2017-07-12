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

@end
