//
//  STUpdateToNewerVersionController.m
//  Status
//
//  Created by Cosmin Andrus on 28/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STUpdateToNewerVersionController.h"
#import "STBaseRequest.h"

@interface STUpdateToNewerVersionController()

@property (nonatomic, strong) UIAlertView *newerVersionAlert;

@end

static STUpdateToNewerVersionController *_sharedManager = nil;

@implementation STUpdateToNewerVersionController

+ (STUpdateToNewerVersionController *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [STUpdateToNewerVersionController new];
    });
    
    return _sharedManager;
}

-(void)checkForAppInfo{
    if (_newerVersionAlert!=nil) {
        return;
    }
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURL * url = [NSURL URLWithString:@"https://itunes.apple.com/lookup?id=841855995"];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithURL:url
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                        if(error == nil)
                                                        {
                                                            NSError *errorJson = nil;
                                                            NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &errorJson];
                                                            NSString *appVersion = [[STBaseRequest new] getAppVersion];
                                                            NSString *appStoreVersion = [responseDict[@"results"] firstObject][@"version"];
                                                            if (![appStoreVersion isEqualToString:appVersion]) {
                                                                _newerVersionAlert = [[UIAlertView alloc] initWithTitle:@"A new version of Get STATUS is available on Appstore!\n\nWhat's new:" message:[responseDict[@"results"] firstObject][@"releaseNotes"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Download", nil];
                                                                [_newerVersionAlert show];
                                                            }
                                                        }
                                                        
                                                    }];
    
    [dataTask resume];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView isEqual:_newerVersionAlert]) {
        if (buttonIndex == 1) {
            _newerVersionAlert = nil;
            NSString *iTunesLink = @"https://itunes.apple.com/us/app/apple-store/id841855995?mt=8";
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:iTunesLink]];
        }
    }
}
@end
