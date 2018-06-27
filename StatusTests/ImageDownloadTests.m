//
//  ImageDownloadTests.m
//  STATUSTests
//
//  Created by Cosmin Andrus on 26/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SDWebImageManager.h"

NSInteger const kExpectationTimeout = 300;

@interface ImageDownloadTests : XCTestCase

@property (nonatomic, strong) NSURL *fourMBImageUrl;//4MB image
@property (nonatomic, strong) NSURL *zeroPointEightMBImageUrl;//0.8MB image

@end

@implementation ImageDownloadTests

- (void)setUp {
    [super setUp];
    [SDWebImageManager sharedManager].imageCache.config.shouldDecompressImages = NO;
    [SDWebImageDownloader sharedDownloader].shouldDecompressImages = NO;
    [SDWebImageManager sharedManager].imageDownloader.maxConcurrentDownloads = 6;
    self.fourMBImageUrl = [NSURL URLWithString:@"https://getstatus.nyc3.digitaloceanspaces.com/posts/mGKXIsJK0IW0q18mBmDbJNj2ED4EfB7eLBqQ1gcG.png"];
    self.zeroPointEightMBImageUrl = [NSURL URLWithString:@"https://getstatus.nyc3.digitaloceanspaces.com/posts/yn5GoMccpHDsaSfYUBIcsuS6bgLAODmSOG1jbN3A.jpeg"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPerformance4MBDownloadWithProgressive {
    [self measureMetrics:@[XCTPerformanceMetric_WallClockTime] automaticallyStartMeasuring:YES forBlock: ^{
        XCTestExpectation *expectation = [self expectationWithDescription:@"progressive download"];
        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:self.fourMBImageUrl options:SDWebImageDownloaderProgressiveDownload progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (finished && image) {
                [expectation fulfill];
            }
        }];
        [self waitForExpectations:@[expectation] timeout:kExpectationTimeout];
    }];
}

- (void)testPerformance4MBStandardDownload {
    [self measureMetrics:@[XCTPerformanceMetric_WallClockTime] automaticallyStartMeasuring:YES forBlock: ^{
        XCTestExpectation *expectation = [self expectationWithDescription:@"progressive download"];
        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:self.fourMBImageUrl options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (finished && image) {
                [expectation fulfill];
            }
        }];
        [self waitForExpectations:@[expectation] timeout:kExpectationTimeout];
    }];
}

- (void)testPerformanceZeroPointEightMBDownloadWithProgressive {
    [self measureMetrics:@[XCTPerformanceMetric_WallClockTime] automaticallyStartMeasuring:YES forBlock: ^{
        XCTestExpectation *expectation = [self expectationWithDescription:@"progressive download"];
        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:self.zeroPointEightMBImageUrl options:SDWebImageDownloaderProgressiveDownload progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (finished && image) {
                [expectation fulfill];
            }
        }];
        [self waitForExpectations:@[expectation] timeout:kExpectationTimeout];
    }];
}

- (void)testPerformanceZeroPointEightMBStandardDownload {
    [self measureMetrics:@[XCTPerformanceMetric_WallClockTime] automaticallyStartMeasuring:YES forBlock: ^{
        XCTestExpectation *expectation = [self expectationWithDescription:@"progressive download"];
        [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:self.zeroPointEightMBImageUrl options:SDWebImageDownloaderHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
            if (finished && image) {
                [expectation fulfill];
            }
        }];
        [self waitForExpectations:@[expectation] timeout:kExpectationTimeout];
    }];
}


@end
