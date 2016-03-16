//
//  STCustomShareView.m
//  Status
//
//  Created by Andrus Cosmin on 04/03/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STCustomShareView.h"
#import "STLocalNotificationService.h"

CGFloat const kDefaultButtonHeight = 50.f;
NSInteger const kShareViewTag = 1001;

@interface STCustomShareView()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrMoveScaleHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrDeleteHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrEditHeight;
@property (weak, nonatomic) IBOutlet UIImageView *lineDelete;
@property (weak, nonatomic) IBOutlet UIImageView *lineMoveAndScale;
@property (weak, nonatomic) IBOutlet UIImageView *lineEdit;
@property (weak, nonatomic) IBOutlet UIButton *deletaBtn;
@property (weak, nonatomic) IBOutlet UIButton *moveScaleBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIView *shadowView;

@property (nonatomic, strong) NSString *postUuid;
@end

@implementation STCustomShareView

+(void)presentViewForPostId:(NSString *)postUuid
          withExtendedRights:(BOOL)extendedRights{
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"STCustomShareView" owner:self options:nil];
    
    STCustomShareView *shareOptionsView = (STCustomShareView*)[array objectAtIndex:0];
    shareOptionsView.postUuid = postUuid;
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

+(void)dismissView{
    UIWindow *mainWindow = [[UIApplication sharedApplication].delegate window];
    STCustomShareView *shareOptionsView = [mainWindow viewWithTag:kShareViewTag];
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

    _constrDeleteHeight.constant = _constrMoveScaleHeight.constant = _constrEditHeight.constant = (extendedRights ? kDefaultButtonHeight : 0);
    _deletaBtn.hidden = _moveScaleBtn.hidden = _editBtn.hidden = !extendedRights;
    _lineDelete.hidden = _lineMoveAndScale.hidden = _lineEdit.hidden = !extendedRights;

}

-(void) setAlfaForDissmiss:(BOOL) isDissmissed{

    for (UIView * view in self.subviews) {
        view.alpha = isDissmissed ? 0 : 1;
    }
}

#pragma mark - IBActions

- (IBAction)onCancelPressed:(id)sender {
    [STCustomShareView dismissView];
}
- (IBAction)onReportPost:(id)sender {
    [[CoreManager notificationService] postNotificationName:STOptionsViewReportPostNotification object:nil userInfo:@{kPostIdKey:_postUuid}];
}
- (IBAction)onDeletePost:(id)sender {
    [[CoreManager notificationService] postNotificationName:STOptionsViewDeletePostNotification object:nil userInfo:@{kPostIdKey:_postUuid}];
}
- (IBAction)onEditPost:(id)sender {
    [[CoreManager notificationService] postNotificationName:STOptionsViewEditPostNotification object:nil userInfo:@{kPostIdKey:_postUuid}];
}
- (IBAction)onMoveAndScale:(id)sender {
    [[CoreManager notificationService] postNotificationName:STOptionsViewMoveAndScaleNotification object:nil userInfo:@{kPostIdKey:_postUuid}];
}
- (IBAction)onSaveLocally:(id)sender {
    [[CoreManager notificationService] postNotificationName:STOptionsViewSaveNotification object:nil userInfo:@{kPostIdKey:_postUuid}];
    
}
- (IBAction)onShareFb:(id)sender {
    [[CoreManager notificationService] postNotificationName:STOptionsViewShareFbNotification object:nil userInfo:@{kPostIdKey:_postUuid}];
}


@end
