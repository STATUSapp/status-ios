//
//  STImageCacheController.m
//  Status
//
//  Created by Andrus Cosmin on 17/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STImageCacheController.h"
#import "NSString+MD5.h"
#import "UIImage+ImageEffects.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"
#import "STLocalNotificationService.h"
#import "STImageCacheObj.h"
#import "STLoggerService.h"

NSInteger const STImageDownloadSpecialPriority = -1;
NSInteger const STImageDownloadmMaximumDownloadsCount = 5;

@interface STImageCacheController()

@property (nonatomic, strong) NSMutableArray <STImageCacheObj *> *objectsArray;
@property (nonatomic, strong) NSMutableArray *sortedFlows;
@end

@implementation STImageCacheController

-(instancetype)init{
    self = [super init];
    if (self) {
        //default sort
        self.sortedFlows = [NSMutableArray arrayWithArray:@[@(STImageDownloadSpecialPriority),@(STFlowTypeHome),@(STFlowTypePopular),@(STFlowTypeRecent), @(STFlowTypeHasttag), @(STFlowTypeMyGallery), @(STFlowTypeUserGallery), @(STFlowTypeSinglePost)]];
    }
    return self;
}

-(void) loadImageWithName:(NSString *) imageFullLink andCompletion:(loadImageCompletion) completion{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    [sdManager loadImageWithURL:[NSURL URLWithString:imageFullLink] options:SDWebImageHighPriority progress:nil
                      completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                          if (error!=nil) {
                              NSLog(@"Error downloading image: %@", error.debugDescription);
                              completion(nil);
                          }
                          else if(finished)
                              completion(image);
                          else
                              completion(nil);
                      }];
    

}

-(void) loadPostImageWithName:(NSString *) imageFullLink
           withPostCompletion:(loadPostImageCompletion) completion{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    
    NSArray *filteredArray = [_objectsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"imageUrl like %@", imageFullLink]];
    
    __weak STImageCacheController *weakSelf = self;
    [sdManager cachedImageExistsForURL:[NSURL URLWithString:imageFullLink] completion:^(BOOL isInCache) {
        __strong STImageCacheController *strongSelf = weakSelf;
        if (!isInCache) {
            if (imageFullLink && filteredArray.count == 0){
                STImageCacheObj *obj = [STImageCacheObj new];
                obj.imageUrl = imageFullLink;
                obj.flowType = @(STImageDownloadSpecialPriority);
                [strongSelf startImageDownloadForNewFlowType:STImageDownloadSpecialPriority andDataSource:@[obj]];
            }
            completion(nil);
        }else{
            [sdManager loadImageWithURL:[NSURL URLWithString:imageFullLink] options:SDWebImageHighPriority progress:nil
                              completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                  if (error!=nil) {
                                      NSLog(@"Error loading image from disk: %@", error.debugDescription);
                                      completion(nil);
                                      
                                  }
                                  else if (finished==YES){
                                      if (completion!=nil) {
                                          completion(image);
                                      }
                                  }
                                  else
                                      completion(nil);
                              }];
        }
    }];
}

-(void) downloadImageWithName:(NSString *) imageFullLink andCompletion:(loadImageComp) completion{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    [sdManager loadImageWithURL:[NSURL URLWithString:imageFullLink] options:SDWebImageHighPriority progress:nil
                      completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                          if (error!=nil) {
                              NSLog(@"Error downloading image: %@", error.debugDescription);
                              completion(imageFullLink, NO, CGSizeZero);
                          }else if(finished){
                              completion(imageFullLink,YES, image.size);
                          }else{
                              if (image) {
                                  completion(imageFullLink,NO, image.size);
                              }else{
                                  completion(imageFullLink,NO, CGSizeZero);
                              }
                          }
                      }];

}

-(void) cleanTemporaryFolder{
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
        NSLog(@"Local stored images was cleared!");
    }];
}

-(void)changeFlowType:(STFlowType) flowType needsSort:(BOOL)needsSort{
    NSInteger firstReplacebleItemIndex;
    if ([[_sortedFlows firstObject] integerValue]!=STImageDownloadSpecialPriority) {
        firstReplacebleItemIndex = 0;
    }else{//get the next one
        firstReplacebleItemIndex = 1;
    }
    
    if ([[_sortedFlows objectAtIndex:firstReplacebleItemIndex] integerValue]!=flowType) {
        [_sortedFlows removeObject:@(flowType)];
        [_sortedFlows insertObject:@(flowType) atIndex:firstReplacebleItemIndex];
    }
    
    NSLog(@"Sorted download flows: %@", _sortedFlows);
    
    if (needsSort==YES) {
        [self sortDownloadArray];
    }
}

