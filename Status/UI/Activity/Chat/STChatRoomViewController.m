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
#import "STLoginService.h"
#import "AppDelegate.h"
#import "STCoreDataRequestManager.h"
#import "STDAOEngine.h"
#import "STCoreDataManager.h"
#import "Message+CoreDataClass.h"
#import "STNetworkQueueManager.h"
#import "UIImageView+WebCache.h"
#import "ContainerFeedVC.h"
#import "STTabBarViewController.h"

#import "STGetUserInfoRequest.h"
#import "UITableView+SPXRevealAdditions.h"

#import "NSString+MD5.h"

#import "STListUser.h"
#import "STDataAccessUtils.h"
#import "BadgeService.h"

static CGFloat const TEXT_VIEW_OFFSET = 18.f;
@interface STChatRoomViewController ()<UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate, STChatControllerDelegate, STRechabilityDelegate, UIScrollViewDelegate, SLCoreDataRequestManagerDelegate>
{
    UIAlertController *statusAlert;
    NSInteger loadMoreIndex;
    UIAlertController *actionSheet;
    UIAlertController *successBlockAlert;
    CGPoint lastContentOffset;
    CGRect keyboardBounds;
    BOOL justEnteredRoom;
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

@property (strong, nonatomic) STListUser *user;
@property (strong, nonatomic) STChatController *chatController;
@property (strong, nonatomic) NSString *roomId;
@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) STCoreDataRequestManager *currentManager;

@end

@implementation STChatRoomViewController

+ (STChatRoomViewController *)roomWithUser:(STListUser *)user{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatScene" bundle:nil];
    STChatRoomViewController *viewController = (STChatRoomViewController *)[storyboard instantiateViewControllerWithIdentifier:@"chat_room"];
    viewController.user = user;
    
    return viewController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)loadUserInfo
{
    [_userNameLbl setTitle:_user.userName forState:UIControlStateNormal];
    [_userNameLbl setTitle:_user.userName forState:UIControlStateHighlighted];
    NSString *photoLink = _user.thumbnail;
    __weak STChatRoomViewController *weakSelf = self;
    
    [_userImg sd_setImageWithURL:[NSURL URLWithString:photoLink] placeholderImage:[UIImage imageNamed:[_user genderImage]] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        __strong STChatRoomViewController *strongSelf = weakSelf;
        strongSelf.userImage = image;
        [strongSelf.tableView reloadData];
        [strongSelf.userImg maskImage:strongSelf.userImage];
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _textView.userInteractionEnabled = NO;
    [self.tableView enableRevealableViewForDirection:SPXRevealableViewGestureDirectionLeft];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [self initiateCustomControls];
    if (_user.userName == nil) {//notification, need fetch
        __weak STChatRoomViewController *weakSelf = self;
        [STDataAccessUtils getUserDataForUserId:_user.uuid withCompletion:^(NSArray *objects, NSError *error) {
            __strong STChatRoomViewController *strongSelf = weakSelf;
            if (!error) {
                strongSelf.user = [objects firstObject];
                [strongSelf loadUserInfo];
                
            }
            else{
                //TODO dev_1_2 restrict access?
            }
        }];
    }
    else
        [self loadUserInfo];
    _chatController = [STChatController sharedInstance];
    _chatController.delegate = self;
    _chatController.rechabilityDelegate = self;
}

-(void)viewWillAppear:(BOOL)animated{
    
//    _tableViewWidth.constant = self.view.frame.size.width + 70; // enlarge tableViewWidth in order to hide the time of the message
    
    [super viewWillAppear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:YES];
    if (_chatController.canChat == NO) {
        NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        NSString *userId = _user.uuid;
        STCoreDataRequestManager *messages = [[STDAOEngine sharedManager] fetchRequestManagerForEntity:@"Message"
                                                                                        sortDescritors:@[sd1]
                                                                                             predicate:[NSPredicate predicateWithFormat:@"userId like %@", userId]
                                                                                    sectionNameKeyPath:@"sectionDate"
                                                                                              delegate:nil
                                                                                          andTableView:nil];
        NSString *roomId = [[[messages allObjects] firstObject] valueForKey:@"roomID"];
        NSLog(@"RoomID: %@", roomId);
        if (roomId!=nil) {
            [self chatDidOpenRoom:roomId];
        }

    }
    else
    {
        if (_chatController.authenticated == YES) {
            [_chatController openChatRoomForUserId: _user.uuid];
        }
        else
            [_chatController authenticate];

    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:NO];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    if(_roomId){
        [_chatController leaveRoom:_roomId];
    }
}

- (void)initiateCustomControls {
	    
    _textView.isScrollable = YES;
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    _textView.font = [UIFont fontWithName:@"ProximaNova-Regular" size:16.f];
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
        [self.tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];

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
        self.heightConstraint.constant = height + TEXT_VIEW_OFFSET;
        if ([[self.currentManager allObjects] count]>0) {
            [self.tableView scrollToRowAtIndexPath:[self.currentManager indexPathForObject:[[self.currentManager allObjects] lastObject]] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
	 
}

-(void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView{
    _sendBtn.enabled = [_chatController canChat] && _textView.text.length>0;
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
        [_chatController getRoomMessages:_roomId withOffset:[[_currentManager allObjects] count]];
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
    [_chatController sendMessage:toSendMessage inRoom:_roomId];
    [_textView setText:@""];
}
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onClickUserName:(id)sender {
    
    if (_user.uuid == nil) {
        NSLog(@"Error from server. No user id.");
        return;
    }
    
    ContainerFeedVC *feedCVC = [ContainerFeedVC galleryFeedControllerForUserId:_user.uuid andUserName:nil];

    [self.navigationController pushViewController:feedCVC animated:YES];
}
- (IBAction)onClickDelete:(id)sender {
    actionSheet = [UIAlertController alertControllerWithTitle:nil
                                                      message:nil
                                               preferredStyle:UIAlertControllerStyleActionSheet];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Block User" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Block User" message:@"Are you sure do you want to block this user?" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"Block" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.chatController blockUserWithId:self.user.uuid];
        }]];
        
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    }]];
    
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Delete Conversation" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (self.roomId){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"roomID like %@", self.roomId];
            [[CoreManager coreDataService] deleteAllObjectsFromTable:@"Message" withPredicate:predicate];
            [[CoreManager coreDataService] save];
        }
    }]];
    
    [self.navigationController presentViewController:actionSheet animated:YES completion:nil];
}
- (IBAction)onTapBackgound:(id)sender {
    [_textView resignFirstResponder];
}


