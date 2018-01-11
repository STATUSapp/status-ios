//
//  ProcessorsService.m
//  Status
//
//  Created by Andrus Cosmin on 13/04/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STProcessorsService.h"
#import "STFlowProcessor.h"

@interface STProcessorsService ()
{
    NSArray *allowedTypes;
}
@property (nonatomic, strong) NSMutableArray *processorsArray;

@end

@implementation STProcessorsService

-(instancetype)init{
    self = [super init];
    if (self) {
        allowedTypes = @[@(STFlowTypeDiscoverNearby),
                         @(STFlowTypePopular),
                         @(STFlowTypeRecent)];
        _processorsArray = [NSMutableArray new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDidLoggedIn) name:kNotificationUserDidLoggedIn object:nil];

    }
    return self;
}

#pragma mark -UINotifications
-(void)userDidLoggedIn{
    //reload all the processors
    for (STFlowProcessor *fp in _processorsArray) {
        [fp reloadProcessor];
    }
}

-(STFlowProcessor *)getProcessorWithType:(STFlowType)type{
    if (![allowedTypes containsObject:@(type)]) {
#ifdef DEBUG
        NSLog(@"STProcessorsService is called with unallowed type. Debug this ASAP.");
#endif
        return nil;
    }
    
    STFlowProcessor *resultProcessor = nil;
    for (STFlowProcessor *processor in _processorsArray) {
        if([processor processorFlowType] == type){
            resultProcessor = processor;
            break;
        }
    }
    
    if (resultProcessor == nil) {
        resultProcessor = [[STFlowProcessor alloc] initWithFlowType:type];
        [_processorsArray addObject:resultProcessor];
    }
    
    return resultProcessor;
}

@end
