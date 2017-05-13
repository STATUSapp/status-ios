//
//  STBaseRequest.m
//  Status
//
//  Created by Cosmin Andrus on 19/11/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//


#import "STBaseRequest.h"

@implementation STBaseRequest

- (id)init{
    self = [super init];
    if (self) {
        self.retryCount = kBCRequestRetryCount;
        __weak STBaseRequest *weakSelf = self;
        
        self.failureBlock = ^(NSError *error){
            [weakSelf requestFailedWithError: error];
        };
        
        self.standardSuccessBlock = ^(NSURLSessionDataTask *task, id responseObject) {
            weakSelf.returnAttributes = responseObject;
            
            if (weakSelf.completionBlock) {
                weakSelf.completionBlock(weakSelf.returnAttributes,nil);
            }
            
            [[CoreManager networkService] requestDidSucceed:weakSelf];
            
        };
        
        self.standardErrorBlock = ^(NSURLSessionDataTask *task, NSError *error) {
            //check error code for network errors
            NSError* err = [weakSelf translateToHTTPError:task error:error];
            if (error.code != NSURLErrorCancelled) {
                [weakSelf failRequestWithError:err];
            }
            
        };
    }
    return self;
}

- (void)retry{
    self.executionBlock();
}

- (void) requestFailedWithError:(NSError*)error{
    
    self.shouldAddToQueue = YES;
    
    self.retryCount--;
    if (self.retryCount <= 0) self.shouldAddToQueue = NO;
    
    [[CoreManager networkService] request:self didFailWithError:error];
}

- (void)failRequestWithError:(NSError *)err {
    if (self.failureBlock) {
        self.failureBlock(err);
    }
    
    [self requestFailedWithError:err];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:self.retryCount forKey:@"retryCount"];
    if (self.timeStamp) [aCoder encodeObject:self.timeStamp forKey:@"timeStamp"];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        __weak STBaseRequest *weakSelf = self;
        self.failureBlock = ^(NSError *error){ [weakSelf requestFailedWithError: error];};
        self.retryCount = [aDecoder decodeIntForKey:@"retryCount"];
        _timeStamp = [aDecoder decodeObjectForKey:@"timeStamp"];
    }
    
    return self;
}

- (NSError*)translateToHTTPError:(NSURLSessionDataTask *)task error:(NSError *)error
{
    if (error.code == 488) {
        return error;
    }
    NSInteger statusCode = ((NSHTTPURLResponse*)task.response).statusCode;
    if (error.code == NSURLErrorCancelled) { //cancelled
        statusCode = NSURLErrorCancelled;
    }

    if (error.code == kCFURLErrorTimedOut || error.code == kCFURLErrorCannotFindHost) {
        statusCode = kHTTPErrorNoConnection;
    }

    
    NSError *err = [NSError errorWithDomain:error.domain
                                       code:statusCode
                                   userInfo:error.userInfo];
    return err;
}

#pragma mark - Virtualization
-(NSString *)urlString{
    NSAssert(YES, @"This method should be overwritten");
    return @"";
}

#pragma mark - Helpers

-(NSNumber *)getTimeZoneOffsetFromGMT{
    NSTimeZone *localTime = [NSTimeZone systemTimeZone];
    return @(localTime.secondsFromGMT/3600);
}

-(NSString *)getAppVersion{
    NSDictionary *infoDictionary = [[NSBundle mainBundle]infoDictionary];
    
    NSString *buildVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];;
    
    NSLog(@"Version: %@", buildVersion);
    
    return buildVersion;
}

- (NSMutableDictionary *)getDictParamsWithToken
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:@{@"token":[[CoreManager networkService] getAccessToken]}];
    return params;
}

@end
