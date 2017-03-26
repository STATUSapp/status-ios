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
#import "UIImage+Resize.h"
#import "STPost.h"
#import "STNavigationService.h"
#import "FeedCVC.h"
#import "STTabBarViewController.h"

@interface STMoveScaleViewController ()<UIScrollViewDelegate>
{
    UIImageView *_imageView;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UINavigationBar *transparentNavBar;

@end

@implementation STMoveScaleViewController

+ (instancetype)newControllerForImage:(UIImage *)img shouldCompress:(BOOL)compressing andPost:(STPost *)post {
    // here, no compressing should be done, because it might be a cropping after this
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STMoveScaleViewController *viewController = (STMoveScaleViewController *)[storyboard instantiateViewControllerWithIdentifier:@"STMoveScaleViewController"];
    viewController.currentImg = img;
    viewController.post = post;
    viewController.shouldCompress = compressing;
    
    return viewController;
}

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
    [self.view bringSubviewToFront:_transparentNavBar];
    _imageView = [[UIImageView alloc] initWithImage:_currentImg];
    [self setUpTheContext];
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

-(void) setUpTheContext{
    [self.scrollView addSubview:_imageView];
    CGSize imageSize = _imageView.image.size;
    NSLog(@"Image Size: %@", NSStringFromCGSize(imageSize));
    self.scrollView.contentSize = imageSize;
    
    CGRect scrollViewFrame = self.view.bounds;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;

    self.scrollView.minimumZoomScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.maximumZoomScale = MAX(imageSize.height/scrollViewFrame.size.height,imageSize.width/scrollViewFrame.size.width);
    self.scrollView.zoomScale = MIN(scaleWidth, scaleHeight);
    
    CGRect contentsFrame = [self aspectFitForRect:CGRectMake(0, 0, imageSize.width, imageSize.height) intoRect:scrollViewFrame];
    _imageView.frame = contentsFrame;
    
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.view.bounds.size;
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

#pragma mark IBACTIONS
- (IBAction)onUseBtnPressed:(id)sender {
    UIImage *croppedImg = [self croppedImage];
    
    // after cropping, we should do optimization
    if (_shouldCompress == YES) {
        NSUInteger imgSizeInBytes = [croppedImg calculatedSizeInBytes];
        if (imgSizeInBytes > STMaximumSizeInBytesForUpload) {
            CGFloat compressRatio = (CGFloat)STMaximumSizeInBytesForUpload / (CGFloat)imgSizeInBytes;
            compressRatio = sqrtf(compressRatio);
            CGSize newImgSize = CGSizeMake(compressRatio * croppedImg.size.width, compressRatio * croppedImg.size.height);
            croppedImg = [croppedImg resizedImage:newImgSize interpolationQuality:kCGInterpolationHigh];
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    STSharePhotoViewController *viewController = (STSharePhotoViewController *)[storyboard instantiateViewControllerWithIdentifier:@"shareScene"];
    viewController.imgData = UIImageJPEGRepresentation(croppedImg, 1.f);
    viewController.post = _post;
    viewController.controllerType = _post==nil?STShareControllerAddPost:STShareControllerEditPost;
    [self.navigationController pushViewController:viewController animated:YES];

   }
- (IBAction)onClickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Helpers
-(UIImage *)croppedImage{
    CGRect visibleRect;
    float scale = 1.f/_scrollView.zoomScale;
    CGSize boundsSize = self.view.bounds.size;
    visibleRect.origin.x = _scrollView.contentOffset.x * scale;
    visibleRect.origin.y = _scrollView.contentOffset.y * scale;
    visibleRect.size.width = boundsSize.width * scale;
    visibleRect.size.height = boundsSize.height * scale;
    
    UIImage *croppedImage = [_currentImg croppedImage:visibleRect];
    
    return croppedImage;
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

-(void)dealloc{
    //remove the delegate will prevent scroll to call functions after the view did not exists
    [self.scrollView setDelegate:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