#pragma mark - STChatControllerDelegate

-(void)chatDidClose{
    NSLog(@"Chat did close");
    _sendBtn.enabled = NO;
//    [self showStatusAlertWithMessage:@"Your chat connection appears to be offline. You can wait or you can Go Back"];
}
-(void)chatDidOpenRoom:(NSString *)roomId{
    _roomId = roomId;
    _textView.userInteractionEnabled = YES;
    justEnteredRoom  =YES;

    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
    _currentManager = [[STDAOEngine sharedManager] fetchRequestManagerForEntity:@"Message" sortDescritors:@[sd1] predicate:[NSPredicate predicateWithFormat:@"roomID like %@", _roomId] sectionNameKeyPath:@"sectionDate" delegate:self andTableView:nil];

    NSNumber *seen = [[[_currentManager allObjects] valueForKey:@"seen"] valueForKeyPath: @"@sum.self"];
//    NSInteger unseen = [[_currentManager allObjects] count] - seen.integerValue;
    [[CoreManager badgeService] adjustUnreadMessages: (-1) * seen.integerValue];
    [_tableView reloadData];
    
    if ([[_currentManager allObjects] count]>0) {
        [_tableView scrollToRowAtIndexPath:[_currentManager indexPathForObject:[[_currentManager allObjects] lastObject]] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    else
    {
        if (justEnteredRoom == YES) {
            justEnteredRoom = NO;
            [self onLoadMore:nil];
        }
    }
    [_chatController syncRoomMessages:_roomId withMessagesIds:[_currentManager.allObjects valueForKey:@"uuid"]];

}
-(void)chatDidAuthenticate{
    [self hideStatusAlert];
    [_chatController openChatRoomForUserId: _user.uuid];
}

-(void)userWasBlocked{
    [self showStatusAlertWithMessage:@"This chat room was blocked."];
}

-(void)userBlockSuccess{
    successBlockAlert = [UIAlertController alertControllerWithTitle:@"Block User" message:@"This user was blocked. You will no longer receive messages from him." preferredStyle:UIAlertControllerStyleAlert];
    [successBlockAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self.navigationController presentViewController:successBlockAlert animated:YES completion:nil];
}

#pragma mark - STRechabilityDelegate

-(void)networkOff{
    [self showStatusAlertWithMessage:@"Your internet connection appears to be offline. You can wait for better connection or you can Go Back"];
}

-(void)networkOn{
    [self hideStatusAlert];
//    [chatController reconnect];
}

#pragma mark Helpers

-(void)showStatusAlertWithMessage:(NSString *)message{
    if (statusAlert==nil && [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        statusAlert = [UIAlertController alertControllerWithTitle:@"Chat" message:message preferredStyle:UIAlertControllerStyleAlert];
        [statusAlert addAction:[UIAlertAction actionWithTitle:@"GO BACK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [self.navigationController presentViewController:statusAlert animated:YES completion:nil];
    }
}

-(void)hideStatusAlert{
    [statusAlert dismissViewControllerAnimated:YES completion:nil];
    statusAlert = nil;
    
}

#pragma mark - UITableViewDelegate
-(NSString *)getIdentifierForIndexPath:(NSIndexPath *)indexPath{
    Message *message = [_currentManager objectAtIndexPath:indexPath];
    BOOL received = ![message.userId isEqualToString:_chatController.currentUserId];
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
    Message *message = [_currentManager objectAtIndexPath:indexPath];
    BOOL received = ![message.userId isEqualToString:_chatController.currentUserId];
    if (received == YES) {
        [(STMessageReceivedCell *)cell configureCellWithMessage:message andUserImage:_userImage];
    }
    else
        [(STMessageSendCell *)cell configureCellWithMessage:message];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    float height = 50.f;

    Message *message = [_currentManager objectAtIndexPath:indexPath];
    BOOL received = ![message.userId isEqualToString:_chatController.currentUserId];
    if (received == YES) {
        height = [STMessageReceivedCell cellHeightForMessage:message];
    }
    else
        height = [STMessageSendCell cellHeightForMessage:message];
    return height;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [_currentManager numberOfObjectsInSection:section];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_textView resignFirstResponder];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_currentManager numberOfSections];
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
//    Message *msg = [_currentManager objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
//    return msg.sectionDate;
//}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    Message *msg = [_currentManager objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];

    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    CGRect rect = CGRectMake(0, 0, mainWindow.frame.size.width, 20);

    UIView *sectionView = [[UIView alloc] initWithFrame:rect];
    UILabel *lb = [[UILabel alloc] initWithFrame:rect];
    lb.text = msg.sectionDate;
    lb.font = [UIFont fontWithName:@"ProximaNova-Regular" size:14.f];
    [lb setBackgroundColor:[UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:0.2]];
    lb.textAlignment = NSTextAlignmentCenter;
    [sectionView addSubview:lb];
    
    return sectionView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20.f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tableView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [actionSheet dismissViewControllerAnimated:YES completion:nil];
    [self hideStatusAlert];
    [successBlockAlert dismissViewControllerAnimated:YES completion:nil];
    _chatController.delegate = nil;
    _chatController.rechabilityDelegate = nil;
    if(_roomId){
        [_chatController leaveRoom:_roomId];
        [[CoreManager coreDataService] save];
    }
}

-(void)controllerContentChanged:(NSArray *)objects{
    [self.tableView reloadData];
    if (_chatController.loadMore==NO) {
        [_tableView scrollToRowAtIndexPath:[_currentManager indexPathForObject:[[_currentManager allObjects] lastObject]] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}

@end
