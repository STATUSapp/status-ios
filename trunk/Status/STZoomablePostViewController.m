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
    [[STImageCacheController sharedInstance] loadImageWithName:self.postPhotoLink andCompletion:^(UIImage *img) {
        // Set up the image we want to scroll & zoom and add it to the scroll view
        _imageView = [[UIImageView alloc] initWithImage:img];
        _imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=img.size};
        //_imageView.contentMode = UIViewContentModeScaleAspectFit;
        [weakSelf setUpTheContext];
        
    }];
}

-(void) setUpTheContext{
    [self.scrollView addSubview:_imageView];
    
    CGSize imageSize = _imageView.image.size;
    self.scrollView.contentSize = imageSize;

    CGRect scrollViewFrame = self.view.bounds;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.0f;
    CGSize boundsSize = scrollViewFrame.size;
    self.scrollView.zoomScale = MAX(scaleHeight, scaleWidth);
    _zoomFill = self.scrollView.zoomScale;
    //center the image view on the
    CGRect contentsFrame = _imageView.frame;
    contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;

    _imageView.frame = contentsFrame;
     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    // Return the view that we want to zoom
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // The scroll view has zoomed, so we need to re-center the contents
    //NSLog(@"self.scrollView.zoomScale = %f", self.scrollView.zoomScale);
    [self centerScrollViewContents];
}

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
