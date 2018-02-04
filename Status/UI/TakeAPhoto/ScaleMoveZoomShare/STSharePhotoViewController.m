//
//  STSharePhotoViewController.m
//  Status
//
//  Created by Andrus Cosmin on 23/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STSharePhotoViewController.h"
#import "STNetworkQueueManager.h"
#import <MessageUI/MessageUI.h>
#import "STFacebookLoginController.h"
#import "STConstants.h"
#import "STFacebookHelper.h"

#import "STUploadPostRequest.h"
#import "UIImage+Resize.h"

#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "STDataAccessUtils.h"
#import "STPost.h"
#import "STLocalNotificationService.h"
#import "STTabBarViewController.h"

#import "STShopProduct.h"
#import "STTagProductsContainer.h"

#import "STTagProductsManager.h"
#import "STShopProductCell.h"
#import "STNavigationService.h"
#import "STImageCacheController.h"

static NSInteger const  kMaxCaptionLenght = 250;
static CGFloat const kTagProductsViewDefaultHeight = 44.f;

typedef NS_ENUM(NSUInteger, TagProductSection) {
    TagProductSectionProducts,
    TagProductSectionAddProduct,
    TagProductSectionCount,
};

@interface STSharePhotoViewController ()<MFMailComposeViewControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, STMoveAndScaleProtocol>{
}
@property (weak, nonatomic) IBOutlet UIImageView *sharedImageView;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UITextView *captiontextView;
@property (weak, nonatomic) IBOutlet UICollectionView *productsCollection;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagProductsViewHeightConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tagProductsCollectionHeightConstr;

@property (weak, nonatomic) IBOutlet UILabel *writeCaptionPlaceholder;
@property (weak, nonatomic) IBOutlet UIView *shareView;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@property (assign, nonatomic) BOOL shouldPostToFacebook;

@property (assign, nonatomic)BOOL donePostingToFacebook;

@property (strong, nonatomic)NSError *fbError;

@property (strong, nonatomic) UIImage *changedImage;


//initialized with the post.shopProducts if exists and then new items can be added/removed
@property (nonatomic, strong) NSArray <STShopProduct *> *shopProducts;

@end

@implementation STSharePhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)configureImageViewWithImageData:(NSData *)imageData{
    UIImage * sharedImage = [UIImage imageWithData:imageData];
    CGFloat resizeRatio = sharedImage.size.width / self.view.frame.size.width;
    CGSize newSize = CGSizeMake(sharedImage.size.width / resizeRatio, sharedImage.size.height / resizeRatio);
    
    sharedImage = [sharedImage resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
    _sharedImageView.image = sharedImage;
    //    _sharedImageView.layer.contentsRect = CGRectMake(0, 0, 1, 0.25);

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.hidesBarsOnSwipe = NO;
    self.navigationController.navigationBarHidden = NO;
    [self configureImageViewWithImageData:_imgData];
    [[STTagProductsManager sharedInstance] startDownload];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tagProductsNotification:) name:kTagProductNotification object:nil];

    if (_post) {
        _captiontextView.text = _post.caption;
        for (STShopProduct *sp in _post.shopProducts) {
            [[STTagProductsManager sharedInstance] processProduct:sp];
        }
    }
    else{
        _captiontextView.text = @"";
        _shopProducts = @[];
    }
    _captiontextView.delegate = self;
    _writeCaptionPlaceholder.hidden = _captiontextView.text.length>0;
    _shareView.hidden = (_controllerType == STShareControllerEditInfo) ;
    _captiontextView.userInteractionEnabled = YES;
    
    [self updateProductsCollection];
}

-(void)updateProductsCollection{
    if (_shopProducts.count > 0) {
        _tagProductsViewHeightConstr.constant = 0;
        _tagProductsCollectionHeightConstr.constant = [STShopProductCell cellSize].height + 6;
;
    }
    else{
        _tagProductsViewHeightConstr.constant = kTagProductsViewDefaultHeight;
        _tagProductsCollectionHeightConstr.constant = 0.f;
    }
    [self.productsCollection reloadData];
    [self.productsCollection.collectionViewLayout invalidateLayout];
    [self.view layoutIfNeeded];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[STTagProductsManager sharedInstance] resetManager];
}

