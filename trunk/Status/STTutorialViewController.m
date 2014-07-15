//
//  STTutorial.m
//  Status
//
//  Created by Silviu on 01/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STTutorialViewController.h"
#import "STTutorialCell.h"
#import "STInviteController.h"

static NSString * const kSTTutorialImagePrefix = @"tutorial_";
static NSInteger const  kSTNumberOfTutorialImages = 6;

@interface STTutorialViewController ()

@property (strong, nonatomic) UIPageControl * pageControl;

@end

@implementation STTutorialViewController

+ (STTutorialViewController *)newInstance{
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil]
            instantiateViewControllerWithIdentifier:NSStringFromClass([STTutorialViewController class])];
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
    // Do any additional setup after loading the view.
    UITapGestureRecognizer * dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewController)];
    dismissTap.cancelsTouchesInView = NO;
    dismissTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:dismissTap];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(10, 50, 300, 50)];
    self.pageControl.numberOfPages = kSTNumberOfTutorialImages;
    self.pageControl.userInteractionEnabled = NO;
    [self.view addSubview:self.pageControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)dismissViewController{
    if ([(STTutorialCell*)[self.collectionView visibleCells].firstObject tag] == kSTNumberOfTutorialImages - 1) {
        [self dismissViewControllerAnimated:YES completion:^{
            if (_delegate && [_delegate respondsToSelector:@selector(tutorialDidDissmiss)]) {
                [_delegate performSelector:@selector(tutorialDidDissmiss)];
            }
        }];
        
        
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark UICollectionView methods

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    STTutorialCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([STTutorialCell class]) forIndexPath:indexPath];
    cell.tutorialImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@%ld", kSTTutorialImagePrefix, (long)indexPath.row]];
    
    if (indexPath.row == kSTNumberOfTutorialImages - 1) {
        cell.backgroundView = [[UIImageView alloc] initWithImage:self.backgroundImageForLastElement];
        cell.backgroundView.backgroundColor = [UIColor clearColor];
    }
    cell.tag = indexPath.row;
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return kSTNumberOfTutorialImages;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    self.pageControl.currentPage = [(STTutorialCell*)[self.collectionView visibleCells].firstObject tag];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.view.frame.size;
}

@end
