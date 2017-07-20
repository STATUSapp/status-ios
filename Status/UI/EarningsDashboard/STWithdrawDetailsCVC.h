//
//  STWithdrawDetailsCVC.h
//  Status
//
//  Created by Cosmin Andrus on 15/07/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol STWithdrawDetailsChildCVCProtocol <NSObject>

-(void)childCVCHasChanges:(BOOL)hasChanges;

@end

@interface STWithdrawDetailsCVC : UICollectionViewController
@property (nonatomic, weak) id<STWithdrawDetailsChildCVCProtocol>delegate;
-(void)save;

@end
