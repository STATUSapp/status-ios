//
//  STImageResizeService.h
//  Status
//
//  Created by Cosmin Andrus on 21/06/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, STImageUseType) {
    STImageUseTypeUploadPost = 0,
    STImageUseTypeUploadForSuggestions, 
    STImageUseTypeUploadProfile,
    STImageUseTypeUploadProduct
};

@interface STImageResizeService : NSObject

- (UIImage *)resizeImage:(UIImage *)image
         forUseType:(STImageUseType)useType;

@end
