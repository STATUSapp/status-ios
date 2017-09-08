//
//  STExploreFilters.m
//  Status
//
//  Created by Cosmin Andrus on 06/09/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STExploreFilters.h"
@interface STExploreFilters ()

@property (nonatomic, weak) id<STExploreFiltersProtocol>delegate;
@property (nonatomic, assign) STExploreFiltersType type;

@property (weak, nonatomic) IBOutlet UIView *timeframeContainer;
@property (weak, nonatomic) IBOutlet UIButton *dailyButton;
@property (weak, nonatomic) IBOutlet UIButton *weeklyButton;
@property (weak, nonatomic) IBOutlet UIButton *monthlyButton;
@property (weak, nonatomic) IBOutlet UIButton *allTimeButton;
@property (weak, nonatomic) IBOutlet UIButton *womenButton;
@property (weak, nonatomic) IBOutlet UIButton *menButton;
@property (weak, nonatomic) IBOutlet UIButton *bothButton;

@property (strong, nonatomic) UIButton *selectedTimeframe;
@property (strong, nonatomic) UIButton *selectedGender;

@end

@implementation STExploreFilters

+ (STExploreFilters *)exploreFiltersWithDelegate:(id<STExploreFiltersProtocol>)delegate
                                         andType:(STExploreFiltersType)type{
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"STExploreFilters" owner:delegate options:nil];
    
    STExploreFilters *view = (STExploreFilters *)[views firstObject];
    view.delegate = delegate;
    view.type = type;
    [view setDefaultValues];
    return view;

}

-(void)awakeFromNib{
    [super awakeFromNib];
}

-(void)setDefaultValues{
    if (_type == STExploreFiltersTypeRecent) {
        _timeframeContainer.hidden = YES;
    }
    else{
        STExploreFiltersTimeframe defaultTimeframe = [_delegate defaultTimeframeOptionWithSender:self];
        _selectedTimeframe = [self getTimeframeButton:defaultTimeframe];
    }
    
    STExploreFiltersGender defaultGender = [_delegate defaultGenderOptionWithSender:self];
    _selectedGender = [self getGenderButton:defaultGender];
    
    [self configureFilters];
}

-(UIButton *)getTimeframeButton:(STExploreFiltersTimeframe)option{
    UIButton *button = nil;
    switch (option) {
        case STExploreFiltersTimeframeDaily:
            button = _dailyButton;
            break;
        case STExploreFiltersTimeframeWeekly:
            button = _weeklyButton;
            break;
        case STExploreFiltersTimeframeMonthly:
            button = _monthlyButton;
            break;
        case STExploreFiltersTimeframeAllTime:
            button = _allTimeButton;
            break;
    }
    if (!button) {
        NSLog(@"TIMEFRAME BUTTON SHOULD NOT BE NIL");
    }
    return button;
}

-(UIButton *)getGenderButton:(STExploreFiltersGender)option{
    UIButton *button = nil;
    switch (option) {
        case STExploreFiltersGenderWomen:
            button = _womenButton;
            break;
        case STExploreFiltersGenderMen:
            button = _menButton;
            break;
        case STExploreFiltersGenderBoth:
            button = _bothButton;
    }
    if (!button) {
        NSLog(@"GENDER BUTTON SHOULD NOT BE NIL");
    }
    return button;
}

-(STExploreFiltersTimeframe)selectedTimeframeOption{
    if (_type == STExploreFiltersTypeRecent) {
        return -1;//invalid option
    }

    if (_selectedTimeframe == _dailyButton) {
        return STExploreFiltersTimeframeDaily;
    }
    
    if (_selectedTimeframe == _weeklyButton) {
        return STExploreFiltersTimeframeWeekly;
    }
    
    if (_selectedTimeframe == _monthlyButton) {
        return STExploreFiltersTimeframeMonthly;
    }
    
    if (_selectedTimeframe == _allTimeButton) {
        return STExploreFiltersTimeframeAllTime;
    }
    
    NSLog(@"SELECTED TIMEFRAME BUTTON SHOULD NOT BE NIL");
    
    return -1;//invalid option
}

-(STExploreFiltersGender)selectedGenderOption{
    if (_selectedGender == _womenButton) {
        return STExploreFiltersGenderWomen;
    }
    
    if (_selectedGender == _menButton) {
        return STExploreFiltersGenderMen;
    }
    
    if (_selectedGender == _bothButton) {
        return STExploreFiltersGenderBoth;
    }
    
    NSLog(@"SELECTED GENDER BUTTON SHOULD NOT BE NIL");
    
    return -1;//invalid option
}



-(void)configureFilters{
    [_dailyButton setSelected:_dailyButton==_selectedTimeframe];
    [_weeklyButton setSelected:_weeklyButton==_selectedTimeframe];
    [_monthlyButton setSelected:_monthlyButton==_selectedTimeframe];
    [_allTimeButton setSelected:_allTimeButton==_selectedTimeframe];
    
    [_womenButton setSelected:_womenButton==_selectedGender];
    [_menButton setSelected:_menButton==_selectedGender];
    [_bothButton setSelected:_bothButton==_selectedGender];
}


#pragma mark - IBACTIONS
- (IBAction)timeframeOptionSelected:(id)sender {
    if (_type == STExploreFiltersTypeRecent) {
        NSLog(@"THIS ACTION IS NOT ALLOWED FOR RECENT TYPE");
        return;
    }
    if (_selectedTimeframe!=sender) {
        _selectedTimeframe = sender;
        [self configureFilters];
        [self callTheDelegate];
    }
}

- (IBAction)genderOptionSelected:(id)sender {
    if (_selectedGender!=sender) {
        _selectedGender = sender;
        [self configureFilters];
        [self callTheDelegate];
    }
}

-(void)callTheDelegate{
    STExploreFiltersGender selectedGenderOption = [self selectedGenderOption];
    STExploreFiltersTimeframe selectedTimeframeOption = [self selectedTimeframeOption];
    
    [_delegate filtersChangedInTimeFrame:selectedTimeframeOption
                               andGender:selectedGenderOption
                               forSender:self];

}

@end
