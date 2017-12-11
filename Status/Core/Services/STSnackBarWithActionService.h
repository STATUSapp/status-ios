//
//  STSnackBarWithActionService.h
//  Status
//
//  Created by Cosmin Andrus on 10/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STSnackBarBaseService.h"
typedef NS_ENUM(NSUInteger, STSnackWithActionBarType) {
    STSnackWithActionBarTypeGuestMode = 0
};
@interface STSnackBarWithActionService : STSnackBarBaseService

-(void)showSnackBarWithType:(STSnackWithActionBarType)type;

@end
