//
//  UILabel+TopRanking.h
//  Status
//
//  Created by Cosmin Andrus on 15/07/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STTopBase;

@interface UILabel (TopRanking)

- (void)configureWithTop:(STTopBase *)top;

@end
