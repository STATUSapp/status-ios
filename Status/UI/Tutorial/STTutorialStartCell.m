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
    [attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ProximaNova-Bold" size:17.f] range:NSMakeRange(0, [facebookLoginTitle length])];
    
    [attributedString addAttribute:NSKernAttributeName
                             value:@(2)
                             range:NSMakeRange(0,[facebookLoginTitle length])];
    

    NSMutableAttributedString *defaultAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];
    
    NSMutableAttributedString *selectedAttributedString = [[NSMutableAttributedString alloc] initWithAttributedString:attributedString];

    [defaultAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]
                             range:NSMakeRange(0, facebookLoginTitle.length)];

    [selectedAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite:1.f alpha:0.5f]
                                    range:NSMakeRange(0, facebookLoginTitle.length)];

    [_facebookLoginButton setAttributedTitle:defaultAttributedString forState:UIControlStateNormal] ;
    [_facebookLoginButton setAttributedTitle:selectedAttributedString forState:UIControlStateHighlighted] ;

    

}

@end
