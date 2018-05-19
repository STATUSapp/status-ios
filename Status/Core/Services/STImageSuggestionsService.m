//
//  STImageSuggestionsService.m
//  Status
//
//  Created by Cosmin Andrus on 28/02/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STImageSuggestionsService.h"
#import "STSuggestedProduct.h"
#import "STUploadImageForSuggestionsRequest.h"
#import "STDataAccessUtils.h"
NSTimeInterval const kTimerInterval = 5.0;

@interface STImageSuggestionsService ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableArray <STSuggestedProduct *> *suggestedProducts;
@property (nonatomic, assign) BOOL suggestedProductsLoaded;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSArray<STSuggestedProduct *> *> *similarProducts;
@property (nonatomic, copy) STImageSuggestionsServiceCompletion suggesstedCompletion;
@property (nonatomic, copy) STImageSuggestionsServiceCompletion similarCompletion;
@property (nonatomic, strong) NSString *similarProductId;
@property (nonatomic, strong) NSString *postId;
@property (nonatomic, strong)NSData *imageData;

@end

@implementation STImageSuggestionsService

#pragma mark - Public

-(void)startServiceWithImage:(UIImage *)image{
    [self clearService];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];

    
    self.imageData = UIImageJPEGRepresentation(image, 1.f);
    __weak STImageSuggestionsService *weakSelf = self;
    [STUploadImageForSuggestionsRequest uploadImageForSuggestionsWithData:self.imageData withCompletion:^(id response, NSError *error) {
        __strong STImageSuggestionsService *strongSelf = weakSelf;
        if (!error) {
            strongSelf.postId = response[@"post_id"];
            [strongSelf setUpTimer];
        }else{
            NSLog(@"Error on STUploadImageForSuggestionsRequest %@", error.debugDescription);
            [strongSelf addSuggestions:nil];
            [strongSelf clearService];
        }
        
    } failure:^(NSError *error) {
        NSLog(@"Error on STUploadImageForSuggestionsRequest %@", error.debugDescription);
        __strong STImageSuggestionsService *strongSelf = weakSelf;
        [strongSelf addSuggestions:nil];
        [strongSelf clearService];
    }];
    
}

-(BOOL)canCommitCurrentPost{
    return self.postId!=nil;
}
-(void)commitCurrentPostWithCaption:(NSString *)caption
                          imageData:(NSData *)imageData
                       shopProducts:(NSArray<STShopProduct *> *)shopProducts
                         completion:(STImageSuggestionsCommitCompletion)completion{
    
    [self transformSuggestionsIntoProducts:^(NSArray *objects) {
        NSMutableArray *allShopProducts = [NSMutableArray new];
        [allShopProducts addObjectsFromArray:shopProducts];
        [allShopProducts addObjectsFromArray:objects];
        
        [STDataAccessUtils commitPostWithId:self.postId
                           withNewImageData:imageData
                             withNewCaption:caption
                           withShopProducts:allShopProducts
                             withCompletion:^(NSArray *finalObjects, NSError *error) {
                                 completion(error, finalObjects);
                             }];
    }];
    
}

-(void)transformSuggestionsIntoProducts:(STImageSuggestionsServiceCompletion)completion{
    __block NSMutableArray <STShopProduct *> *transformedObjects = [@[] mutableCopy];
    __block NSInteger possibleTransformations = self.suggestedProducts.count;
    for (STSuggestedProduct *sp in self.suggestedProducts) {
        [STDataAccessUtils transformSuggestionWithPostId:self.postId
                                            suggestionId:sp.uuid
                                          withCompletion:^(NSArray *objects, NSError *error) {
                                              NSLog(@"Transformation status: %@", error);
                                              possibleTransformations --;
                                              [transformedObjects addObjectsFromArray:objects];
                                              if (possibleTransformations == 0) {
                                                  completion(transformedObjects);
                                              }
                                          }];
    }
}

-(void)setSuggestionsCompletionBlock:(STImageSuggestionsServiceCompletion)completion{
    self.suggesstedCompletion = completion;
    if (self.suggestedProductsLoaded) {
        if (self.suggesstedCompletion) {
            self.suggesstedCompletion(self.suggestedProducts);
        }
    }
}
-(void)setSimilarCompletionBlock:(STImageSuggestionsServiceCompletion)completion
                      forProduct:(STSuggestedProduct *)product{
    self.similarCompletion = completion;
    NSArray *products = [_similarProducts valueForKey:product.uuid];
    if (products == nil) {
        [self downloadSimilarForProduct:product];
    }else{
        self.similarCompletion(products);
    }
}

