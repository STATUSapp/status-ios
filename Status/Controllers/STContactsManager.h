//
//  STContactsManager.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STContactsManager : NSObject
+(instancetype) sharedInstance;
@property (nonatomic, strong) NSArray *allContacts;
@end
