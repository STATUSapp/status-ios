//
//  STSyncBaseObject.h
//  Status
//
//  Created by Cosmin Andrus on 31/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STSyncBaseObject : NSObject

@property (nonatomic, assign) NSInteger pageIndex;

-(void)sync;
-(NSUserDefaults *)lastCheckUserDefaults;
-(void)resetLastCheck;

@end
