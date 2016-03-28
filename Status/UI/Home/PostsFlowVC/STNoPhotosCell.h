//
//  STNoPhotosCell.h
//  Status
//
//  Created by Cosmin Andrus on 02/02/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STPost;

@interface STNoPhotosCell : UICollectionViewCell
-(void)setUpCellWithUserName:(NSString *)userName andFlow:(STFlowType)flowType;
-(void)configureWithUserName:(NSString *)userName
            isTheCurrentUser:(BOOL)isOwner;
@end
