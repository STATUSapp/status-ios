//
//  STTagBrandCell.h
//  Status
//
//  Created by Cosmin Andrus on 29/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STTagBrandCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *separatorView;

-(void)setNoBrandFound;
@end
