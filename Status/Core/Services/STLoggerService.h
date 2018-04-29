//
//  STLoggerService.h
//  Status
//
//  Created by Cosmin Andrus on 23/04/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STLoggerService : NSObject

-(instancetype)initWithSuiteName:(NSString *)suiteName;

@property (nonatomic, strong, readonly) NSMutableArray *logArray;
@property (nonatomic, assign, readonly) BOOL inProgress;

-(void)sendLogs:(NSDictionary *)logs;
-(void)saveLogsToDisk;
-(void)startUpload;

@end
