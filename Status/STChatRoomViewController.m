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

@interface STChatRoomViewController ()<UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate>
{
    NSMutableArray *_messages;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet HPGrowingTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomTextViewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;


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
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];    [self initiateCustomControls];
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

-(void)resignTextView
{
	[_textView resignFirstResponder];
}

//Code from Brett Schumann
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
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    _containerView.frame = containerFrame;
    [UIView commitAnimations];
    _bottomTextViewConstraint.constant = keyboardBounds.size.height;
    

}

-(void) keyboardWillHide:(NSNotification *)note{
	// get a rect for the textView frame
	CGRect containerFrame = _containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;     
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[note.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue]];
    [UIView setAnimationBeginsFromCurrentState:YES];
    _containerView.frame = containerFrame;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
    _bottomTextViewConstraint.constant = 0;
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    CGRect r = _containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    [UIView animateWithDuration:0.25 animations:^{
        _heightConstraint.constant = height;
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
- (IBAction)onSendButtonPressed:(id)sender {
    [_messages addObject:_textView.text];
    [_textView setText:@""];
    [_textView resignFirstResponder];
    
    [_tableView reloadData];
    [_tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:_messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        [(STMessageReceivedCell *)cell configureCellWithMessage:message];
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

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
