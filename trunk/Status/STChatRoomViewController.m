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
#import "STFacebookController.h"

@interface STChatRoomViewController ()<UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate, STChatControllerDelegate>
{
    NSMutableArray *_messages;
    UIImage *userImage;
    STChatController *chatController;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet HPGrowingTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTextViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UIImageView *userImg;
@property (weak, nonatomic) IBOutlet UIButton *userNameLbl;


@end

@implementation STChatRoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    _messages = [NSMutableArray new];
    [self generateStringsWithNumber:@(20)];
    //[_tableView reloadData];
    [self initiateCustomControls];
    [_userNameLbl setTitle:_userInfo[@"user_name"] forState:UIControlStateNormal];
    [_userNameLbl setTitle:_userInfo[@"user_name"] forState:UIControlStateHighlighted];
    
    [[STImageCacheController sharedInstance] loadImageWithName:_userInfo[@"small_photo_link"] andCompletion:^(UIImage *img) {
        userImage = img;
        [_tableView reloadData];
        [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        [_userImg maskImage:userImage];
    }];
    chatController = [STChatController sharedInstance];
    chatController.delegate = self;
    [chatController reconnect];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)initiateCustomControls {
	    
    _textView.isScrollable = YES;
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    _textView.font = [UIFont fontWithName:@"Helvetica Neue" size:16.f];
	_textView.minNumberOfLines = 1;
	_textView.maxNumberOfLines = 4;
	_textView.returnKeyType = UIReturnKeySend; //just as an example
	_textView.delegate = self;
    _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _textView.backgroundColor = [UIColor clearColor];
    _textView.placeholder = @"Message";
    
}

#pragma mark - Keyboard Notifications

-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
	CGRect keyboardBounds;
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
    
    _bottomTextViewConstraint.constant = 216.f; //keyboardBounds.size.height;

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
    }];
	 
}

-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    _sendBtn.enabled = _textView.text.length>0;
}

-(void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView{
    if (growingTextView.text.length > 0) {
        [self onSendButtonPressed:nil];
    }
    
}

-(BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView{
    return [_textView resignFirstResponder];
}

-(void)resignTextView
{
	[_textView resignFirstResponder];
}

#pragma mark - IBActions

- (IBAction)onSendButtonPressed:(id)sender {
    [_messages addObject:_textView.text];
    [chatController sendMessage:_textView.text inRoom:_roomId];
    [_textView setText:@""];
    [_textView resignFirstResponder];
    
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onClickUserName:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    STFlowTemplateViewController *flowCtrl = [storyboard instantiateViewControllerWithIdentifier: @"flowTemplate"];
    flowCtrl.flowType = STFlowTypeUserProfile;
    flowCtrl.userID = _userInfo[@"user_id"];
    flowCtrl.userName = _userInfo[@"user_name"];
    if ([flowCtrl.userID isEqualToString:[STFacebookController sharedInstance].currentUserId ]) {
        flowCtrl.flowType = STFlowTypeMyProfile;
    }
    [self.navigationController pushViewController:flowCtrl animated:YES];
}
- (IBAction)onClickDelete:(id)sender {
    [chatController close];
    //chatController.delegate = nil;
}

#pragma mark - STChatControllerDelegate

-(void)chatDidClose{
    NSLog(@"Chat did close");
}
-(void)chatDidReceivedMesasage:(NSString *)message{
    [_messages addObject:message];
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)chatDidOpenRoom:(NSString *)roomId{
    _roomId = roomId;
}
-(void)chatDidAuthenticate{
    //TODO: check if this is right
    [chatController openChatRoomForUserId:_userInfo[@"id"]];
}

#pragma mark - UITableViewDelegate
-(NSString *)getIdentifierForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row%2==0) {
        return @"MessageReceivedCell";
    }
    return @"MessageSendCell";
        
}

-(void)generateStringsWithNumber:(NSNumber *)nr{
    NSString *str = @"Message ";
    
    for (int i=0; i<nr.intValue; i++) {
        str = [str stringByAppendingString:@"asafd "];
        [_messages addObject:[str copy]];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identifier = [self getIdentifierForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    NSString *message = [_messages objectAtIndex:indexPath.row];
    if (indexPath.row%2==0) {
        [(STMessageReceivedCell *)cell configureCellWithMessage:message andUserImage:userImage];
    }
    else
    {
        [(STMessageSendCell *)cell configureCellWithMessage:message];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *message = [_messages objectAtIndex:indexPath.row];
    if (indexPath.row%2 ==0 ) {
        return [STMessageReceivedCell cellHeightForText:message];
    }
    else
        return [STMessageSendCell cellHeightForText:message];
    
    return 50.f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _messages.count;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
