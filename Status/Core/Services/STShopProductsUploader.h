//
//  STShopProductsUploader.h
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STShopProduct;

typedef NS_ENUM(NSUInteger, ShopProductsUploadStatus) {
    ShopProductsUploadStatusIncomplete = 0,
    ShopProductsUploadStatusComplete,
};

typedef void (^shopProductsCompletion)(NSArray <STShopProduct *> *shopProducts, ShopProductsUploadStatus status);

@interface STShopProductsUploader : NSObject

- (void)uploadShopProducts:(NSArray <STShopProduct *> *)shopProducts
            withCompletion:(shopProductsCompletion)completion;

@end
