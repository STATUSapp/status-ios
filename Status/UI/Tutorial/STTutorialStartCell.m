//
//  STTutorialStartCell.m
//  Status
//
//  Created by Cosmin Andrus on 05/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import "STTutorialStartCell.h"

@interface STTutorialStartCell ()
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginButton;

@end

@implementation STTutorialStartCell

-(void)configureCell{
    NSString *facebookLoginTitle = @"FACEBOOK LOGIN";
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:facebookLoginTitle];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]
                             range:NSMakeRange(0, facebookLoginTitle.length)];
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Bold" size:17.f] range:NSMakeRange(0, [facebookLoginTitle length])];
    
    [attributedString addAttribute:NSKernAttributeName
                             value:@(2)
                             range:NSMakeRange(0,[facebookLoginTitle length])];
    [_facebookLoginButton setAttributedTitle:attributedString forState:UIControlStateNormal] ;
    

}

@end
