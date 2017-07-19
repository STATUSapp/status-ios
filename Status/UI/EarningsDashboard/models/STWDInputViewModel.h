//
//  STWithdrawDetailsInputViewModel.h
//  Status
//
//  Created by Cosmin Andrus on 15/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STWDInputViewModel : NSObject

@property (nonatomic, strong, readonly) NSString *inputName;
@property (nonatomic, strong, readonly) NSString *inputValue;
@property (nonatomic, strong, readonly) NSString *inputPlaceholder;

-(instancetype)initWithName:(NSString *)inputName
                      value:(NSString *)inputValue
                placehodler:(NSString *)inputPlaceholder;

-(void)updateValue:(NSString *)value;
@end
