//
//  STBaseObj.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STBaseObj.h"

@implementation STBaseObj
-(NSString *)debugDescription{
    return [NSString stringWithFormat:@"%@", self.infoDict];
}
@end
