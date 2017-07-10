//
//  STTagManualProductCell.m
//  Status
//
//  Created by Cosmin Andrus on 07/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagManualProductCell.h"
#import "STShopProduct.h"

const CGFloat kDefaultImageViewWidth = 129.f;

@interface STTagManualProductCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LoadedImageWidthConstr;
@property (weak, nonatomic) IBOutlet UIImageView *loadedImageView;
@property (weak, nonatomic) IBOutlet UIButton *deleteLoadedImageButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notLoadedWidthConstr;
@property (weak, nonatomic) IBOutlet UIButton *uploadProductButton;
@property (weak, nonatomic) IBOutlet UITextView *linkTextView;
@property (weak, nonatomic) IBOutlet UIButton *deleteProductButton;
@property (weak, nonatomic) IBOutlet UIView *notLoadedView;
@property (weak, nonatomic) IBOutlet UILabel *textViewPlaceholder;

@end

@implementation STTagManualProductCell

-(void)configureCellWithproduct:(STShopProduct *)product
                       andIndex:(NSInteger)index{
    _deleteProductButton.tag = index;
    _uploadProductButton.tag = index;
    _deleteProductButton.tag = index;
    _linkTextView.tag = index;
    
    [self setTextViewWithString:product.productUrl];
    
    if (product.localImage) {
        _notLoadedWidthConstr.constant = 0.f;
        _notLoadedView.hidden = YES;
        _LoadedImageWidthConstr.constant = kDefaultImageViewWidth;
        _loadedImageView.image = product.localImage;
    }
    else
    {
        _notLoadedView.hidden = NO;
        _notLoadedWidthConstr.constant = kDefaultImageViewWidth;
        _LoadedImageWidthConstr.constant = 0.f;
        _loadedImageView.image = nil;
    }
}

-(void)setTextViewWithString:(NSString *)text{
    if ([_linkTextView isFirstResponder]) {
        _textViewPlaceholder.hidden = YES;
    }
    else
    {
        _linkTextView.text = text;
        if (text && text.length > 0) {
            _textViewPlaceholder.hidden = YES;
        }
        else
            _textViewPlaceholder.hidden = NO;
    }

}

+(CGFloat)cellHeight{
    return 181.f;
}
@end
