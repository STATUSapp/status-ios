//
//  NSIndexPath+Additions.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 01/11/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (Additions)
+(NSIndexPath*)indexPathWithTag:(NSInteger)tag;
+(NSInteger)tagForIndexPath:(NSIndexPath*)indexPath;
@end
