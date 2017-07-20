//
//  STWithdrawDetailsSectionViewModel.h
//  Status
//
//  Created by Cosmin Andrus on 15/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STWDInputViewModel.h"

@interface STWDSectionViewModel : NSObject

@property (nonatomic, strong, readonly) NSString *sectionName;
@property (nonatomic, strong, readonly) NSArray <STWDInputViewModel *> *inputs;

-(instancetype)initWithName:(NSString *)sectionName
                  andInputs:(NSArray <STWDInputViewModel *>*)inputs;

-(STWDInputViewModel *)inputVMAtIndex:(NSInteger)index;
-(BOOL)hasChanges;
@end
