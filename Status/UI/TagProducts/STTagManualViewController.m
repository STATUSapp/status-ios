//
//  STTagManualViewController.m
//  Status
//
//  Created by Cosmin Andrus on 07/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagManualViewController.h"
#import "STShopProduct.h"

#import "STTagManualProductCell.h"
#import "STTagAddProductCell.h"

#import "STTagProductsManager.h"
#import "STImageResizeService.h"

typedef NS_ENUM(NSUInteger, STTagManualSection) {
    STTagManualSectionProducts = 0,
    STTagManualSectionAddProduct,
    STTagManualSectionCount,
};

@interface STTagManualViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>
{
    UITextView *currentTextView;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray<STShopProduct *> *products;

@property (nonatomic, assign) NSInteger addPhotoIndex;
@end

@implementation STTagManualViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _addPhotoIndex = NSNotFound;
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateProducts:(NSArray<STShopProduct *> *)products{
    _products = [NSMutableArray arrayWithArray:products];
    if (_products.count == 0) {
        [self addProductPressed:nil];
    }
    [_collectionView reloadData];
}

#pragma mark - UICollectionView delegates

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return STTagManualSectionCount;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == STTagManualSectionProducts) {
        return [_products count];
    }
    else if (section == STTagManualSectionAddProduct){
        return 1;
    }
    
    return 0;
}

-(NSString *)identifierForIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == STTagManualSectionProducts) {
        return @"STTagManualProductCell";
    }
    else if (indexPath.section == STTagManualSectionAddProduct){
        return @"STTagAddProductCell";
    }
    
    return nil;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identifier = [self identifierForIndexPath:indexPath];
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if ([cell isKindOfClass:[STTagManualProductCell class]]) {
        STShopProduct *product = _products[indexPath.item];
        [(STTagManualProductCell *)cell configureCellWithproduct:product
                                                        andIndex:indexPath.item];
    }
    else if ([cell isKindOfClass:[STTagAddProductCell class]]){
        //nothing to configure
    }
    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0.f;
    if (indexPath.section == STTagManualSectionProducts) {
        height = [STTagManualProductCell cellHeight];
    }
    else if (indexPath.section == STTagManualSectionAddProduct){
        height = [STTagAddProductCell cellHeight];
    }
    
    if (height > 0.f) {
        return CGSizeMake(collectionView.frame.size.width, height);
    }
    
    return CGSizeZero;
}
#pragma mark - IBActions

- (IBAction)deleteImagePressed:(id)sender {
    NSInteger index = ((UIButton *)sender).tag;
    STShopProduct *product = _products[index];
    product.localImage = nil;
    
    [_collectionView reloadData];
}

- (IBAction)uploadImagePressed:(id)sender {
    
    _addPhotoIndex = ((UIButton *)sender).tag;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Photos"
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"Take a photo"
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                      [self presentPhotoPickerForType:UIImagePickerControllerSourceTypeCamera];
                                                  }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Open Camera Roll"
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                                  [self presentPhotoPickerForType:UIImagePickerControllerSourceTypePhotoLibrary|UIImagePickerControllerSourceTypeSavedPhotosAlbum];
                                              }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
    [self.parentViewController presentViewController:alert animated:YES completion:nil];


}

- (IBAction)deleteProductPressed:(id)sender {
    NSInteger index = ((UIButton *)sender).tag;
    [_products removeObjectAtIndex:index];
    
    [_collectionView reloadData];

}
- (IBAction)addProductPressed:(id)sender {
    
    STShopProduct *newProduct = [STShopProduct new];
    [_products addObject:newProduct];
    
    [_collectionView reloadData];
    
}
- (IBAction)onDonePressed:(id)sender {
    [currentTextView resignFirstResponder];
    NSString *errorString = nil;
    for (STShopProduct *sp in _products) {
        if (!sp.localImage) {
            errorString = NSLocalizedString(@"Added product should have an image.", nil);
            break;
        }
        if (sp.productUrl) {
            if ([sp.productUrl rangeOfString:@"http"].location == NSNotFound) {
                sp.productUrl = [NSString stringWithFormat:@"http://%@", sp.productUrl];
            }
        }
        if (!sp.productUrl || ![self validateUrlString:sp.productUrl]) {
            errorString = NSLocalizedString(@"Added product should have a valid url.", nil);
            break;
        }
    }
    
    if (errorString) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:errorString
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
        
        [self.parentViewController presentViewController:alert
                                                animated:YES
                                              completion:nil];
    }
    else
    {
        for (STShopProduct *sp in _products) {
            [[STTagProductsManager sharedInstance] processProduct:sp];
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(manualProductsAdded)]) {
            [_delegate manualProductsAdded];
        }
    }
}

-(void)presentPhotoPickerForType:(UIImagePickerControllerSourceType)type{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = type;
    [imagePicker setAllowsEditing:YES];
    [self.parentViewController presentViewController:imagePicker animated:YES completion:nil];

}

#pragma mark UIImagePicker delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self.addPhotoIndex!=NSNotFound) {
            UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
            UIImage *resizedImage = [[CoreManager imageResizeService] resizeImage:img forUseType:STImageUseTypeUploadProduct];
            STShopProduct *product = self.products[self.addPhotoIndex];
            product.localImage = resizedImage;
            [self.collectionView reloadData];
        }
    }];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
    _addPhotoIndex = NSNotFound;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)textViewDidBeginEditing:(UITextView *)textView{
    currentTextView = textView;
    NSIndexPath *currentCellIndexPath = [NSIndexPath indexPathForItem:textView.tag inSection:STTagManualSectionProducts];
    STTagManualProductCell *currentCell = (STTagManualProductCell *)[_collectionView cellForItemAtIndexPath:currentCellIndexPath];
    STShopProduct *product = _products[currentCellIndexPath.item];
    [currentCell setTextViewWithString:product.productUrl];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    NSIndexPath *currentCellIndexPath = [NSIndexPath indexPathForItem:textView.tag inSection:STTagManualSectionProducts];
    STTagManualProductCell *currentCell = (STTagManualProductCell *)[_collectionView cellForItemAtIndexPath:currentCellIndexPath];
    [currentCell setTextViewWithString:textView.text];
    
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    NSIndexPath *currentCellIndexPath = [NSIndexPath indexPathForItem:textView.tag inSection:STTagManualSectionProducts];
    STTagManualProductCell *currentCell = (STTagManualProductCell *)[_collectionView cellForItemAtIndexPath:currentCellIndexPath];
    STShopProduct *product = _products[currentCellIndexPath.item];
    product.productUrl = textView.text;
    [currentCell setTextViewWithString:product.productUrl];
    currentTextView = nil;
}

-(void)showInvalidUrlAlertForTextView:(UITextView *)textView{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Please enter a valid web address.", nil) preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Ok", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [textView becomeFirstResponder];
    }]];
    [self.parentViewController presentViewController:alert
                                            animated:YES
                                          completion:nil];
}

-(BOOL)validateUrlString:(NSString *)urlString{
    NSString *urlText = urlString;
    NSURL *candidateURL = [NSURL URLWithString:urlText];
    if (candidateURL && candidateURL.scheme && candidateURL.host) {
        return YES;
    }
    return NO;

}
@end
