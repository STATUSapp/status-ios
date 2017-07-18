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

@end

@implementation STWDInputViewModel


-(instancetype)initWithName:(NSString *)inputName
                      value:(NSString *)inputValue
                placehodler:(NSString *)inputPlaceholder{
    self = [super init];
    if (self) {
        _inputName = inputName;
        _inputValue = inputValue;
        _inputPlaceholder = inputPlaceholder;
    }
    return self;
}

@end
