//
//  STSharePhotoTVC.m
//  Status
//
//  Created by Cosmin Andrus on 13/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STSharePhotoTVC.h"
#import "UIImage+Resize.h"
#import "STPost.h"
#import "STTagProductsManager.h"
#import "STTagProductsContainer.h"
#import "STMoveScaleViewController.h"
#import "STDetailedShopProductCell.h"
#import "STTagSuggestions.h"

static NSInteger const  kMaxCaptionLenght = 250;

typedef NS_ENUM(NSUInteger, TagProductSection) {
    TagProductSectionProducts = 0,
    TagProductSectionAddProduct,
    TagProductSectionCount,
};

typedef NS_ENUM(NSUInteger, STSharePhotoSection) {
    STSharePhotoSectionImageAndCaption = 0,
    STSharePhotoSectionSuggestedProductsHeader,
    STSharePhotoSectionSuggestedProducts,
    STSharePhotoSectionTagProductsHeader,
    STSharePhotoSectionTaggedProducts,
    STSharePhotoSectionShareFacebook
};
@interface STSharePhotoTVC ()<UITextViewDelegate, STMoveAndScaleProtocol, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *sharedImageView;
@property (weak, nonatomic) IBOutlet UITextView *captiontextView;
@property (weak, nonatomic) IBOutlet UIButton *tagProductsButton;
@property (weak, nonatomic) IBOutlet UIView *tagProductsSeparator;
@property (weak, nonatomic) IBOutlet UICollectionView *productsCollection;
@property (weak, nonatomic) IBOutlet UILabel *writeCaptionPlaceholder;
@property (weak, nonatomic) IBOutlet UICollectionView *suggestedProductsCollection;

//initialized with the post.shopProducts if exists and then new items can be added/removed
@property (nonatomic, strong) NSArray <STShopProduct *> *shopProducts;
@property (nonatomic, strong) NSMutableArray <STShopProduct *> *suggesteProducts;

@property (strong, nonatomic) UIImage *changedImage;
@property (assign, nonatomic) BOOL shouldPostToFacebook;
@property (assign, nonatomic) BOOL suggestionsLoaded;

@end

@implementation STSharePhotoTVC

- (void)viewDidLoad {
    [super viewDidLoad];
//    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
//        self.tableView.scrollEnabled = NO;
//    }
//    else {
//        self.tableView.scrollEnabled = YES;
//    }

    [self configureImageViewWithImageData:_imgData];

    [[STTagProductsManager sharedInstance] startDownload];
    
    _productsCollection.delegate = self;
    _productsCollection.dataSource = self;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tagProductsNotification:) name:kTagProductNotification object:nil];

    if (_post) {
        _captiontextView.text = _post.caption;
        for (STShopProduct *sp in _post.shopProducts) {
            [[STTagProductsManager sharedInstance] processProduct:sp];
        }
        //TODO: remove this mock
        _suggestionsLoaded = NO;
        _suggesteProducts = [NSMutableArray array];
    }
    else{
        _captiontextView.text = @"";
        _shopProducts = @[];
        //TODO: get suggested products data from server
        _suggestionsLoaded = NO;
        _suggesteProducts = [NSMutableArray array];
    }
    
    _captiontextView.delegate = self;
    _writeCaptionPlaceholder.hidden = _captiontextView.text.length>0;

    [self updateProductsCollection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    [[STTagProductsManager sharedInstance] resetManager];
}

