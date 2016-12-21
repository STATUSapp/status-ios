//
//  STCustomSegment.h
//  Status
//
//  Created by Cosmin Andrus on 27/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STSCustomSegmentProtocol  <NSObject>

@required
- (CGFloat)topSpace;
- (CGFloat)bottomSpace;
- (NSInteger)numberOfButtons;
- (NSString *)buttonTitleForIndex:(NSInteger)index;
- (void)buttonPressedAtIndex:(NSInteger)index;

@optional
- (NSInteger)defaultSelectedIndex;

@end

@interface STCustomSegment : UIView

+ (STCustomSegment *)customSegmentWithDelegate:(id<STSCustomSegmentProtocol>)delegate;

- (void)selectSegmentIndex:(NSInteger)index;
@end
