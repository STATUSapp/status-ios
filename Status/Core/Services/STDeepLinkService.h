//
//  STDeepLinkService.h
//  Status
//
//  Created by Cosmin Andrus on 26/06/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STDeepLinkService : NSObject

- (NSArray <UIViewController *> *)redirectViewControllers;
- (void) addParams:(NSDictionary *)redirectParams;

@end
