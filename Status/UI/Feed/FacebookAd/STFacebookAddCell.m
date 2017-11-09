//
//  STFacebookAddCell.m
//  Status
//
//  Created by Cosmin Andrus on 09/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STFacebookAddCell.h"
#import "STAdPost.h"

@interface STFacebookAddCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerHeightConstr;
@property (weak, nonatomic) IBOutlet UIImageView *adIcon;
@property (weak, nonatomic) IBOutlet UILabel *adTitle;
@property (weak, nonatomic) IBOutlet UIImageView *adMediaImage;
@property (weak, nonatomic) IBOutlet UIButton *CTAButton;
@property (weak, nonatomic) IBOutlet UILabel *adBody;

@end

@implementation STFacebookAddCell

-(void)configureWithAdPost:(STAdPost *)adPost{
    
}

+(CGSize)cellSizeWithAdPost:(STAdPost *)adPost{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;

    return CGSizeMake(screenSize.width, 350.f);
}
@end
