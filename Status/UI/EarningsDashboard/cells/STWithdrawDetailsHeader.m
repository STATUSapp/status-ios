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
    _headerTitle.text = sectionVM.sectionName;
}
@end
