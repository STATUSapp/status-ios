//
//  NSString+VersionComparison.h
//  Status
//
//  Created by Andrus Cosmin on 12/02/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (VersionComparison)

-(BOOL)isGreaterThanVersion:(NSString *)version;
-(BOOL)isGreaterThanEqualWithVersion:(NSString *)version;
-(BOOL)isSmallerThanVersion:(NSString *)version;
-(BOOL)isSmallerThanEqualWithVersion:(NSString *)version;

@end