-(void)sortDownloadArray{
    [_objectsArray sortUsingComparator:^NSComparisonResult(STImageCacheObj *obj1, STImageCacheObj *obj2) {
        return [@([self.sortedFlows indexOfObject:obj1.flowType]) compare:@([self.sortedFlows indexOfObject:obj2.flowType])];
    }];
    
}

-(void)startImageDownloadForNewFlowType:(STFlowType)flowType andDataSource:(NSArray <STImageCacheObj *>*)newObjects{
    
    [self changeFlowType:flowType needsSort:NO];
    if (_objectsArray == nil) {
        _objectsArray = [NSMutableArray new];
    }
    
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    __weak STImageCacheController *weakSelf = self;
    for (STImageCacheObj *obj in newObjects) {
        __strong STImageCacheController *strongSelf = weakSelf;
        [sdManager cachedImageExistsForURL:[NSURL URLWithString:obj.imageUrl] completion:^(BOOL isInCache) {
            if (!isInCache) {
                STImageCacheObj *objToAdd = obj;
                objToAdd.flowType = @(flowType);
                [strongSelf.objectsArray addObject:objToAdd];
            }
            if ([newObjects lastObject] == obj) {
                [strongSelf sortDownloadArray];
                [strongSelf loadNextPhoto];
            }
        }];
    }
}

- (BOOL)canAddNewImageDownlod{
    NSArray *array = [_objectsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"downloading == YES"]];
    return [array count] < STImageDownloadmMaximumDownloadsCount;
}

- (STImageCacheObj *)firstObjectToBeDownloading{
    NSArray *array = [_objectsArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"downloading == NO"]];
    return [array firstObject];

}
- (void)downloadImageFromObject:(STImageCacheObj *)obj {
    obj.downloading = YES;
    __weak STImageCacheController *weakSelf = self;
    
    __block NSString *fullUrlString = obj.imageUrl;
    
    [self downloadImageWithName:fullUrlString
                  andCompletion:^(NSString *downloadedImage, BOOL downloaded, CGSize downloadedImageSize) {
                      __strong STImageCacheController *strongSelf = weakSelf;
                      if (downloaded==YES) {
                          [[CoreManager localNotificationService] postNotificationName:STLoadImageNotification object:nil userInfo:@{kImageUrlKey:fullUrlString, kImageSizeKey:NSStringFromCGSize(downloadedImageSize)}];
                      }else{
                          
                          NSMutableDictionary *params = [@{} mutableCopy];
                          [params setValue:fullUrlString forKey:kImageLinkKey];
                          [[CoreManager loggerService] sendLogs:params];
                          NSLog(@"Image not downloaded: %@", fullUrlString);
                      }
                      
                      [strongSelf.objectsArray filterUsingPredicate:[NSPredicate predicateWithFormat:@"imageUrl != %@", downloadedImage]];
                      
                      [strongSelf loadNextPhoto];
                  }];
}

-(void)loadNextPhoto{
    NSLog(@"Photo for download count: %lu", (unsigned long)_objectsArray.count);
    if (_objectsArray.count == 0) {
//        [[SDImageCache sharedImageCache] clearMemory];
//        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        return;
    }

    BOOL canAddNewImageToBeDownloaded = [self canAddNewImageDownlod];
    STImageCacheObj *obj = [self firstObjectToBeDownloading];
    while (canAddNewImageToBeDownloaded && obj) {
        [self downloadImageFromObject:obj];
        canAddNewImageToBeDownloaded = [self canAddNewImageDownlod];
        obj = [self firstObjectToBeDownloading];
    }
}

+ (CGSize) imageSizeForUrl:(NSString *)url{
    SDImageCache *sdCache = [SDImageCache sharedImageCache];
    NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:url]];
    UIImage *image = [sdCache imageFromDiskCacheForKey:key];
    
    if (image) {
        return image.size;
    }
    
    return CGSizeZero;
}

+ (void) imageDownloadedForUrl:(NSString *)url completion:(cachedImageCompletion)completion{
    if (!url){
        completion(NO);
        return;
    }
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    
    [sdManager cachedImageExistsForURL:[NSURL URLWithString:url] completion:^(BOOL isInCache) {
        if (isInCache) {
            [sdManager loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageHighPriority progress:nil
                              completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                                  if (error!=nil) {
                                      NSLog(@"Error downloading image: %@", error.debugDescription);
                                  }
                                  else if(finished)
                                  {
                                      [[CoreManager localNotificationService] postNotificationName:STLoadImageNotification object:nil userInfo:@{kImageUrlKey:url, kImageSizeKey:NSStringFromCGSize(image.size)}];
                                  }
                              }];
        }
        completion(isInCache);
    }];
}

@end
