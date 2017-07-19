//
//  STWithdrawDetailsInputCell.m
//  Status
//
//  Created by Cosmin Andrus on 15/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STWithdrawDetailsInputCell.h"
#import "STWDInputViewModel.h"
#import "STIndexPathTextField.h"

@interface STWithdrawDetailsInputCell ()
@property (weak, nonatomic) IBOutlet UILabel *inputTitle;
@property (weak, nonatomic) IBOutlet STIndexPathTextField *inputTextView;

@end

@implementation STWithdrawDetailsInputCell

-(void)configureWithInputViewModel:(STWDInputViewModel *)inputVM
                      andIndexPath:(NSIndexPath *)indexPath{
    _inputTitle.text = inputVM.inputName;
    _inputTextView.text = inputVM.inputValue;
    _inputTextView.placeholder = inputVM.inputPlaceholder;
    _inputTextView.indexPath = indexPath;
}

-(void)prepareForReuse{
    _inputTextView.indexPath = nil;
}
@end
