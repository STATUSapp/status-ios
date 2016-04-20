//
//  ProcessorsService.h
//  Status
//
//  Created by Andrus Cosmin on 13/04/16.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STFlowProcessor;

@interface STProcessorsService : NSObject

-(STFlowProcessor *)getProcessorWithType:(STFlowType)type;

@end