-(void)changeBaseSuggestion:(STSuggestedProduct *)baseSuggestion
             withSuggestion:(STSuggestedProduct *)suggestion{
    if ([baseSuggestion.uuid isEqualToString:suggestion.uuid]) {
        return;
    }
    
    NSMutableArray <STSuggestedProduct *> *baseSuggestions;
    for (NSString *suggestedProductId in [self.similarProducts allKeys]) {
        if ([baseSuggestion.uuid isEqualToString:suggestedProductId]) {
            baseSuggestions = [self.similarProducts[suggestedProductId] mutableCopy];
            break;
        }
    }
    
//    [baseSuggestions removeObject:suggestion];
//    [baseSuggestions addObject:baseSuggestion];
    self.similarProducts[baseSuggestion.uuid] = nil;
    self.similarProducts[suggestion.uuid] = baseSuggestions;
    NSInteger currentIndex = [self.suggestedProducts indexOfObject:baseSuggestion];
    [self.suggestedProducts replaceObjectAtIndex:currentIndex withObject:suggestion];
}

-(void)removeSuggestion:(STSuggestedProduct *)suggestion{
    [self.suggestedProducts removeObject:suggestion];
}

-(void)clearService{
    [self.timer invalidate];
    self.timer = nil;
    self.suggestedProductsLoaded = NO;
    self.postId = nil;
    self.suggestedProducts = nil;
    self.suggesstedCompletion = nil;
    self.similarCompletion = nil;
    [self saveSuggestionsId];
}

#pragma mark - UINotifications

-(void)appWillResignActive{
    if (self.suggestedProductsLoaded == NO &&
        self.postId!=nil) {
        //save the post_id and resume timer
        [self saveSuggestionsId];
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)appWillEnterForeground{
    [self loadSuggestionsId];
    if (self.postId &&
        self.suggestedProductsLoaded == NO) {
        [self setUpTimer];
    }
}

#pragma mark - Private

-(void)saveSuggestionsId{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:self.postId forKey:@"PENDING_POST_ID"];
    [ud synchronize];
}

-(void)loadSuggestionsId{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    self.postId = [ud valueForKey:@"PENDING_POST_ID"];
}

-(void)setUpTimer{
    _timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval target:self selector:@selector(timerMethod:) userInfo:nil repeats:YES];

}

- (void)addSuggestions:(NSArray<STSuggestedProduct *> *)objects {
    self.suggestedProductsLoaded = YES;
    self.suggestedProducts = [objects mutableCopy];
    if (self.suggesstedCompletion) {
        self.suggesstedCompletion(objects);
    }
}

-(void)timerMethod:(id)sender{
    NSLog(@"Send get suggested request for post_id %@", self.postId);
    __weak STImageSuggestionsService *weakSelf = self;
    [STDataAccessUtils getSuggestedProductsWithPostId:self.postId withCompletion:^(NSArray<STSuggestedProduct *> *objects, NSError *error) {
        __strong STImageSuggestionsService *strongSelf = weakSelf;
        if(error){
            if (error.code == STWebservicesCodesPartialContent) {
                //do nothing, try again later
            }
        }else{
            NSLog(@"Received suggestions: %@", objects);
            [[NSNotificationCenter defaultCenter] removeObserver:strongSelf];
            [strongSelf addSuggestions:objects];
            [strongSelf.timer invalidate];
            strongSelf.timer = nil;
            [strongSelf startSimilarProductsDownload];
        }
    }];
}

- (void)downloadSimilarForProduct:(STSuggestedProduct *)sp {
    __weak STImageSuggestionsService *weakSelf = self;
    [STDataAccessUtils getSimilarProductsWithPostId:self.postId
                                       suggestionId:sp.uuid
                                     withCompletion:^(NSArray *objects, NSError *error) {
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
    self.similarProducts = [@{} mutableCopy];
    for (STSuggestedProduct *sp in _suggestedProducts) {
        [self downloadSimilarForProduct:sp];
    }
}
@end
