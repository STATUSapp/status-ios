//
//  STSectionView.h
//  Status
//
//  Created by Cosmin Andrus on 02/01/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STSectionView : UIView

@property (weak, nonatomic) IBOutlet UILabel *sectionLabel;

+ (STSectionView *)sectionViewWithOwner:(id)owner;
@end
