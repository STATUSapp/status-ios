//
//  STMenuView.m
//  Status
//
//  Created by Cosmin Andrus on 16/09/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STMenuView.h"
#import "STMenuController.h"

@implementation STMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (IBAction)onCloseMenu:(id)sender {
    [[STMenuController sharedInstance] hideMenu];
}
- (IBAction)onHomePressed:(id)sender {
    [[STMenuController sharedInstance] goHome];
}
- (IBAction)onNearbyPressed:(id)sender {
    [[STMenuController sharedInstance] goNearby];
}
- (IBAction)onFriendsInviterPressed:(id)sender {
    [[STMenuController sharedInstance] goFriendsInviter];
}
- (IBAction)onNotificationPressed:(id)sender {
    [[STMenuController sharedInstance] goNotification];
}
- (IBAction)onMePressed:(id)sender {
    [[STMenuController sharedInstance] goMyProfile];
}
- (IBAction)onToturialPressed:(id)sender {
    [[STMenuController sharedInstance] goTutorial];
}
- (IBAction)onSettingsPressed:(id)sender {
    [[STMenuController sharedInstance] goSettings];
}
- (IBAction)onPopularPressed:(id)sender {
    [[STMenuController sharedInstance] goPopular];
}
- (IBAction)onRecentPressed:(id)sender {
    [[STMenuController sharedInstance] goRecent];
}

@end
