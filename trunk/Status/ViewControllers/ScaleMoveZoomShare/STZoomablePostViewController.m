//
//  STZoomablePostViewController.m
//  Status
//
//  Created by Cosmin Andrus on 3/12/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STZoomablePostViewController.h"
#import "STImageCacheController.h"

@interface STZoomablePostViewController ()<UIScrollViewDelegate>
{
    UIImageView *_imageView;
    float _zoomFill;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBlurImgView;

@end

@implementation STZoomablePostViewController

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
    __weak STZoomablePostViewController *weakSelf = self;
    [[STImageCacheController sharedInstance] loadPostImageWithName:self.postPhotoLink andCompletion:^(UIImage *origImg, UIImage *bluredImg) {
        // Set up the image we want to scroll & zoom and add it to the scroll view
        _imageView = [[UIImageView alloc] initWithImage:origImg];
        _imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=origImg.size};
        _backgroundBlurImgView.image = bluredImg;
        [weakSelf setUpTheContext];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) setUpTheContext{
    [self.scrollView addSubview:_imageView];
    
    CGSize imageSize = _imageView.image.size;
    self.scrollView.contentSize = imageSize;

    CGRect scrollViewFrame = self.view.bounds;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    self.scrollView.minimumZoomScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.maximumZoomScale = MAX(imageSize.height/_scrollView.frame.size.height,imageSize.width/_scrollView.frame.size.width);
    self.scrollView.zoomScale = MIN(scaleWidth, scaleHeight);
    _zoomFill = self.scrollView.zoomScale;

    CGRect contentsFrame = [self aspectFitForRect:CGRectMake(0, 0, imageSize.width, imageSize.height)
                                         intoRect:_scrollView.frame];
    _imageView.frame = contentsFrame;
     
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

#pragma mark UIScrollViewDelegate

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    //NSLog(@"self.scrollView.zoomScale = %f", self.scrollView.zoomScale);
    [self centerScrollViewContents];
}

#pragma mark IBACTIONS

- (IBAction)onDismissZoomable:(id)sender {
    [self.scrollView setZoomScale:_zoomFill animated:YES];
    //remove the delegate will prevent scroll to call functions after the view did not exists
    [self.scrollView setDelegate:nil];
    [self performSelector:@selector(dissmissThisView) withObject:nil afterDelay:0.3];

}

-(void) dissmissThisView{
    [self dismissViewControllerAnimated:NO completion:nil];
    //[self.navigationController popViewControllerAnimated:NO];
}

@end
