//
//  STCustomCollectionViewCell.h
//  Status
//
//  Created by silviu on 2/16/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCustomCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

    // if setupDict is nil, the cell will be setted as a placeholder
- (void)setUpWithDictionary:(NSDictionary *)setupDict forFlowType:(int)flowType;
- (void)updateLikeBtnAndLblWithDict:(NSDictionary *)setUpDict;
-(void)addCaptionShadowWithExtraSpace:(CGFloat)extrHeight;
- (void)captionShadowPressed:(id)sender;
@end