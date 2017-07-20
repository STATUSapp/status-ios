//
//  STWithdrawDetailsHeader.m
//  Status
//
//  Created by Cosmin Andrus on 15/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STWithdrawDetailsHeader.h"
#import "STWDSectionViewModel.h"

@interface STWithdrawDetailsHeader ()
@property (weak, nonatomic) IBOutlet UILabel *headerTitle;

@end

@implementation STWithdrawDetailsHeader

-(void)configureWithSectionViewModel:(STWDSectionViewModel *)sectionVM{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:sectionVM.sectionName];
    [attributedString addAttribute:NSKernAttributeName
                             value:@(3.5)
                             range:NSMakeRange(0, sectionVM.sectionName.length)];
    _headerTitle.attributedText = attributedString;
}
@end
