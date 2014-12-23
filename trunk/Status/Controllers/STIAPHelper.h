//
//  STIAPHelper.h
//  Status
//
//  Created by Silviu Burlacu on 7/7/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

@interface STIAPHelper : NSObject

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

+ (STIAPHelper *)sharedInstance;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;

- (void)restoreCompletedTransactions;

#warning Move this to another place. Maybe a class called UtilityMethods
- (void)showRateAppAlert;

@end
