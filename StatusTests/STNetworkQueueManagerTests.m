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
#import "STLoginService.h"
#import "STLoginRequest.h"
#import "STRegisterRequest.h"
#import "STLoginRequest.h"
#import "STDeletePostRequest.h"
#import "STFollowUsersRequest.h"
#import "STUnfollowUsersRequest.h"
#import "STGetFollowersRequest.h"
#import "STGetFollowingRequest.h"
#import "STGetPostsRequest.h"
#import "STGetBrandsRequest.h"

@interface STNetworkQueueManagerTests : XCTestCase

@property (nonatomic, strong) STNetworkQueueManager *networkQueue;
@property (nonatomic, strong) STNetworkQueueManager *networkQueueMock;

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
    XCTAssertNotNil(self.networkQueueMock.baseUrl, @"Base url should not be nil");
    XCTAssertNil(self.networkQueueMock.photoDownloadBaseUrl, @"Photo download base url should be nil");
}

-(void)testLoginRegisterFlow{
    XCTAssertTrue([self.networkQueue canSendLoginOrRegisterRequest], @"Should be possible to add login or register in the first place");
    OCMStub([self.networkQueueMock isConnectionWorking]).andReturn(YES);

    STRegisterRequest *registerRequest = [STRegisterRequest new];
    registerRequest.executionBlock = ^void(){
        NSLog(@"Register request executed");
    };
    
    [self.networkQueueMock addToQueueTop:registerRequest];
    
    OCMVerify([self.networkQueueMock startDownload]);
    XCTAssertTrue([self.networkQueue canSendLoginOrRegisterRequest]==NO, @"Should not be possible to add login or register requests");
    [self.networkQueueMock requestDidSucceed:registerRequest];
    XCTAssertTrue([self.networkQueue canSendLoginOrRegisterRequest], @"Should be possible to add login or register requests");

    STLoginRequest *loginRequest = [STLoginRequest new];
    loginRequest.executionBlock = ^void(){
        NSLog(@"Login request executed");
    };
    
    [self.networkQueueMock addToQueue:loginRequest];

    OCMVerify([self.networkQueueMock startDownload]);
    XCTAssertTrue([self.networkQueue canSendLoginOrRegisterRequest]==NO, @"Should not be possible to add login or register requests");
    [self.networkQueueMock requestDidSucceed:loginRequest];
    XCTAssertTrue([self.networkQueue canSendLoginOrRegisterRequest], @"Should be possible to add login or register requests");

}

- (void)testConnectivity{
    XCTAssertTrue([self.networkQueue canSendLoginOrRegisterRequest], @"Should be possible to add login or register in the first place");
    OCMStub([self.networkQueueMock isConnectionWorking]).andReturn(NO);
    
    STRegisterRequest *registerRequest = [STRegisterRequest new];
    registerRequest.executionBlock = ^void(){
        NSLog(@"Register request executed");
    };
    
    [self.networkQueueMock addToQueueTop:registerRequest];
    
    XCTAssertTrue([self.networkQueue canSendLoginOrRegisterRequest], @"Should be possible to add login or register requests");
    [self.networkQueueMock request:registerRequest didFailWithError:[NSError errorWithDomain:@"com.status.connectivity" code:447 userInfo:nil]];
}

- (void)testConcurency{
    XCTAssertTrue([self.networkQueue canSendLoginOrRegisterRequest], @"Should be possible to add login or register in the first place");
    OCMStub([self.networkQueueMock isConnectionWorking]).andReturn(YES);
    
    NSMutableArray<STBaseRequest *> *requestsArray = [NSMutableArray new];
    
    STDeletePostRequest *deletePostRequest = [STDeletePostRequest new];
    [requestsArray addObject:deletePostRequest];
    
    STFollowUsersRequest *followUserRequest = [STFollowUsersRequest new];
    [requestsArray addObject:followUserRequest];
    
    STUnfollowUsersRequest *unfollowUserRequest = [STUnfollowUsersRequest new];
    [requestsArray addObject:unfollowUserRequest];
    
    STGetFollowersRequest *getFollowersRequest = [STGetFollowersRequest new];
    [requestsArray addObject:getFollowersRequest];

    STGetFollowingRequest *getFollowingRequest = [STGetFollowingRequest new];
    [requestsArray addObject:getFollowingRequest];
    
    STGetPostsRequest *getPostsRequest = [STGetPostsRequest new];
    [requestsArray addObject:getPostsRequest];

    STGetBrandsRequest *getBrandsRequest1 = [STGetBrandsRequest new];
    [requestsArray addObject:getBrandsRequest1];

    STGetBrandsRequest *getBrandsRequest2 = [STGetBrandsRequest new];
    [requestsArray addObject:getBrandsRequest2];

    STGetBrandsRequest *getBrandsRequest3 = [STGetBrandsRequest new];
    [requestsArray addObject:getBrandsRequest3];

    STGetBrandsRequest *getBrandsRequest4 = [STGetBrandsRequest new];
    [requestsArray addObject:getBrandsRequest4];

    NSInteger numberOfSeconds = 5;
    int64_t delta = numberOfSeconds * NSEC_PER_SEC;
    BOOL isLastObject = NO;
    XCTestExpectation *expectation = [self expectationWithDescription:@"last request expectation"];
    for (STBaseRequest *request in requestsArray) {
        if (request == [requestsArray lastObject]) {
            isLastObject = YES;
        }
        __weak STBaseRequest *requestWeak = request;
        request.executionBlock = ^void(){
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, delta);
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                NSLog(@"%@ request executed", NSStringFromClass(requestWeak.class));
                [self.networkQueueMock requestDidSucceed:requestWeak];
                if (isLastObject) {
                    [expectation fulfill];
                }
            });
        };

        [self.networkQueueMock addToQueue:request];
    }
    [self waitForExpectations:@[expectation] timeout:21];
    
    XCTAssertTrue(self.networkQueueMock.requestQueue.count == 0, @"At the end all requests should have been finished");

}

-(void)testForAccessors{
    NSString *testAccessToken = [[NSUUID UUID] UUIDString];
    [self.networkQueueMock setAccessToken:testAccessToken];
    XCTAssertNotNil([self.networkQueueMock getAccessToken], @"Access token should not be nil");
    [self.networkQueueMock deleteAccessToken];
    XCTAssertNil([self.networkQueueMock getAccessToken], @"Access token should be nil");
    NSString *photoDownloadBaseUrl = @"https://test.status.co";
    [self.networkQueueMock setPhotoDownloadBaseUrl:photoDownloadBaseUrl];
    XCTAssertNotNil(self.networkQueueMock.photoDownloadBaseUrl, @"Photo download base url should not be nil");
    [self.networkQueueMock setPhotoDownloadBaseUrl:nil];
    XCTAssertNil(self.networkQueueMock.photoDownloadBaseUrl, @"Photo download base url should be nil");
    
}
@end
