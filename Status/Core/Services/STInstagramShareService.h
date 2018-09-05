//
//  STInstagramShareService.h
//  Status
//
//  Created by Cosmin Andrus on 05/09/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, STInstagramShareError) {
    STInstagramShareErrorNone = 0,
    STInstagramShareErrorNoInstragramApp
};

typedef void (^STInstagramShareCompletionBlock)(STInstagramShareError error);

@interface STInstagramShareService : NSObject

-(void)shareImageToStory:(UIImage *)image
              contentURL:(NSString *)contentURL
              completion:(STInstagramShareCompletionBlock)completion;

@end
