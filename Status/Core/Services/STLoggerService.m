//
//  STLoggerService.m
//  Status
//
//  Created by Cosmin Andrus on 23/04/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STLoggerService.h"
#import "STSendLogsReguest.h"

@interface STLoggerService ()

@property (nonatomic, strong) NSMutableArray *logArray;
@property (nonatomic, assign) BOOL inProgress;
@end

@implementation STLoggerService

#pragma mark - Public Methods

-(instancetype)init{
    self = [super init];
    if (self) {
        [self loadLogsFromDisk];
        self.inProgress = NO;
    }
    return self;
}

-(void)sendLogs:(NSDictionary *)logs{
    if (!_logArray) {
        _logArray = [NSMutableArray new];
    }
    if (logs && logs.allKeys.count > 0) {
        //ignore the Send Logs API.
        //If this is failing, there is not much we can do ;);
        if (![logs[kAPIKey] isEqualToString:kSendLogs]) {
            [self.logArray addObject:logs];
        }
    }
    
    [self startUpload];
}

-(void)saveLogsToDisk{
    NSUserDefaults *logsPrefs = [[NSUserDefaults alloc] initWithSuiteName:@"LOGS_SUITE"];
    [logsPrefs setValue:self.logArray forKey:@"LOGS"];
    [logsPrefs synchronize];
}

- (BOOL)checkCanUploadNext {
    return self.inProgress==NO;
}

-(void)startUpload{
    if (![self checkCanUploadNext]){
        return;
    }
    __block NSDictionary *log = [_logArray firstObject];
    if (log) {
        self.inProgress = YES;
        __weak STLoggerService *weakSelf = self;
        [STSendLogsReguest sendLogs:log
                      andCompletion:^(id response, NSError *error) {
                          weakSelf.inProgress = NO;
                          if (!error) {
                              NSLog(@"Send logs response: %@", response);
                              [weakSelf.logArray removeObject:log];
                              [weakSelf startUpload];
                          }else{
                              NSLog(@"Error sending logs: %@", error.debugDescription);
                          }
                          
                      } failure:^(NSError *error) {
                          weakSelf.inProgress = NO;
                          NSLog(@"Error sending logs: %@", error.debugDescription);
                      }];
    }
}

#pragma mark - Private Methods

-(void)loadLogsFromDisk{
    NSUserDefaults *logsPrefs = [[NSUserDefaults alloc] initWithSuiteName:@"LOGS_SUITE"];
    if (!self.logArray) {
        self.logArray = [NSMutableArray new];
    }
    NSArray *logsQueue = [logsPrefs valueForKey:@"LOGS"];
    if (logsQueue.count) {
        [self.logArray addObjectsFromArray:logsQueue];
    }
}

@end
