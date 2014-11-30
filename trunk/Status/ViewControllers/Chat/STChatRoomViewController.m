//
//  STChatRoomViewController.m
//  Status
//
//  Created by Andrus Cosmin on 27/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STChatRoomViewController.h"
#import "STMessageReceivedCell.h"
#import "STMessageSendCell.h"
#import "HPGrowingTextView.h"
#import "UIImageView+Mask.h"
#import "STImageCacheController.h"
#import "STChatController.h"
#import "STFlowTemplateViewController.h"
#import "STFacebookLoginController.h"
#import "AppDelegate.h"
#import "STCoreDataRequestManager.h"
#import "STDAOEngine.h"
#import "STCoreDataManager.h"
#import "Message.h"
#import "STNetworkQueueManager.h"
#import "UIImageView+WebCache.h"

#import "STGetUserInfoRequest.h"

static NSInteger const  kBlockUserAlertTag = 11;

@interface STChatRoomViewController ()<UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate, STChatControllerDelegate, STRechabilityDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate, SLCoreDataRequestManagerDelegate>
{
    NSMutableArray *_messages;
    UIImage *userImage;
    STChatController *chatController;
    NSString *_roomId;
    
    UIAlertView *statusAlert;
    BOOL deliberateDismiss;
    STCoreDataRequestManager *_currentManager;
    NSInteger loadMoreIndex;
    UIActionSheet *actionSheet;
    UIAlertView *successBlockAlert;
    CGPoint lastContentOffset;
    CGRect keyboardBounds;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet HPGrowingTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTextViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@property (weak, nonatomic) IBOutlet UIButton *userNameLbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewWidth;


@end

@implementation STChatRoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)loadUserInfo
{
    [_userNameLbl setTitle:_userInfo[@"user_name"] forState:UIControlStateNormal];
    [_userNameLbl setTitle:_userInfo[@"user_name"] forState:UIControlStateHighlighted];
    NSString *photoLink = _userInfo[@"small_photo_link"];
    if (photoLink == nil) {
        photoLink = _userInfo[@"full_photo_link"];
    }
    __weak STChatRoomViewController *weakSelf = self;
    
    [_userImg sd_setImageWithURL:[NSURL URLWithString:photoLink] placeholderImage:[UIImage imageNamed:@"btn_nrLIkes_normal"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        userImage = image;
        [weakSelf.tableView reloadData];
        [weakSelf.userImg maskImage:userImage];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _textView.userInteractionEnabled = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    _messages = [NSMutableArray new];

    [self initiateCustomControls];
    if (_userInfo[@"user_name"] == nil) {//notification, need fetch
        __weak STChatRoomViewController *weakSelf = self;
        STRequestCompletionBlock completion = ^(id response, NSError *error){
            if([response[@"status_code"] integerValue] == STWebservicesSuccesCod){
                [weakSelf.userInfo addEntriesFromDictionary:response];
                [weakSelf loadUserInfo];
            }
        };
        [STGetUserInfoRequest getInfoForUser:_userInfo[@"user_id"] completion:completion failure:nil];
    }
    else
        [self loadUserInfo];
    chatController = [STChatController sharedInstance];
    chatController.delegate = self;
    chatController.rechabilityDelegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (chatController.authenticated == YES) {
        [chatController openChatRoomForUserId:_userInfo[@"user_id"]];
    }
    else
        [chatController authenticate];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if(_roomId){
        [chatController leaveRoom:_roomId];
    }
}

- (void)initiateCustomControls {
	    
    _textView.isScrollable = YES;
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    _textView.font = [UIFont fontWithName:@"Helvetica Neue" size:16.f];
	_textView.minNumberOfLines = 1;
	_textView.maxNumberOfLines = 5;
	_textView.returnKeyType = UIReturnKeyDefault; //just as an example
	_textView.delegate = self;
    _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _textView.backgroundColor = [UIColor clearColor];
    _textView.placeholder = @"Message";
    
}

#pragma mark - Keyboard Notifications

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    
	// get a rect for the textView frame
	CGRect containerFrame = _containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height);

	// animations settings
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationShowStopped)];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    _containerView.frame = containerFrame;
    [UIView commitAnimations];

}

-(void) animationShowStopped{
    
    [UIView animateWithDuration:0.1 animations:^{
        [_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];

    }];
    _bottomTextViewConstraint.constant = keyboardBounds.size.height;

}

-(void) keyboardWillHide:(NSNotification *)note{
	// get a rect for the textView frame
	CGRect containerFrame = _containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;     
    
    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(animationHideStopped)];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    _containerView.frame = containerFrame;
    _bottomTextViewConstraint.constant = 0;
    [UIView commitAnimations];
    
}

