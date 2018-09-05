//
//  STInstagramShareService.m
//  Status
//
//  Created by Cosmin Andrus on 05/09/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STInstagramShareService.h"

@implementation STInstagramShareService

-(void)shareImageToStory:(UIImage *)image
              contentURL:(NSString *)contentURL
              completion:(STInstagramShareCompletionBlock)completion{
    // Verify app can open custom URL scheme, open if able
    NSURL *urlScheme = [NSURL URLWithString:@"instagram-stories://share"];
    if ([[UIApplication sharedApplication] canOpenURL:urlScheme]) {
        
        // Assign background image asset and attribution link URL to pasteboard
        NSArray *pasteboardItems = @[@{@"com.instagram.sharedSticker.backgroundImage" : image,
                                       @"com.instagram.sharedSticker.contentURL" : contentURL}];
        NSDictionary *pasteboardOptions = @{UIPasteboardOptionExpirationDate : [[NSDate date] dateByAddingTimeInterval:60 * 5]};
        // This call is iOS 10+, can use 'setItems' depending on what versions you support
        [[UIPasteboard generalPasteboard] setItems:pasteboardItems options:pasteboardOptions];
        
        [[UIApplication sharedApplication] openURL:urlScheme options:@{} completionHandler:^(BOOL success) {
            if (success == YES) {
                completion(STInstagramShareErrorNone);
            }else{
                completion(STInstagramShareErrorNoInstragramApp);
            }
        }];
    } else {
        completion(STInstagramShareErrorNoInstragramApp);
    }
}


@end