#pragma mark - IBActions
- (IBAction)onClickTagProducts:(id)sender {
    [STTagProductsManager sharedInstance].rootViewController = self.parentViewController;
    STTagProductsContainer *vc = [STTagProductsContainer newController];
    
    [self.navigationController pushViewController:vc animated:YES];
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
- (IBAction)onDeleteSuggestedProductPressed:(id)sender {
    NSInteger buttonTag = ((UIButton *)sender).tag;
    STShopProduct *product = [_suggesteProducts objectAtIndex:buttonTag];
    [_suggesteProducts removeObject:product];
    [self.tableView reloadData];
    [_suggestedProductsCollection reloadData];
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
- (IBAction)onTapViewSimilarButton:(id)sender {
    NSInteger buttonTag = ((UIButton *)sender).tag;
    STShopProduct *currentProduct = [_shopProducts objectAtIndex:buttonTag];
    STTagSuggestions *vc = [STTagSuggestions similarProductsScreenWithProducts:[STTagProductsManager sharedInstance].usedProducts andSelectedProduct:nil withCompletion:^(STShopProduct *selectedProduct) {
        [[STTagProductsManager sharedInstance] processProduct:currentProduct];
        [[STTagProductsManager sharedInstance] processProduct:selectedProduct];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)onTapViewSimilarSuggestedProductButton:(id)sender {
    NSInteger buttonTag = ((UIButton *)sender).tag;
    STShopProduct *currentProduct = [_suggesteProducts objectAtIndex:buttonTag];
    STTagSuggestions *vc = [STTagSuggestions similarProductsScreenWithProducts:[STTagProductsManager sharedInstance].usedProducts andSelectedProduct:currentProduct withCompletion:^(STShopProduct *selectedProduct) {
        [_suggesteProducts replaceObjectAtIndex:buttonTag withObject:selectedProduct];
        [self.suggestedProductsCollection reloadData];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark STMoveAndScaleProtocol

-(void)postImageWasChanged:(UIImage *)changedImage{
    _changedImage = changedImage;
    [self configureImageViewWithImageData:UIImageJPEGRepresentation(_changedImage, 1.f)];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [super numberOfSectionsInTableView:tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numRows = [super tableView:tableView numberOfRowsInSection:section];

    switch (section) {
        case STSharePhotoSectionSuggestedProductsHeader:
        case STSharePhotoSectionSuggestedProducts:
        {
            if (_post != nil) {
                numRows = 0;
            }else{
                if (_suggestionsLoaded && _suggesteProducts.count == 0) {
                    numRows = 0;
                }
            }
        }
            break;
        case STSharePhotoSectionTaggedProducts:
            numRows = (_shopProducts.count > 0) ? 1 : 0;
            break;
        case STSharePhotoSectionShareFacebook:
            numRows = (_controllerType == STShareControllerEditInfo) ? 0 : 2;
            break;
    }
    return numRows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    if (indexPath.section == STSharePhotoSectionTaggedProducts ||
        indexPath.section == STSharePhotoSectionSuggestedProducts) {
        height = [STDetailedShopProductCell cellSize].height + 6;
    }
    return height;
}
#pragma mark - Helpers
- (void)configureImageViewWithImageData:(NSData *)imageData{
    UIImage * sharedImage = [UIImage imageWithData:imageData];
    CGFloat resizeRatio = sharedImage.size.width / self.view.frame.size.width;
    CGSize newSize = CGSizeMake(sharedImage.size.width / resizeRatio, sharedImage.size.height / resizeRatio);
    
    sharedImage = [sharedImage resizedImage:newSize interpolationQuality:kCGInterpolationDefault];
    _sharedImageView.image = sharedImage;
//        _sharedImageView.layer.contentsRect = CGRectMake(0, 0, 1, 0.25);
    
}

-(void)updateProductsCollection{
    NSString *tagProductsString = NSLocalizedString(@"Tag Products", nil);
    if (_shopProducts.count > 0) {
        tagProductsString = NSLocalizedString(@"Tagged Products", nil);
    }
    [self.tagProductsButton setTitle:tagProductsString forState:UIControlStateNormal];
    [self.tagProductsButton setTitle:tagProductsString forState:UIControlStateSelected];
    [self.tagProductsButton setTitle:tagProductsString forState:UIControlStateHighlighted];
    self.tagProductsSeparator.hidden = (_shopProducts.count > 0);
    
    [self.tableView reloadData];
    [self.productsCollection reloadData];
    [self.productsCollection.collectionViewLayout invalidateLayout];
    [self.suggestedProductsCollection reloadData];
    [self.suggestedProductsCollection.collectionViewLayout invalidateLayout];
    [self.view layoutIfNeeded];
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
        case STTagManagerEventUsedProducts:
        {
            //TODO: remove this mock
            _suggestionsLoaded = YES;
            _suggesteProducts = [NSMutableArray arrayWithArray:[STTagProductsManager sharedInstance].usedProducts];
            [self updateProductsCollection];
        }
            break;
        default:
            break;
    }
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
    if (collectionView == _productsCollection) {
        if (section == TagProductSectionProducts) {
            return [_shopProducts count];
        }
        else if (section == TagProductSectionAddProduct){
            return 1;
        }
    }else if (collectionView == _suggestedProductsCollection){
        if (section == TagProductSectionProducts) {
            return [_suggesteProducts count];
        }
        else if (section == TagProductSectionAddProduct){
            return 0;
        }
    }
    
    return 0;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGSize size = [STDetailedShopProductCell cellSize];
    return size;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == TagProductSectionAddProduct) {
        [self onClickTagProducts:nil];
    }
}

-(NSString *)identifierForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == TagProductSectionProducts) {
        return @"STDetailedShopProductCell";
    }
    else if (indexPath.section == TagProductSectionAddProduct){
        return @"STAddProductCell";
    }
    
    return @"";
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[self identifierForIndexPath:indexPath] forIndexPath:indexPath];
    if ([cell isKindOfClass:[STDetailedShopProductCell class]]) {
        if (collectionView == _productsCollection) {
            STShopProduct *product = [_shopProducts objectAtIndex:indexPath.row];
            [(STDetailedShopProductCell *)cell configureWithShopProduct:product];
        }else if (collectionView == _suggestedProductsCollection){
            STShopProduct *product = [_suggesteProducts objectAtIndex:indexPath.row];
            [(STDetailedShopProductCell *)cell configureWithShopProduct:product];
        }
        [((STDetailedShopProductCell *)cell) setTag:indexPath.row];
    }
    
    return cell;
}


#pragma mark - Public

-(NSData *)postImageData{
    NSData *currentImageData = _imgData;
    if (_changedImage) {
        currentImageData = UIImageJPEGRepresentation(_changedImage, 1.f);
    }
    return currentImageData;
}
-(NSString *)postCaptionString{
    return _captiontextView.text;
}
-(NSArray<STShopProduct *> *)postShopProducts{
    return _shopProducts;
}
-(BOOL)postShouldBePostedOnFacebook{
    return _shouldPostToFacebook;
}
@end
