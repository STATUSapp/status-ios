//
//  STCustomSegment.m
//  Status
//
//  Created by Cosmin Andrus on 27/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STCustomSegment.h"

CGFloat const kDefaultSegmentViewMargins = 40.f;
NSInteger const kButtonTagOffset = 100;
CGFloat const kButtonHeight = 44.f;
CGFloat const kSeparatorHeight = 20.f;
@interface STCustomSegment ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectionWidthConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectionLeadingConstr;
@property (nonatomic, weak) id <STSCustomSegmentProtocol>delegate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstr;
@property (nonatomic, assign, readwrite) NSInteger selectedIndex;
@property (weak, nonatomic) IBOutlet UIView *bottomLine;
@property (weak, nonatomic) IBOutlet UIView *bottomSelectionBar;

@end

@implementation STCustomSegment

+ (STCustomSegment *)customSegmentWithDelegate:(id<STSCustomSegmentProtocol>)delegate{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"STCustomSegment" owner:delegate options:nil];
    STCustomSegment *customSegment = (STCustomSegment *)[views firstObject];
    return customSegment;
}

-(CGFloat)usedViewMargins{
    STSegmentSelection selectionType = [self segmentSelectionType];
    if (selectionType == STSegmentSelectionBottomBar) {
        return kDefaultSegmentViewMargins;
    }
    
    return 8.f;
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
    NSInteger numberOfButtons = [_delegate segmentNumberOfButtons:self];
    CGSize requiredSize = [self requiredSize];
    CGFloat screenWidth = requiredSize.width;
    CGFloat availableWidth = screenWidth - [self usedViewMargins];
    CGFloat buttonWidth = availableWidth / numberOfButtons;
    
    return buttonWidth;

}

- (CGSize)requiredSize{
    CGFloat bottomSpace = [_delegate segmentBottomSpace:self];
    CGFloat topSpace = [_delegate segmentTopSpace:self];
    
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, bottomSpace + topSpace + kButtonHeight);
}

- (STSegmentSelection )segmentSelectionType{
    STSegmentSelection selectionType = STSegmentSelectionBottomBar;
    if ([_delegate respondsToSelector:@selector(segmentSelectionForSegment:)]) {
        selectionType = [_delegate segmentSelectionForSegment:self];
    }
    
    return selectionType;
}

- (void)configureView{
    //background color
    UIColor *backgroundColor = [UIColor whiteColor];
    if ([_delegate respondsToSelector:@selector(backgroundColorForSegment:)]) {
        backgroundColor = [_delegate backgroundColorForSegment:self];
    }
    self.backgroundColor = backgroundColor;
    
    //configure selection
    STSegmentSelection selectionType = [self segmentSelectionType];
    if (selectionType == STSegmentSelectionHighlightButton) {
        _bottomLine.hidden = YES;
        _bottomSelectionBar.hidden = YES;
    }
    // add buttons
    NSInteger numberOfButtons = [_delegate segmentNumberOfButtons:self];

    CGFloat buttonWidth = [self buttonWidth];
    
    CGSize requiredSize = [self requiredSize];
    CGRect rect = self.frame;
    rect.size = requiredSize;
    self.frame = rect;
    
    CGFloat topSpace = [_delegate segmentTopSpace:self];
    CGFloat bottomSpace = [_delegate segmentBottomSpace:self];
    _bottomConstr.constant = bottomSpace;
    
    CGSize buttonSize = CGSizeMake(buttonWidth, kButtonHeight + _bottomSelectionBar.frame.size.height);
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 15, 0);

    BOOL shouldAddSeparators = NO;
    if (_delegate && [_delegate respondsToSelector:@selector(segmentShouldHaveOptionsSeparators:)]) {
        shouldAddSeparators = [_delegate segmentShouldHaveOptionsSeparators:self];
    }

    
    for (int i =0 ; i< numberOfButtons; i++) {
        CGPoint origin = CGPointMake(i * buttonWidth + [self usedViewMargins]/2.f, topSpace);
        CGRect frame = CGRectZero;
        frame.origin = origin;
        frame.size = buttonSize;
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = frame;
        NSString *stringTitle = [self.delegate segment:self buttonTitleForIndex:i];
        [button setTitle:stringTitle forState:UIControlStateNormal];
        [button setTitle:stringTitle forState:UIControlStateSelected];
        button.titleLabel.font = [UIFont fontWithName:@"ProximaNova-Semibold" size:17.f];
        UIColor *color = [UIColor colorWithRed:38.f/255.f
                                         green:38.f/255.f
                                          blue:38.f/255.f
                                         alpha:1.f];
        if (selectionType == STSegmentSelectionHighlightButton) {
            UIColor *unselectedColor = [UIColor colorWithRed:38.f/255.f
                                                      green:38.f/255.f
                                                       blue:38.f/255.f
                                                      alpha:0.5f];
            [button setTitleColor:unselectedColor forState:UIControlStateNormal];
            [button setTitleColor:color forState:UIControlStateSelected];
        }
        else
        {
            [button setTitleColor:color forState:UIControlStateNormal];
            [button setTitleColor:color forState:UIControlStateSelected];
        }
        button.tag = kButtonTagOffset + i;
        [button addTarget:self
                   action:@selector(onSegmentButtonPressed:)
         forControlEvents:UIControlEventTouchUpInside];
        button.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
        button.contentEdgeInsets = insets;
        [self addSubview:button];
        
        if (shouldAddSeparators) {
            if (i < numberOfButtons - 1) {
                //not for the last one
                CGRect separatorFrame = CGRectMake(frame.origin.x + frame.size.width, (kButtonHeight - kSeparatorHeight)/2.f, 1.f, kSeparatorHeight);
                UIView *separator = [[UIView alloc] initWithFrame:separatorFrame];
                separator.backgroundColor = [UIColor lightGrayColor];
                [self addSubview:separator];
            }
        }
    }
    
    //configure the selection
    _selectionWidthConstr.constant = buttonWidth;
    
    //add the default selection
    
    if (_delegate && [_delegate respondsToSelector:@selector(segmentDefaultSelectedIndex:)]) {
        NSInteger defaultIndex = [_delegate segmentDefaultSelectedIndex:self];
        _selectedIndex = defaultIndex;
        UIButton *button = [self viewWithTag:kButtonTagOffset + defaultIndex];
        if (button) {
            [self onSegmentButtonPressed:button];
        }
    }
    
}

- (void)onSegmentButtonPressed:(id)sender{
    UIButton *button = (UIButton *)sender;
    NSInteger previuosSelectedIndex = _selectedIndex;
    _selectedIndex = button.tag - kButtonTagOffset;
    [self.delegate segment:self buttonPressedAtIndex:_selectedIndex];
    
    STSegmentSelection selectionType = [self segmentSelectionType];

    if (selectionType == STSegmentSelectionHighlightButton) {
        UIButton *previuosSelectedButton = [self viewWithTag:kButtonTagOffset + previuosSelectedIndex];
        previuosSelectedButton.selected = NO;
        button.selected = YES;
    }
    else
    {
        CGFloat leading = (button.tag - kButtonTagOffset) * [self buttonWidth] + ([self usedViewMargins] / 2.f);
        [UIView animateWithDuration:0.33f
                         animations:^{
                             self.selectionLeadingConstr.constant = leading;
                             [self layoutIfNeeded];
                         }];
    }
    
}

@end
