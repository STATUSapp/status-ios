//
//  STCustomSegment.m
//  Status
//
//  Created by Cosmin Andrus on 27/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STCustomSegment.h"

CGFloat const kSegmentViewMargins = 40.f;
NSInteger const kButtonTagOffset = 100;
CGFloat const kButtonHeight = 44.f;

@interface STCustomSegment ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectionWidthConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectionLeadingConstr;
@property (nonatomic, weak) id <STSCustomSegmentProtocol>delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstr;
@end

@implementation STCustomSegment

+ (STCustomSegment *)customSegmentWithDelegate:(id<STSCustomSegmentProtocol>)delegate{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"STCustomSegment" owner:delegate options:nil];
    STCustomSegment *customSegment = (STCustomSegment *)[views firstObject];
    
    [customSegment configureSegmentWithDelegate:delegate];
    
    return customSegment;
}

- (void)selectSegmentIndex:(NSInteger)index{
    UIButton *button = [self viewWithTag:index + kButtonTagOffset];
    [self onSegmentButtonPressed:button];
}

- (void)configureSegmentWithDelegate:(id<STSCustomSegmentProtocol>)delegate{
    self.delegate = delegate;
    [self configureView];
}

- (CGFloat)buttonWidth{
    NSInteger numberOfButtons = [_delegate numberOfButtons];
    CGSize requiredSize = [self requiredSize];
    CGFloat screenWidth = requiredSize.width;
    CGFloat availableWidth = screenWidth - kSegmentViewMargins;
    CGFloat buttonWidth = availableWidth / numberOfButtons;
    
    return buttonWidth;

}

- (CGSize)requiredSize{
    CGFloat bottomSpace = [_delegate bottomSpace];
    CGFloat topSpace = [_delegate topSpace];
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, bottomSpace + topSpace + kButtonHeight);
}

- (void)configureView{
    // add buttons
    NSInteger numberOfButtons = [_delegate numberOfButtons];

    CGFloat buttonWidth = [self buttonWidth];
    
    CGSize requiredSize = [self requiredSize];
    CGRect rect = self.frame;
    rect.size = requiredSize;
    self.frame = rect;
    
    CGFloat topSpace = [_delegate topSpace];
    CGFloat bottomSpace = [_delegate bottomSpace];
    _bottomConstr.constant = bottomSpace;
    
    CGSize buttonSize = CGSizeMake(buttonWidth, kButtonHeight);
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 15, 0);

    for (int i =0 ; i< numberOfButtons; i++) {
        CGPoint origin = CGPointMake(i * buttonWidth + kSegmentViewMargins/2.f, topSpace);
        CGRect frame = CGRectZero;
        frame.origin = origin;
        frame.size = buttonSize;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        NSString *stringTitle = [self.delegate buttonTitleForIndex:i];
        [button setTitle:stringTitle forState:UIControlStateNormal];
        [button setTitle:stringTitle forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:17.f];
        UIColor *color = [UIColor colorWithRed:38.f/255.f
                                         green:38.f/255.f
                                          blue:38.f/255.f
                                         alpha:1.f];
        [button setTitleColor:color forState:UIControlStateNormal];
        [button setTitleColor:color forState:UIControlStateSelected];
        button.tag = kButtonTagOffset + i;
        [button addTarget:self
                   action:@selector(onSegmentButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        button.contentEdgeInsets = insets;
        [self addSubview:button];
    }
    
    //configure the selection
    _selectionWidthConstr.constant = buttonWidth;
    
    //add the default selection
    
    if (_delegate && [_delegate respondsToSelector:@selector(defaultSelectedIndex)]) {
        NSInteger defaultIndex = [_delegate defaultSelectedIndex];
        
        UIButton *button = [self viewWithTag:kButtonTagOffset + defaultIndex];
        if (button) {
            [self onSegmentButtonPressed:button];
        }
    }
    
}

- (void)onSegmentButtonPressed:(id)sender{
    UIButton *button = (UIButton *)sender;
    
    [self.delegate buttonPressedAtIndex:button.tag - kButtonTagOffset];
    
    CGFloat leading = (button.tag - kButtonTagOffset) * [self buttonWidth] + (kSegmentViewMargins / 2.f);
    
    [UIView animateWithDuration:0.33f
                     animations:^{
                         _selectionLeadingConstr.constant = leading;
                         [self layoutIfNeeded];
                     }];
}

@end
