//
//  STImageSuggestionsService.m
//  Status
//
//  Created by Cosmin Andrus on 28/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STImageSuggestionsService.h"
#import "STShopProduct.h"
#import "STUploadImageForSuggestionsRequest.h"
#import "STDataAccessUtils.h"

NSTimeInterval const kTimerInterval = 3.0;

@interface STImageSuggestionsService ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSString *suggestionsId;
@property (nonatomic, strong) NSArray <STShopProduct *> *suggestedProducts;
@property (nonatomic, assign) BOOL suggestedProductsLoaded;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<STShopProduct *> *> *similarProducts;
@property (nonatomic, copy) STImageSuggestionsServiceCompletion suggesstedCompletion;
@property (nonatomic, copy) STImageSuggestionsServiceCompletion similarCompletion;
@property (nonatomic, strong) NSString *similarProductId;

@end

@implementation STImageSuggestionsService

#pragma mark - Public

-(void)startServiceWithImage:(UIImage *)image{
    [self clearService];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

    
    NSData *imageData = UIImageJPEGRepresentation(image, 1.f);
    __weak STImageSuggestionsService *weakSelf = self;
    [STUploadImageForSuggestionsRequest uploadImageForSuggestionsWithData:imageData withCompletion:^(id response, NSError *error) {
        __strong STImageSuggestionsService *strongSelf = weakSelf;
        if (!error) {
            strongSelf.suggestionsId = response[@"suggestions_id"];
            [strongSelf setUpTimer];
        }else{
            [strongSelf clearService];
        }
        
    } failure:^(NSError *error) {
        __strong STImageSuggestionsService *strongSelf = weakSelf;
        [strongSelf clearService];
    }];
    
}
-(void)setSuggestionsCompletionBlock:(STImageSuggestionsServiceCompletion)completion{
    self.suggesstedCompletion = completion;
    if (self.suggestedProducts) {
        self.suggesstedCompletion(self.suggestedProducts);
    }
}
-(void)setSimilarCompletionBlock:(STImageSuggestionsServiceCompletion)completion
                      forProduct:(STShopProduct *)product{
    self.similarCompletion = completion;
    NSArray *products = [_similarProducts valueForKey:product.uuid];
    if (products == nil) {
        [self downloadSimilarForProduct:product];
    }else{
        self.similarCompletion(products);
    }
}

-(void)clearService{
    [self.timer invalidate];
    self.timer = nil;
    self.suggestedProductsLoaded = NO;
    self.suggestionsId = nil;
    self.suggestedProducts = nil;
    self.suggesstedCompletion = nil;
    self.similarCompletion = nil;
}

#pragma mark - UINotifications

-(void)appWillResignActive{
    if (self.suggestedProductsLoaded == NO &&
        self.suggestionsId!=nil) {
        //save the suggestions_id and resume timer
        [self saveSuggestionsId];
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)appWillEnterForeground{
    [self loadSuggestionsId];
    if (self.suggestionsId &&
        self.suggestedProductsLoaded == NO) {
        [self setUpTimer];
    }
}

#pragma mark - Private

-(void)saveSuggestionsId{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:self.suggestionsId forKey:@"IMAGE_SUGGESTIONS_ID"];
    [ud synchronize];
}

-(void)loadSuggestionsId{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.suggestionsId = [ud valueForKey:@"IMAGE_SUGGESTIONS_ID"];
}

-(void)setUpTimer{
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(timerMethod:) userInfo:nil repeats:YES];

}

-(void)timerMethod:(id)sender{
    __weak STImageSuggestionsService *weakSelf = self;
    [STDataAccessUtils getSuggestedProductsWithId:self.suggestionsId withCompletion:^(NSArray *objects, NSError *error) {
        __strong STImageSuggestionsService *strongSelf = weakSelf;
        if(error){
            if (error.code == STWebservicesCodesPartialContent) {
                //do nothing, try again later
            }
        }else{
            [[NSNotificationCenter defaultCenter] removeObserver:strongSelf];
            strongSelf.suggestedProductsLoaded = YES;
            strongSelf.suggestedProducts = objects;
            if (strongSelf.suggesstedCompletion) {
                strongSelf.suggesstedCompletion(objects);
            }
            [strongSelf.timer invalidate];
            strongSelf.timer = nil;
            [strongSelf startSimilarProductsDownload];
        }
    }];
}

- (void)downloadSimilarForProduct:(STShopProduct *)sp {
    __weak STImageSuggestionsService *weakSelf = self;
    [STDataAccessUtils getSimilarProductsWithId:sp.uuid withCompletion:^(NSArray *objects, NSError *error) {
        __strong STImageSuggestionsService *strongSelf = weakSelf;
        if (objects!=nil) {
            [strongSelf.similarProducts setValue:objects forKey:sp.uuid];
            if ([strongSelf.similarProductId isEqualToString:sp.uuid]) {
                if (strongSelf.similarCompletion) {
                    strongSelf.similarCompletion(objects);
                }
            }
        }
    }];
}

-(void)startSimilarProductsDownload{
    for (STShopProduct *sp in _suggestedProducts) {
        [self downloadSimilarForProduct:sp];
    }
}
@end
