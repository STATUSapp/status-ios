//
//  STChoosePhotoViewController.m
//  Status
//
//  Created by Cosmin Andrus on 26/03/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STChoosePhotoViewController.h"
#import "STCustomSegment.h"
#import "CoreManager.h"
#import "STNavigationService.h"
#import "STMoveScaleViewController.h"
#import "STImagePickerService.h"
#import "STTabBarViewController.h"
#import "STFacebookAlbumsViewController.h"

typedef NS_ENUM(NSUInteger, STChoosePhotoBottomOption) {
    STChoosePhotoBottomOptionFacebook = 0,
    STChoosePhotoBottomOptionLibrary,
    STChoosePhotoBottomOptionCamera,
    STChoosePhotoBottomOptionCount
};

@interface STChoosePhotoViewController ()<STSCustomSegmentProtocol>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomDistanceConstr;
@property (nonatomic, strong) STCustomSegment *customSegment;
@property (weak, nonatomic) IBOutlet UIView *bottomActionView;

@end

@implementation STChoosePhotoViewController

+(instancetype)newController{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"TakeAPhoto" bundle:[NSBundle mainBundle]];
    STChoosePhotoViewController * vc = [storyboard instantiateViewControllerWithIdentifier:@"STChoosePhotoViewController"];
    return vc;

}

- (void)viewDidLoad {
    [super viewDidLoad];
    _customSegment = [STCustomSegment customSegmentWithDelegate:self];
    [_customSegment configureSegmentWithDelegate:self];
    CGRect rect = _customSegment.frame;
    rect.origin.x = 0.f;
    rect.origin.y = 0.f;
    rect.size.height = _bottomActionView.frame.size.height;
    rect.size.width = _bottomActionView.frame.size.width;
    
    _customSegment.frame = rect;
    _customSegment.translatesAutoresizingMaskIntoConstraints = YES;
    
    [_bottomActionView addSubview:_customSegment];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageWasPostedWithPostId:) name:STPostNewImageUploaded object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageWasPostedWithPostId:) name:STPostImageWasEdited object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookPickerDidChooseImage:)
                                                 name:STFacebookPickerNotification
                                               object:nil];

}

-(void)viewWillAppear:(BOOL)animated{
    [_customSegment selectSegmentIndex:STChoosePhotoBottomOptionFacebook];
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
    [(STTabBarViewController *)self.tabBarController setTabBarHidden:NO];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notifications

- (void)imageWasPostedWithPostId:(NSNotification *)notif {
    //    NSString *postId = notif.userInfo[kPostIdKey];
    //    FeedCVC *feedCVC = [FeedCVC singleFeedControllerWithPostId:postId];
    //    [[CoreManager navigationService] pushViewController:feedCVC inTabbarAtIndex:STTabBarIndexHome keepThecurrentStack:NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [[CoreManager navigationService] switchToTabBarAtIndex:STTabBarIndexProfile popToRootVC:YES];
}

-(void)facebookPickerDidChooseImage:(NSNotification *)notif{
    
    UIImage *image = notif.userInfo[kImageKey];
    
    STMoveScaleViewController * moveScaleVC = [STMoveScaleViewController newControllerForImage:image shouldCompress:NO andPost:nil];
    
    NSArray *viewControllers = @[[self.navigationController.viewControllers firstObject], moveScaleVC];
    
    [self.navigationController setViewControllers:viewControllers animated:YES];
    
}


#pragma mark - IBACTIONS

- (IBAction)onBackButtonPressed:(id)sender {
    [[CoreManager navigationService] dismissChoosePhotoVC];
}


#pragma mark - STCustomSegmentProtocol

- (CGFloat)segmentTopSpace:(STCustomSegment *)segment{
    return 0.f;
}
- (CGFloat)segmentBottomSpace:(STCustomSegment *)segment{
    return 0.f;
}
- (NSInteger)segmentNumberOfButtons:(STCustomSegment *)segment{
    return STChoosePhotoBottomOptionCount;
}
- (NSString *)segment:(STCustomSegment *)segment buttonTitleForIndex:(NSInteger)index{
    return [self stringForOption:index];
}
- (void)segment:(STCustomSegment *)segment buttonPressedAtIndex:(NSInteger)index{
    STChoosePhotoBottomOption option = index;
    switch (option) {
        case STChoosePhotoBottomOptionLibrary:
            [self uploadPhotoFromLibrary];
            break;
        case STChoosePhotoBottomOptionCamera:
            [self takeAPhotoWithCamera];
            break;
        case STChoosePhotoBottomOptionFacebook:
            //nothing to handle
            break;
        default:
            break;
    }
}

- (NSInteger)segmentDefaultSelectedIndex:(STCustomSegment *)segment{
    return STChoosePhotoBottomOptionFacebook;
}

-(UIColor *)backgroundColorForSegment:(STCustomSegment *)segment{
    return [UIColor colorWithRed:247.f/255.f
                           green:247.f/255.f
                            blue:247.f/255.f
                           alpha:1.f];
}

-(STSegmentSelection)segmentSelectionForSegment:(STCustomSegment *)segment{
    return STSegmentSelectionHighlightButton;
}

#pragma mark - STCustomSegment Helpers

-(NSString *)stringForOption:(STChoosePhotoBottomOption)option{
    
    NSString *resultString = @"";
    switch (option) {
        case STChoosePhotoBottomOptionFacebook:
            resultString = NSLocalizedString(@"FACEBOOK", nil);
            break;
        case STChoosePhotoBottomOptionLibrary:
            resultString = NSLocalizedString(@"LIBRARY", nil);
            break;
        case STChoosePhotoBottomOptionCamera:
            resultString = NSLocalizedString(@"PHOTO", nil);
            break;
        default:
            break;
    }
    
    return resultString;
}

- (void)takeAPhotoWithCamera{
    
    __weak STChoosePhotoViewController * weakSelf = self;
    imagePickerCompletion completion = ^(UIImage *img, BOOL shouldCompressImage){
        if (img) {
            STMoveScaleViewController * moveScaleVC = [STMoveScaleViewController newControllerForImage:img shouldCompress:shouldCompressImage andPost:nil];
            [weakSelf.navigationController pushViewController:moveScaleVC animated:YES];
        }
        else
            [weakSelf.customSegment selectSegmentIndex:STChoosePhotoBottomOptionFacebook];
    };
    
    [[CoreManager imagePickerService] takeCameraPictureFromController:self withCompletion:completion];
}

- (void)uploadPhotoFromLibrary{
    __weak STChoosePhotoViewController * weakSelf = self;
    imagePickerCompletion completion = ^(UIImage *img, BOOL shouldCompressImage){
        
        STMoveScaleViewController * moveScaleVC = [STMoveScaleViewController newControllerForImage:img shouldCompress:shouldCompressImage andPost:nil];
        [weakSelf.navigationController pushViewController:moveScaleVC animated:YES];
    };
    
    [[CoreManager imagePickerService] launchLibraryPickerFromController:self withCompletion:completion];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
