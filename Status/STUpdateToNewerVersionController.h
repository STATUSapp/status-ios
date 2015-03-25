//
//  STUpdateToNewerVersionController.h
//  Status
//
//  Created by Cosmin Andrus on 28/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STUpdateToNewerVersionController : NSObject
-(void)checkForAppInfo;
+ (STUpdateToNewerVersionController *)sharedManager;
@end
