//
//  STATUSTests.m
//  STATUSTests
//
//  Created by Silviu Burlacu on 28/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "STPost.h"
#import "STPostsPool.h"

@interface STATUSTests : XCTestCase

@end

@implementation STATUSTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (NSArray *)mockPosts {
    
    NSMutableArray * array = [NSMutableArray array];
    
    for (int i = 0; i < 10 ; i++) {
        STPost * mock = [STPost new];
        mock.uuid = [NSString stringWithFormat:@"abc%li", (long)i];
        [array addObject:mock];
    }
    
    return array.copy;
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}


- (void)testPoolAdd {
    STPostsPool * pool = [[STPostsPool alloc] init];
    
    [pool addPosts:[self mockPosts]];
    [pool addPosts:[self mockPosts]];
    [pool addPosts:[self mockPosts]];
    [pool addPosts:[self mockPosts]];
    
    XCTAssertEqual([self mockPosts].count, [pool getAllPosts].count);
    
}

- (void)testPoolUpdate {
    STPostsPool * pool = [[STPostsPool alloc] init];
    
    STPost * mock = [STPost new];
    mock.uuid = @"abc67";
    mock.caption = @"abd";
    
    [pool addPosts:@[mock]];
    
    mock.caption = @"abe";
    [pool addPosts:@[mock]];
    
    XCTAssertEqual(1, [pool getAllPosts].count);
    
    
    
    STPost * updatedMock = [pool getPostWithId:@"abc67"];
    XCTAssertTrue([updatedMock.caption isEqualToString:@"abe"]);
    
}

- (void)testPoolRemoval {
    STPostsPool * pool = [[STPostsPool alloc] init];
    
    [pool addPosts:[self mockPosts]];
    
    STPost * mock = [STPost new];
    mock.uuid = @"abc67";
    
    [pool removePosts:@[mock]];
    
    STPost * deletedMock = [pool getPostWithId:@"abc67"];
    XCTAssertNil(deletedMock);
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        STPostsPool * pool = [[STPostsPool alloc] init];
        
        [pool addPosts:[self mockPosts]];
        [pool addPosts:[self mockPosts]];
        [pool addPosts:[self mockPosts]];
        [pool addPosts:[self mockPosts]];
    }];
}

@end
