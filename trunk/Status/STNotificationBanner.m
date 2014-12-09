//
//  STNotificationBanner.m
//  Status
//
//  Created by Cosmin Andrus on 09/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STNotificationBanner.h"

@implementation STNotificationBanner

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (IBAction)onClosePressed:(id)sender {
    [_delegate bannerPressedClose];
}
- (IBAction)onBannerTapped:(id)sender {
    [_delegate bannerTapped];
}

@end
