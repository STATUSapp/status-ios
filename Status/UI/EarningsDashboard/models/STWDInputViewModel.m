//
//  STWithdrawDetailsInputViewModel.m
//  Status
//
//  Created by Cosmin Andrus on 15/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STWDInputViewModel.h"

@interface STWDInputViewModel ()

@property (nonatomic, strong, readwrite) NSString *inputName;
@property (nonatomic, strong, readwrite) NSString *inputValue;
@property (nonatomic, strong, readwrite) NSString *inputPlaceholder;

@property (nonatomic, strong) NSString *initialInputValue;

@end

@implementation STWDInputViewModel


-(instancetype)initWithName:(NSString *)inputName
                      value:(NSString *)inputValue
                placehodler:(NSString *)inputPlaceholder{
    self = [super init];
    if (self) {
        _inputName = inputName;
        _inputValue = inputValue;
        _initialInputValue = inputValue;
        _inputPlaceholder = inputPlaceholder;
    }
    return self;
}

-(void)updateValue:(NSString *)value{
    _inputValue = value;
}

-(BOOL)hasChanges{
    if (!_initialInputValue) {
        return _inputValue.length > 0;
    }
    
    return ![_initialInputValue isEqualToString:_inputValue];
}

-(NSString *)debugDescription{
    return [NSString stringWithFormat:@"Initial value: %@\nActual value: %@\n", _initialInputValue, _inputValue];
}
@end
