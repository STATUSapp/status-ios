//
//  STWithdrawDetailsInputCell.m
//  Status
//
//  Created by Cosmin Andrus on 15/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STWithdrawDetailsInputCell.h"
#import "STWDInputViewModel.h"

@interface STWithdrawDetailsInputCell ()
@property (weak, nonatomic) IBOutlet UILabel *inputTitle;
@property (weak, nonatomic) IBOutlet UITextField *inputTextView;

@end

@implementation STWithdrawDetailsInputCell

-(void)configureWithInputViewModel:(STWDInputViewModel *)inputVM{
    _inputTitle.text = inputVM.inputName;
    _inputTextView.text = inputVM.inputValue;
    _inputTextView.placeholder = inputVM.inputPlaceholder;
}
@end
