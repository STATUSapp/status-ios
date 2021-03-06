//
//  STShopProductsUploader.m
//  Status
//
//  Created by Cosmin Andrus on 12/02/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STShopProductsUploader.h"
#import "STUploadShopProduct.h"
#import "STShopProduct.h"

@interface STShopProductsUploader ()

@property (nonatomic, copy) shopProductsCompletion completion;
@property (nonatomic, strong) NSMutableArray <STShopProduct*> *shopProducts;

@end

@implementation STShopProductsUploader

- (void)uploadShopProducts:(NSArray <STShopProduct *> *)shopProducts
            withCompletion:(shopProductsCompletion)completion
{
    _completion = completion;
    _shopProducts = [NSMutableArray arrayWithArray:shopProducts];
    
    __block NSInteger shopProductsWithId = 0;
    __block NSInteger shopProductsNotUploaded = 0;
    __weak STShopProductsUploader *weakSelf = self;
    
    for (STShopProduct *sp in _shopProducts) {
        if (sp.uuid || sp.mainImageUrl) {
            shopProductsWithId ++;
        }
        else
        {
            __block STShopProduct *blockSP = sp;
            [STUploadShopProduct uploadShopProduct:sp
                                    withCompletion:^(id response, NSError *error) {
                                        __strong STShopProductsUploader *strongSelf = weakSelf;
                                        if (!error) {
                                            NSDictionary *uploadedItem = [response firstObject];
                                            blockSP.uuid = [uploadedItem[@"id"] stringValue];
                                            blockSP.mainImageUrl = [uploadedItem[@"image_url"] stringByReplacingHttpWithHttps];
                                            shopProductsWithId ++;
                                            
                                        }
                                        else
                                            shopProductsNotUploaded ++;
                                        
                                        if ([strongSelf.shopProducts count] == shopProductsNotUploaded + shopProductsWithId) {
                                            if (strongSelf.completion) {
                                                strongSelf.completion(strongSelf.shopProducts, shopProductsNotUploaded == 0 ? ShopProductsUploadStatusComplete:ShopProductsUploadStatusIncomplete);
                                            }
                                        }
                                        
                                        
                                        
                                    } failure:^(NSError *error) {
                                        __strong STShopProductsUploader *strongSelf = weakSelf;
                                        shopProductsNotUploaded ++;
                                        if ([strongSelf.shopProducts count] == shopProductsNotUploaded + shopProductsWithId) {
                                            if (strongSelf.completion) {
                                                strongSelf.completion(strongSelf.shopProducts, shopProductsNotUploaded == 0 ? ShopProductsUploadStatusComplete:ShopProductsUploadStatusIncomplete);
                                            }
                                        }
                                        
                                    }];
        }
    }
    
    if ([self.shopProducts count] == shopProductsNotUploaded + shopProductsWithId) {
        if (_completion) {
            _completion(self.shopProducts, shopProductsNotUploaded == 0 ? ShopProductsUploadStatusComplete:ShopProductsUploadStatusIncomplete);
        }
    }
}

@end
