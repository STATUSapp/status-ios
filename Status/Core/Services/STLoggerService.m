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

@property (nonatomic, strong, readwrite) NSMutableArray *logArray;
@property (nonatomic, assign, readwrite) BOOL inProgress;
@property (nonatomic, strong) NSString *suiteName;
@end

@implementation STLoggerService

#pragma mark - Public Methods

-(instancetype)initWithSuiteName:(NSString *)suiteName{
    self = [super init];
    if (self) {
        self.suiteName = suiteName;
        [self loadLogsFromDisk];
        self.inProgress = NO;
    }
    return self;
}

-(void)sendLogs:(NSDictionary *)logs{
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
    NSUserDefaults *logsPrefs = [[NSUserDefaults alloc] initWithSuiteName:[self logsSuiteName]];
    [logsPrefs setValue:self.logArray forKey:[self logsKey]];
    [logsPrefs synchronize];
}

-(void)startUpload{
    if (self.inProgress){
        return;
    }
    __block NSDictionary *log = [self getNextLogToBeUploaded];
    if (log) {
        self.inProgress = YES;
        [self uploadLog:log];
    }
}

#pragma mark - Private Methods
-(void)handleResponse:(NSError *)error
               forLog:(NSDictionary *)log{
    self.inProgress = NO;
    if (!error) {
        [self.logArray removeObject:log];
        [self startUpload];
    }else{
        NSLog(@"Error sending logs: %@", error.debugDescription);
    }
}
- (void)uploadLog:(NSDictionary *)log {
    __weak STLoggerService *weakSelf = self;
    [STSendLogsReguest sendLogs:log
                  andCompletion:^(id response, NSError *error) {
                      [weakSelf handleResponse:error forLog:log];
                  } failure:^(NSError *error) {
                      [weakSelf handleResponse:error forLog:log];
                  }];
}

- (NSDictionary *)getNextLogToBeUploaded{
    return [_logArray firstObject];
}

-(NSString *)logsSuiteName{
    if (!_suiteName) {
        _suiteName = @"LOGS_SUITE";

    }
    return _suiteName;
}

-(NSString *)logsKey{
    return @"LOGS";
}

-(void)loadLogsFromDisk{
    NSUserDefaults *logsPrefs = [[NSUserDefaults alloc] initWithSuiteName:[self logsSuiteName]];
    if (!self.logArray) {
        self.logArray = [NSMutableArray new];
    }
    NSArray *logsQueue = [logsPrefs valueForKey:[self logsKey]];
    if (logsQueue.count) {
        [self.logArray addObjectsFromArray:logsQueue];
    }
    
    //delete logs from disk
    [logsPrefs setValue:nil forKey:[self logsKey]];
    [logsPrefs synchronize];
}

@end
