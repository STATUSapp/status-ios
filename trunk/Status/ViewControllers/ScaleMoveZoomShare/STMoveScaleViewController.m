//
//  STMoveScaleViewController.m
//  Status
//
//  Created by Andrus Cosmin on 02/09/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STMoveScaleViewController.h"
#import "UIImage+ImageEffects.h"
#import "STSharePhotoViewController.h"

@interface STMoveScaleViewController ()<UIScrollViewDelegate>
{
    UIImage *_currentImg;
    UIImageView *_imageView;
}
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBlurImgView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UINavigationBar *transparentNavBar;

@end

@implementation STMoveScaleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.transparentNavBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.transparentNavBar.shadowImage = [UIImage new];
    self.transparentNavBar.translucent = YES;
    
    _currentImg = [UIImage imageWithData:_imgData];
    _backgroundBlurImgView.image = [_currentImg applyLightEffect];
    _imageView = [[UIImageView alloc] initWithImage:_currentImg];
    [self setUpTheContext];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setUpTheContext{
    [self.scrollView addSubview:_imageView];
    CGSize imageSize = _imageView.image.size;
    NSLog(@"Image Size: %@", NSStringFromCGSize(imageSize));
    self.scrollView.contentSize = imageSize;
    
    CGRect scrollViewFrame = self.view.bounds;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;

    self.scrollView.minimumZoomScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.maximumZoomScale = MAX(imageSize.height/_scrollView.frame.size.height,imageSize.width/_scrollView.frame.size.width);
    self.scrollView.zoomScale = MIN(scaleWidth, scaleHeight);
    
    CGRect contentsFrame = [self aspectFitForRect:CGRectMake(0, 0, imageSize.width, imageSize.height) intoRect:_scrollView.frame];
    _imageView.frame = contentsFrame;
    
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = _imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    _imageView.frame = contentsFrame;
}

#pragma mark UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [self refreshBacgroundBlur];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self refreshBacgroundBlur];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self refreshBacgroundBlur];
}

#pragma mark IBACTIONS
- (IBAction)onUseBtnPressed:(id)sender {
    UIImage *croppedImg = [self croppedImage];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STSharePhotoViewController *viewController = (STSharePhotoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"shareScene"];
    viewController.imgData = UIImageJPEGRepresentation(croppedImg, 1.f);
    viewController.bluredImgData = UIImageJPEGRepresentation(_backgroundBlurImgView.image, 1.f);
    viewController.delegate = _delegate;
    [self.navigationController pushViewController:viewController animated:YES];

}
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Helpers
-(UIImage *)croppedImage{
    CGRect visibleRect;
    float scale = 1.f/_scrollView.zoomScale;
    visibleRect.origin.x = _scrollView.contentOffset.x * scale;
    visibleRect.origin.y = _scrollView.contentOffset.y * scale;
    visibleRect.size.width = _scrollView.bounds.size.width * scale;
    visibleRect.size.height = _scrollView.bounds.size.height * scale;
    
    UIImage *croppedImage = [self cropImage:_imageView.image withRect:visibleRect];
    
    return croppedImage;
}

-(UIImage*)cropImage:(UIImage*)srcImage withRect:(CGRect) rect
{
    CGImageRef cr = CGImageCreateWithImageInRect([srcImage CGImage], rect);
    UIImage* cropped = [[UIImage alloc] initWithCGImage:cr];
    CGImageRelease(cr);
    return cropped;
}

-(CGRect)aspectFitForRect:(CGRect)inRect intoRect:(CGRect)intoRect{
    float widthRatio = intoRect.size.width/inRect.size.width;
    float heightRatio = intoRect.size.height/inRect.size.height;
    CGRect newRect = intoRect;
    
    if (widthRatio == heightRatio) {
        return newRect;
    }
    
    if (widthRatio > heightRatio) {
        newRect.size.width = inRect.size.width * (intoRect.size.height/inRect.size.height);
        newRect.origin.x = (intoRect.size.width-newRect.size.width)/2;
    }
    else
    {
        newRect.size.height = inRect.size.height * (intoRect.size.width/inRect.size.width);
        newRect.origin.y = (intoRect.size.height-newRect.size.height)/2;
    }
	return CGRectIntegral(newRect);
}

- (void)refreshBacgroundBlur {
    if (_scrollView.zoomScale<1.f) {
        NSLog(@"Apply new background blur");
        UIImage *cropppedImage = [self croppedImage];
        [UIView transitionWithView:_backgroundBlurImgView
                          duration:0.2f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            _backgroundBlurImgView.image= [cropppedImage applyLightEffect];
                        } completion:NULL];
    }
}

@end
