//
//  STResetBaseUrlService.m
//  Status
//
//  Created by Cosmin Andrus on 01/07/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STResetBaseUrlService.h"
#import "STNetworkQueueManager.h"

@interface STResetBaseUrlService ()

@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation STResetBaseUrlService

-(UIAlertController *)resetBaseUrlAlert{
    if (!self.alertController) {
        self.alertController = [UIAlertController alertControllerWithTitle:@"" message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [self.alertController addTextFieldWithConfigurationHandler:nil];
        [self.alertController addAction:[UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *tf = [self.alertController.textFields firstObject];
            NSString *newBaseUrl = tf.text;
            if (newBaseUrl) {
                NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"BaseUrl"];
                [ud setValue:newBaseUrl forKey:@"BASE_URL"];
                [ud synchronize];
                [[CoreManager networkService] reset];
            }
        }]];
        [_alertController addAction:[UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSUserDefaults *ud = [[NSUserDefaults alloc] initWithSuiteName:@"BaseUrl"];
            [ud setValue:kBaseURL forKey:@"BASE_URL"];
            [ud synchronize];
            [[CoreManager networkService] reset];
            
        }]];
    }
    return self.alertController;
}

@end
