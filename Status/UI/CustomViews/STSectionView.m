//
//  STSectionView.m
//  Status
//
//  Created by Cosmin Andrus on 02/01/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STSectionView.h"

@implementation STSectionView

+ (STSectionView *)sectionViewWithOwner:(id)owner{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"STSectionView" owner:owner options:nil];
    STSectionView *view = (STSectionView *)[array firstObject];
    return view;
}

@end
