//
//  STWithdrawDetailsHeader.h
//  Status
//
//  Created by Cosmin Andrus on 15/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STWDSectionViewModel;

@interface STWithdrawDetailsHeader : UICollectionReusableView

-(void)configureWithSectionViewModel:(STWDSectionViewModel *)sectionVM;

@end
