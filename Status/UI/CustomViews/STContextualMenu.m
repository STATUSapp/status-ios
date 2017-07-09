//
//  STCustomShareView.m
//  Status
//
//  Created by Andrus Cosmin on 04/03/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STContextualMenu.h"
#import "STLocalNotificationService.h"
#import "STPost.h"
#import "STPostsPool.h"
#import "STDataAccessUtils.h"

CGFloat const kDefaultButtonHeight = 50.f;
NSInteger const kShareViewTag = 1001;

@interface STContextualMenu()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrDeleteHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrEditHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constrAskUserHeight;
@property (weak, nonatomic) IBOutlet UIImageView *lineDelete;
@property (weak, nonatomic) IBOutlet UIImageView *lineEdit;
@property (weak, nonatomic) IBOutlet UIImageView *askUserLine;
@property (weak, nonatomic) IBOutlet UIButton *deletaBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *askUserBtn;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIImageView *reportPostLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *reportPostHeightConstr;
@property (weak, nonatomic) IBOutlet UIButton *reportPostButton;

@property (nonatomic, weak) id <STContextualMenuDelegate>delegate;
@end

@implementation STContextualMenu

+(void)presentViewWithDelegate:(id<STContextualMenuDelegate>)delegate
          withExtendedRights:(BOOL)extendedRights{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"STContextualMenu" owner:self options:nil];
    
    STContextualMenu *shareOptionsView = (STContextualMenu*)[array objectAtIndex:0];
    shareOptionsView.delegate = delegate;
    shareOptionsView.hidden = TRUE;
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    shareOptionsView.frame = mainWindow.frame;
    shareOptionsView.tag = kShareViewTag;
    [shareOptionsView setUpForExtendedRights:extendedRights];
    shareOptionsView.translatesAutoresizingMaskIntoConstraints = YES;
    [mainWindow addSubview:shareOptionsView];
    
    shareOptionsView.shadowView.alpha = 0.0;
    [UIView animateWithDuration:0.35f animations:^{
        shareOptionsView.hidden=FALSE;
        shareOptionsView.shadowView.alpha = 0.5;
        [shareOptionsView setAlfaForDissmiss:NO];
    }];


}

+(void)presentProfileViewWithDelegate:(id<STContextualMenuDelegate>)delegate{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"STContextualMenu" owner:self options:nil];
    
    STContextualMenu *shareOptionsView = (STContextualMenu*)[array objectAtIndex:1];
    shareOptionsView.delegate = delegate;
    shareOptionsView.hidden = TRUE;
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    shareOptionsView.frame = mainWindow.frame;
    shareOptionsView.tag = kShareViewTag;
    shareOptionsView.translatesAutoresizingMaskIntoConstraints = YES;
    [mainWindow addSubview:shareOptionsView];
    
    shareOptionsView.shadowView.alpha = 0.0;
    [UIView animateWithDuration:0.35f animations:^{
        shareOptionsView.hidden=FALSE;
        shareOptionsView.shadowView.alpha = 0.5;
        [shareOptionsView setAlfaForDissmiss:NO];
    }];
}

+(void)dismissView{
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    STContextualMenu *shareOptionsView = [mainWindow viewWithTag:kShareViewTag];
    [UIView animateWithDuration:0.35f animations:^{
        [shareOptionsView setAlfaForDissmiss:YES];
        shareOptionsView.shadowView.alpha = 0.0;
    }  completion:^(BOOL finished) {
        shareOptionsView.hidden = TRUE;
        [shareOptionsView removeFromSuperview];
    }];
}

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

-(void) setUpForExtendedRights:(BOOL)extendedRights{

    _constrDeleteHeight.constant = _constrEditHeight.constant = (extendedRights ? kDefaultButtonHeight : 0);
    _constrAskUserHeight.constant = _reportPostHeightConstr.constant = (!extendedRights ? kDefaultButtonHeight : 0);
    _deletaBtn.hidden = _editBtn.hidden = !extendedRights;
    _askUserBtn.hidden = _reportPostButton.hidden = extendedRights;
    _lineDelete.hidden = _lineEdit.hidden = !extendedRights;
    _askUserLine.hidden = _reportPostLine.hidden = extendedRights;
    

}

-(void) setAlfaForDissmiss:(BOOL) isDissmissed{

    for (UIView * view in self.subviews) {
        view.alpha = isDissmissed ? 0 : 1;
    }
}

#pragma mark - IBActions

- (IBAction)onCancelPressed:(id)sender {
    [STContextualMenu dismissView];
}
- (IBAction)onReportPost:(id)sender {
    [_delegate contextualMenuReportPost];
}
- (IBAction)onDeletePost:(id)sender {
    [_delegate contextualMenuDeletePost];
}
- (IBAction)onEditPost:(id)sender {
    [_delegate contextualMenuEditPost];
}
- (IBAction)onSaveLocally:(id)sender {
    [_delegate contextualMenuSavePostLocally];
    
}
- (IBAction)onShareFb:(id)sender {
    [_delegate contextualMenuSharePostonFacebook];
}

- (IBAction)onAskUser:(id)sender {
    [_delegate contextualMenuAskUserToUpload];    
}

-(IBAction)onCopyShareUrl:(id)sender{
    [_delegate contextualMenuCopyShareUrl];
}

-(IBAction)onCopyProfileUrl:(id)sender{
    [_delegate contextualMenuCopyProfileUrl];
}

@end
