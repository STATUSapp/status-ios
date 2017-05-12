//
//  STCustomSegment.h
//  Status
//
//  Created by Cosmin Andrus on 27/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
@class STCustomSegment;

@protocol STSCustomSegmentProtocol  <NSObject>

@required
- (CGFloat)segmentTopSpace:(STCustomSegment *)segment;
- (CGFloat)segmentBottomSpace:(STCustomSegment *)segment;
- (NSInteger)segmentNumberOfButtons:(STCustomSegment *)segment;
- (NSString *)segment:(STCustomSegment *)segment
  buttonTitleForIndex:(NSInteger)index;
- (void)segment:(STCustomSegment *)segment
buttonPressedAtIndex:(NSInteger)index;

@optional
- (NSInteger)segmentDefaultSelectedIndex:(STCustomSegment *)segment;

@end

@interface STCustomSegment : UIView

+ (STCustomSegment *)customSegmentWithDelegate:(id<STSCustomSegmentProtocol>)delegate;

@property (nonatomic, assign, readonly) NSInteger selectedIndex;

- (void)configureSegmentWithDelegate:(id<STSCustomSegmentProtocol>)delegate;
- (void)selectSegmentIndex:(NSInteger)index;

@end