-(void)tagProductsNotification:(NSNotification *)sender{
    NSDictionary *userInfo = sender.userInfo;
    
    STTagManagerEvent event = [userInfo[kTagProductUserInfoEventKey] integerValue];
    
    switch (event) {
        case STTagManagerEventSelectedProducts:
        {
            _shopProducts = [NSArray arrayWithArray:[STTagProductsManager sharedInstance].selectedProducts];
            [self updateProductsCollection];
        }
            break;
        default:
            break;
    }
}

#pragma mark IBACTIONS
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onClickTagProducts:(id)sender {
    [STTagProductsManager sharedInstance].rootViewController = self;
    STTagProductsContainer *vc = [STTagProductsContainer newController];
    
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)onClickEmail:(id)sender {
    MFMailComposeViewController *emailShareController = [[MFMailComposeViewController alloc] init];
    [emailShareController setTitle:@"STATUS"];
    [emailShareController setSubject:@"Share Photo on STATUS"];
    [emailShareController setDelegate:self];
    [emailShareController setMailComposeDelegate:self];
    
    NSString *fileName = @"image_status";
    fileName = [fileName stringByAppendingPathExtension:@"jpeg"];
    [emailShareController addAttachmentData:_imgData mimeType:@"image/jpeg" fileName:fileName];

    [self presentViewController:emailShareController animated:YES completion:nil];
}
- (IBAction)onClickFacebook:(id)sender {

    UIButton *btn = (UIButton *) sender;
    btn.selected = !btn.selected;
    _shouldPostToFacebook = btn.selected;
}

- (IBAction)onDeleteProductPressed:(id)sender {
    NSInteger buttonTag = ((UIButton *)sender).tag;
    STShopProduct *product = [_shopProducts objectAtIndex:buttonTag];
    [[STTagProductsManager sharedInstance] processProduct:product];
}

- (IBAction)onClickShare:(id)sender {
    _shareButton.enabled = FALSE;
    __weak STSharePhotoViewController *weakSelf = self;
    if (_controllerType == STShareControllerAddPost ||
        _controllerType == STShareControllerEditInfo) {
        
        NSData *currentImageData = _imgData;
        if (_changedImage) {
            currentImageData = UIImageJPEGRepresentation(_changedImage, 1.f);
        }
        [STDataAccessUtils editPpostWithId:_post.uuid
                          withNewImageData:currentImageData
                            withNewCaption:_captiontextView.text
                          withShopProducts:_shopProducts
                            withCompletion:^(NSArray *objects, NSError *error) {
                                weakSelf.shareButton.enabled = TRUE;
                                if (!error) {
                                    STPost *post = [objects firstObject];
                                    if (weakSelf.shouldPostToFacebook==YES ) {
                                        [weakSelf startPostingWithPostId:post.uuid andImageUrl:post.mainImageUrl deepLink:post.shareShortUrl];
                                    }
                                    else
                                    {
                                        [weakSelf showMessagesAndCallDelegatesForPostId:post.uuid];
                                    }

                                }
                            }];
    }
}
- (IBAction)onTapPicture:(id)sender {
    UIImage *image = [UIImage imageWithData:_imgData];
    if (_changedImage) {
        image = _changedImage;
    }
    STMoveScaleViewController *vc = [STMoveScaleViewController newControllerForImage:image shouldCompress:NO andPost:_post];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];


}

#pragma mark STMoveAndScaleProtocol

-(void)postImageWasChanged:(UIImage *)changedImage{
    _changedImage = changedImage;
    [self configureImageViewWithImageData:UIImageJPEGRepresentation(_changedImage, 1.f)];
}

#pragma mark - MFMailControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    if (result == MFMailComposeResultSent) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Email sent" message:@"Your message was shared." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - Helper