#pragma mark - Growing Text Delegate

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = _containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    [UIView animateWithDuration:0.25 animations:^{
        _heightConstraint.constant = height + 7;
        //_bottomTextViewConstraint.constant =
        //_containerView.frame = r;
        if (_messages.count>0) {
            [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
	 
}

-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    _sendBtn.enabled = _textView.text.length>0;
}

-(void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
//    if (growingTextView.text.length > 0) {
//        [self onSendButtonPressed:nil];
//    }
    //[self onSwipeRight:nil];
}

-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView{
    //[self onSwipeRight:nil];
}

-(BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    _textView.text = [NSString stringWithFormat:@"%@\r", _textView.text];
    return NO;
}

#pragma mark - IBActions
- (IBAction)onLoadMore:(id)sender {
    if (_roomId) {
        lastContentOffset = _tableView.contentOffset;
        [chatController getRoomMessages:_roomId withOffset:_messages.count];
    }
}

- (IBAction)onSendButtonPressed:(id)sender {
    if (!_roomId) {
        return;
    }
    NSString *toSendMessage = _textView.text;
    if (toSendMessage.length == 0) {
        return;
    }
    [chatController sendMessage:toSendMessage inRoom:_roomId];
    [_textView setText:@""];
}
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onClickUserName:(id)sender {
    
    if (_userInfo[@"user_id"] == nil) {
        NSLog(@"Error from server. No user id.");
        return;
    }
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    STFlowTemplateViewController *flowCtrl = [storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = STFlowTypeUserProfile;
    flowCtrl.userID = _userInfo[@"user_id"];
    flowCtrl.userName = _userInfo[@"user_name"];
    if ([flowCtrl.userID isEqualToString:[STFacebookLoginController sharedInstance].currentUserId ]) {
        flowCtrl.flowType = STFlowTypeMyProfile;
    }
    [self.navigationController pushViewController:flowCtrl animated:YES];
}
- (IBAction)onClickDelete:(id)sender {
   
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Block User",@"Delete Conversation", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showInView:self.view];
    
    UIColor *tintColor = [UIColor redColor];
    
    NSArray *actionSheetButtons = actionSheet.subviews;
    for (int i = 0; [actionSheetButtons count] > i; i++) {
        UIView *view = (UIView*)[actionSheetButtons objectAtIndex:i];
        if([view isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton*)view;
            if (((UIButton*)view).tag != 3)//Cancel button
                [btn setTitleColor:tintColor forState:UIControlStateNormal];
                
        }
    }
}
- (IBAction)onSwipeLeft:(UISwipeGestureRecognizer *)recognizer {
    _tableViewWidth.constant = 320.f;
    [_tableView setNeedsUpdateConstraints];

    [UIView animateWithDuration:0.0f animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"TOUCH END");
    
}
- (IBAction)onSwipeRight:(id)sender {
    _tableViewWidth.constant = 390.f;
    [_tableView setNeedsUpdateConstraints];

    [UIView animateWithDuration:0.0f animations:^{
        [_tableView layoutIfNeeded];
    }];
}
- (IBAction)onTapBackgound:(id)sender {
    [_textView resignFirstResponder];
}


#pragma mark - STChatControllerDelegate

-(void)chatDidClose{
    NSLog(@"Chat did close");
    [self showStatusAlertWithMessage:@"Your chat connection appears to be offline. You can wait or you can Go Back"];
}
-(void)chatDidOpenRoom:(NSString *)roomId{
    _roomId = roomId;
    _textView.userInteractionEnabled = YES;

    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    _currentManager = [[STDAOEngine sharedManager] fetchRequestManagerForEntity:@"Message" sortDescritors:@[sd1] predicate:[NSPredicate predicateWithFormat:@"roomID like %@", _roomId] sectionNameKeyPath:nil delegate:self andTableView:nil];
    _messages = [NSMutableArray arrayWithArray:_currentManager.allObjects];
    NSNumber *seen = [[_messages valueForKey:@"seen"] valueForKeyPath: @"@sum.self"];
    NSInteger unseen = _messages.count - seen.integerValue;
    [chatController setUnreadMessages:chatController.unreadMessages-unseen];
    [_tableView reloadData];
    
    if (_messages.count > 0) {
        
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
}
-(void)chatDidAuthenticate{
    [self hideStatusAlert];
    [chatController openChatRoomForUserId:_userInfo[@"user_id"]];
}

-(void)userWasBlocked{
    [self showStatusAlertWithMessage:@"This chat room was blocked."];
}

-(void)userBlockSuccess{
    successBlockAlert = [[UIAlertView alloc] initWithTitle:@"Block User" message:@"This user was blocked. You will no longer receive messages from him." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [successBlockAlert show];
}

#pragma mark - STRechabilityDelegate

-(void)networkOff{
    [self showStatusAlertWithMessage:@"Your internet connection appears to be offline. You can wait for better connection or you can Go Back"];
}

-(void)networkOn{
    [self hideStatusAlert];
    [chatController reconnect];
}

#pragma mark Helpers

-(void)showStatusAlertWithMessage:(NSString *)message{
    if (statusAlert==nil && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        statusAlert = [[UIAlertView alloc] initWithTitle:@"Chat" message:message delegate:self cancelButtonTitle:@"GO BACK" otherButtonTitles:nil, nil];
        deliberateDismiss = NO;
        [statusAlert show];
    }
}

-(void)hideStatusAlert{
    deliberateDismiss = YES;
    [statusAlert dismissWithClickedButtonIndex:0 animated:YES];
    statusAlert = nil;
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kBlockUserAlertTag) {
        if (buttonIndex == 1) {
            [chatController blockUserWithId:_userInfo[@"user_id"]];
        }

    }
    else
    {
        if (deliberateDismiss == YES) {
            deliberateDismiss = NO;
            return;
        }
        if ([alertView isEqual:statusAlert]) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {//Block User
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Block User" message:@"Are you sure do you want to block this user?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Block", nil];
        alertView.tag = kBlockUserAlertTag;
        [alertView show];
    }
    else if (buttonIndex == 1){//Delete conversation
        if (_roomId){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomID like %@", _roomId];
            [[STCoreDataManager sharedManager] deleteAllObjectsFromTable:@"Message" withPredicate:predicate];
            [[STCoreDataManager sharedManager] save];
        }
    }
}

#pragma mark - UITableViewDelegate
-(NSString *)getIdentifierForIndexPath:(NSIndexPath *)indexPath{
    Message *message = _messages[indexPath.row];
    BOOL received = ![message.userId isEqualToString:chatController.currentUserId];
    if (received == YES) {
        return @"MessageReceivedCell";
    }
    else
        return @"MessageSendCell";
    return @"";
    
}

-(NSDate *) dateFromServerDate:(NSString *) serverDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSDate *resultDate = [dateFormatter dateFromString:serverDate];
    return resultDate;
}

-(NSString *)shortDateFormat:(NSDate *)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm a"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    return [dateFormatter stringFromDate:date];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identifier = [self getIdentifierForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    Message *message = _messages[indexPath.row];
    BOOL received = ![message.userId isEqualToString:chatController.currentUserId];
    if (received == YES) {
        [(STMessageReceivedCell *)cell configureCellWithMessage:message andUserImage:userImage];
    }
    else
        [(STMessageSendCell *)cell configureCellWithMessage:message];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float height = 50.f;

    Message *message = _messages[indexPath.row];
    BOOL received = ![message.userId isEqualToString:chatController.currentUserId];
    if (received == YES) {
        height = [STMessageReceivedCell cellHeightForMessage:message];
    }
    else
        height = [STMessageSendCell cellHeightForMessage:message];
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _messages.count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_textView resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    _tableView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [actionSheet dismissWithClickedButtonIndex:2 animated:NO];
    [self hideStatusAlert];
    [successBlockAlert dismissWithClickedButtonIndex:0 animated:NO];
    if(_roomId){
        [chatController leaveRoom:_roomId];
        [[STCoreDataManager sharedManager] save];
    }
    chatController.delegate = nil;
    chatController.rechabilityDelegate = nil;
}

-(void)controllerAddedObject:(id)object atIndexPath:(NSIndexPath *)indexPath{
    [_messages insertObject:object atIndex:indexPath.row];
    [UIView setAnimationsEnabled:NO];
    [_tableView beginUpdates];
    [_tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
    [UIView setAnimationsEnabled:YES];
    if (chatController.loadMore==NO) {
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

-(void)controllerRemovedObject:(id)object atIndexPath:(NSIndexPath *)indexPath{
    NSUInteger index = [_messages indexOfObject:object];
    if (index!=NSNotFound) {
        NSIndexPath *objIndex = [NSIndexPath indexPathForRow:index inSection:0];
        [_messages removeObject:object];
        [_tableView beginUpdates];
        [_tableView  deleteRowsAtIndexPaths:@[objIndex] withRowAnimation:UITableViewRowAnimationFade];
        [_tableView endUpdates];

    }
}

@end
