//
//  NSIndexPath+Additions.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 01/11/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "NSIndexPath+Additions.h"

@implementation NSIndexPath (Additions)
+(NSInteger)tagForIndexPath:(NSIndexPath*)indexPath{
    NSInteger tag = indexPath.row + (indexPath.section<<8);
    return tag;
}

+(NSIndexPath*)indexPathWithTag:(NSInteger)tag{
    NSInteger section = tag>>8;
    NSInteger row =  tag & 0xFF;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    return indexPath;
}
@end
