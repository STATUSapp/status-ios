//
//  STLoggerServiceTests.m
//  STATUSTests
//
//  Created by Cosmin Andrus on 23/04/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "STLoggerService.h"
#import "STConstants.h"
#import "STSendLogsReguest.h"

@interface STLoggerService (PrivateMethods)

- (NSDictionary *)getNextLogToBeUploaded;
- (void)uploadLog:(NSDictionary *)log;
- (void)handleResponse:(NSError *)error
               forLog:(NSDictionary *)log;
- (NSString *)logsSuiteName;
- (NSString *)logsKey;
@end

@interface STLoggerServiceTests : XCTestCase

@property (nonatomic, strong) id loggerServiceMock;
@property (nonatomic, strong) STLoggerService *loggerService;

@end

@implementation STLoggerServiceTests

- (void)setUp {
    [super setUp];
    self.loggerService = [[STLoggerService alloc] initWithSuiteName:@"TEST_LOGS_SUITE"];
    self.loggerServiceMock = OCMPartialMock(self.loggerService);
}

- (void)tearDown {
    [self.loggerServiceMock stopMocking];
    self.loggerServiceMock = nil;
    self.loggerService = nil;
    [super tearDown];
}

-(NSDictionary *)getTestLogToBeUploaded{
    NSMutableDictionary *log = [@{kAPIKey:@"LoggerServiceUnitTest",
                                 kErrorCodeKey:@(1011),
                                 @"timestamp":[NSDate date]
                                 }
                                mutableCopy];
    return log;
}

//using test01, test02, and so on because we need to keep a specific order of the tests for this test case.
- (void)test01InProgressValue {
    
    NSDictionary *log = [self getTestLogToBeUploaded];
    OCMStub([self.loggerServiceMock uploadLog:log]).andDo(nil);
    [self.loggerServiceMock sendLogs:log];
    XCTAssertTrue(self.loggerService.inProgress, @"self.loggerService.inProgress should be YES when sending");
    
    do {
        NSDictionary *nextLog = [self.loggerService getNextLogToBeUploaded];
        [self.loggerService handleResponse:nil forLog:nextLog];
    } while (self.loggerService.logArray.count);
    
    XCTAssertTrue(!self.loggerService.inProgress, @"self.loggerService.inProgress should be NO after the response");
}

- (void)test02LogsArray {
    
    NSDictionary *log1 = [self getTestLogToBeUploaded];
    NSDictionary *log2 = [self getTestLogToBeUploaded];

    OCMStub([self.loggerServiceMock uploadLog:[OCMArg any]]).andDo(nil);

    [self.loggerServiceMock sendLogs:log1];
    XCTAssertTrue(self.loggerService.logArray.count == 1, @"self.loggerService.logArray should have 1 element");
    [self.loggerServiceMock sendLogs:log2];
    XCTAssertTrue(self.loggerService.logArray.count == 2, @"self.loggerService.logArray should have 2 element");
    [self.loggerService handleResponse:nil forLog:log1];
    XCTAssertTrue(self.loggerService.logArray.count == 1, @"self.loggerService.logArray should have 1 element");
    NSError *testError = [NSError errorWithDomain:@"com.status.test_error" code:10011 userInfo:nil];
    [self.loggerService handleResponse:testError forLog:log2];
    XCTAssertTrue(self.loggerService.logArray.count == 1, @"self.loggerService.logArray should have 1 element since error was handled");

    [self.loggerService saveLogsToDisk];
}

- (void)test03LoadLogsFromDisk {
    
    XCTAssertTrue(self.loggerService.logArray.count == 1, @"self.loggerService.logArray should have 1 element loaded from disk");
    OCMStub([self.loggerServiceMock uploadLog:[OCMArg any]]).andDo(nil);
    NSDictionary *log = [self.loggerService getNextLogToBeUploaded];
    [self.loggerService handleResponse:nil forLog:log];
    [self.loggerService saveLogsToDisk];
}

- (void)test04ServerResponse{
    XCTestExpectation *expectation = [self expectationWithDescription:@"send logs request"];
    
    NSDictionary *log = [self getTestLogToBeUploaded];
    [STSendLogsReguest sendLogs:log andCompletion:^(id response, NSError *error) {
        XCTAssertNil(error, @"send test logs error %@", error);
        NSLog(@"Response: %@", response);
        [expectation fulfill];

    } failure:^(NSError *error) {
        XCTAssertNil(error, @"send test logs error %@", error);
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:nil];
}
@end
