//
//  STNetworkQueueManagerTests.m
//  STATUSTests
//
//  Created by Cosmin Andrus on 27/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "STNetworkQueueManager.h"
#import "OCMock.h"
#import "CoreManager.h"
#import "STLoginRequest.h"

@interface STNetworkQueueManagerTests : XCTestCase

@property (nonatomic, strong) STNetworkQueueManager *networkQueue;
@property (nonatomic, strong) id networkQueueMock;
@end

@implementation STNetworkQueueManagerTests

- (void)setUp {
    [super setUp];
    self.networkQueue = [STNetworkQueueManager new];
    self.networkQueueMock = OCMPartialMock(self.networkQueue);
}

- (void)tearDown {
    self.networkQueue = nil;
    [super tearDown];
}

- (void)testInitialState {
    XCTAssertNotNil(self.networkQueue.baseUrl, @"Base url should not be nil");
    XCTAssertNil(self.networkQueue.photoDownloadBaseUrl, @"Photo download base url should be nil");
}

-(void)testLoginRegisterFlow{
    XCTAssertTrue([self.networkQueue canSendLoginOrRegisterRequest], @"Should be possible to add login or register in the first place");
    OCMStub([self.networkQueueMock isConnectionWorking]).andReturn(YES);
    STlogin
//    id coreManagerMock = OCMClassMock([CoreManager class]);
//    OCMStub([coreManagerMock networkService]).andReturn(self.networkQueueMock);

}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