- (void)startPostingWithPostId:(NSString *)postId
                   andImageUrl:(NSString *)imageUrl
                      deepLink:(NSString *)deepLink{
    if (_shouldPostToFacebook) {
        [self postCurrentPhotoToFacebookWithPostId:postId
                                       andImageUrl:imageUrl
                                          deepLink:deepLink];
    }
}
- (void)postCurrentPhotoToFacebookWithPostId:(NSString *)postId
                                 andImageUrl:(NSString *)imageUrl
                                    deepLink:(NSString *)deepLink{
    __weak STSharePhotoViewController *weakSelf = self;
    [[CoreManager facebookService] shareImageWithImageUrl:imageUrl
                                              description:_captiontextView.text
                                                 deepLink:deepLink
                                            andCompletion:^(id result, NSError *error) {
        weakSelf.donePostingToFacebook = YES;
        if (error) {
            weakSelf.fbError = error;
        }
        [weakSelf showMessagesAndCallDelegatesForPostId:postId];
    }];
}

- (void)showMessagesAndCallDelegatesForPostId:(NSString *)postId {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *alertTitle = nil;
        NSString *alertMessage = nil;
        if (_fbError!=nil){
            alertTitle = @"Warning";
            alertMessage = @"Your photo was posted on STATUS, but not shared on Facebook. You can try sharing it on Facebook from your profile.";
        }else{
            alertTitle = @"Success";
            alertMessage = @"Your photo was posted on STATUS";
        }
        if (alertMessage!=nil) {
            __weak STSharePhotoViewController *weakSelf = self;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                [[CoreManager navigationService] dismissChoosePhotoVC];

            }]];
            [self.navigationController presentViewController:alert animated:YES completion:nil];
        }
        if ([_post.uuid isEqualToString:postId]) {
            [[CoreManager localNotificationService] postNotificationName:STPostImageWasEdited object:nil userInfo:@{kPostIdKey:postId}];
        }
        else
            [[CoreManager localNotificationService] postNotificationName:STPostNewImageUploaded object:nil userInfo:@{kPostIdKey:postId}];
    });

}

-(void)showErrorAlert{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Something went wrong. Please try again later." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self.navigationController presentViewController:alert animated:YES completion:nil];
}


#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView{
    _writeCaptionPlaceholder.hidden = YES;
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    _writeCaptionPlaceholder.hidden = textView.text.length > 0;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    NSInteger textLenght = textView.text.length;
    if (text.length > 0) {
        textLenght = textLenght + text.length;
    }
    else
        textLenght--;//delete pressed
    if (textLenght>kMaxCaptionLenght) {
        return NO;
    }
    return YES;
}

#pragma mark - UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return TagProductSectionCount;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == TagProductSectionProducts) {
        return [_shopProducts count];
    }
    else if (section == TagProductSectionAddProduct){
        return 1;
    }
    
    return 0;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size = [STShopProductCell cellSize];
    NSLog(@"Product size: %@", NSStringFromCGSize(size));
    return size;

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == TagProductSectionAddProduct) {
        [self onClickTagProducts:nil];
    }
}

-(NSString *)identifierForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == TagProductSectionProducts) {
        return @"STShopProductCell";
    }
    else if (indexPath.section == TagProductSectionAddProduct){
        return @"STAddProductCell";
    }
    
    return @"";
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self identifierForIndexPath:indexPath] forIndexPath:indexPath];
    if ([cell isKindOfClass:[STShopProductCell class]]) {
        STShopProduct *product = [_shopProducts objectAtIndex:indexPath.row];
        [(STShopProductCell *)cell configureWithShopProduct:product];
        ((STShopProductCell *)cell).deleteButton.tag = indexPath.row;
    }
    
    return cell;
}

/*
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    NSString *identifier = nil;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        identifier = @"STProductsHeader";
    }
    else
        identifier = @"STProductsFooter";
    
    return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:identifier forIndexPath:indexPath];
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    CGSize cellSize = [STShopProductCell cellSize];
    cellSize.width = 16.f;
    
    return cellSize;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize cellSize = [STShopProductCell cellSize];
    cellSize.width = 16.f;
    
    return cellSize;
    
}

 */
@end
