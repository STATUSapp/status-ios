//
//  STWithdrawDetailsSectionViewModel.m
//  Status
//
//  Created by Cosmin Andrus on 15/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STWDSectionViewModel.h"

@interface STWDSectionViewModel ()

@property (nonatomic, strong, readwrite) NSString *sectionName;
@property (nonatomic, strong, readwrite) NSArray <STWDInputViewModel *> *inputs;

@end
@implementation STWDSectionViewModel

-(instancetype)initWithName:(NSString *)sectionName
                  andInputs:(NSArray <STWDInputViewModel *>*)inputs{
    self = [super init];
    if (self) {
        _sectionName = sectionName;
        _inputs = inputs;
    }
    
    return self;
}

-(STWDInputViewModel *)inputVMAtIndex:(NSInteger)index{
    return _inputs[index];
}
@end
