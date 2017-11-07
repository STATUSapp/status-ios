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

NSInteger const STImageDownloadSpecialPriority = -1;

@interface STImageCacheController()

@property (nonatomic, strong) NSMutableArray <STImageCacheObj *> *objectsArray;
@property (nonatomic, strong) NSMutableArray *sortedFlows;
@property (nonatomic, assign) BOOL inProgress;
@end

@implementation STImageCacheController

-(instancetype)init{
    self = [super init];
    if (self) {
        //default sort
        self.sortedFlows = [NSMutableArray arrayWithArray:@[@(STImageDownloadSpecialPriority),@(STFlowTypeHome),@(STFlowTypePopular),@(STFlowTypeRecent), @(STFlowTypeDiscoverNearby), @(STFlowTypeMyGallery), @(STFlowTypeUserGallery), @(STFlowTypeSinglePost)]];
    }
    return self;
}

-(void) loadImageWithName:(NSString *) imageFullLink andCompletion:(loadImageCompletion) completion{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    [sdManager downloadImageWithURL:[NSURL URLWithString:imageFullLink] options:SDWebImageHighPriority progress:nil
                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
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
    
    if (![sdManager diskImageExistsForURL:[NSURL URLWithString:imageFullLink]]) {
        if (imageFullLink && filteredArray.count == 0){
            STImageCacheObj *obj = [STImageCacheObj new];
            obj.imageUrl = imageFullLink;
            obj.flowType = @(STImageDownloadSpecialPriority);
            [self startImageDownloadForNewFlowType:STImageDownloadSpecialPriority andDataSource:@[obj]];
        }
        completion(nil);
    }
    else
    {
        [sdManager downloadImageWithURL:[NSURL URLWithString:imageFullLink] options:SDWebImageHighPriority progress:nil
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
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
    
    
}

-(void) downloadImageWithName:(NSString *) imageFullLink andCompletion:(loadImageComp) completion{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    [sdManager downloadImageWithURL:[NSURL URLWithString:imageFullLink] options:SDWebImageHighPriority progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (error!=nil) {
                                                          NSLog(@"Error downloading image: %@", error.debugDescription);
                                                          completion(imageFullLink, NO, CGSizeZero);
                                                      }
                                                      else if(finished)
                                                      {
                                                          completion(imageFullLink,YES, image.size);
                                                          
                                                      }
                                                      else
                                                          completion(imageFullLink,NO, CGSizeZero);
                                                  }];

}

//-(NSString *) getImageCachePath:(BOOL)forFacebook{
//    
//    NSString *documentsDirectory = NSTemporaryDirectory();//[paths objectAtIndex:0];
//    NSString *imageCachePath = [documentsDirectory stringByAppendingPathComponent:(forFacebook == YES)?@"/FacebookImageCache":@"/ImageCache"];
//    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:imageCachePath]){
//        NSError *error = nil;
//        [[NSFileManager defaultManager] createDirectoryAtPath:imageCachePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
//    }
//    
//    return imageCachePath;
//}


-(void) cleanTemporaryFolder{
//    NSString *tmpPath = [self getImageCachePath:NO];
//    NSError *error = nil;
//    NSFileManager *fm = [NSFileManager defaultManager];
//    for (NSString *file in [fm contentsOfDirectoryAtPath:tmpPath error:&error]) {
//        BOOL success = [fm removeItemAtPath:[tmpPath stringByAppendingPathComponent:file] error:&error];
//        if (!success || error) {
//            NSLog(@"Delete has failed");
//        }
//    }
    
    [[SDImageCache sharedImageCache] clearDisk];
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
        return [@([_sortedFlows indexOfObject:obj1.flowType]) compare:@([_sortedFlows indexOfObject:obj2.flowType])];
    }];
    
}

-(void)startImageDownloadForNewFlowType:(STFlowType)flowType andDataSource:(NSArray <STImageCacheObj *>*)newObjects{
    
    [self changeFlowType:flowType needsSort:NO];
    if (_objectsArray == nil) {
        _objectsArray = [NSMutableArray new];
    }
    
    //sort the flows - move the current to the top
    
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    for (STImageCacheObj *obj in newObjects) {
        if (![sdManager diskImageExistsForURL:[NSURL URLWithString:obj.imageUrl]]) {
            STImageCacheObj *objToAdd = obj;
            objToAdd.flowType = @(flowType);
            [_objectsArray addObject:objToAdd];
        }
        
    }
    [self sortDownloadArray];
    [self loadNextPhoto];
}

-(void)loadNextPhoto{
    NSLog(@"Photo for download count: %lu", (unsigned long)_objectsArray.count);
    while (_objectsArray.count == 0) {
        [[SDImageCache sharedImageCache] clearMemory];
//        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        _inProgress = NO;
        return;
    }
    if (_inProgress == YES) {
        return;
    }
    _inProgress = YES;
    __weak STImageCacheController *weakSelf = self;
    STImageCacheObj *obj = [_objectsArray firstObject];
    
    __block NSString *fullUrlString = obj.imageUrl;
    
    [self downloadImageWithName:fullUrlString
                  andCompletion:^(NSString *downloadedImage, BOOL downloaded, CGSize downloadedImageSize) {
                      
                      if (downloaded==YES) {
                          [[CoreManager localNotificationService] postNotificationName:STLoadImageNotification object:nil userInfo:@{kImageUrlKey:fullUrlString, kImageSizeKey:NSStringFromCGSize(downloadedImageSize)}];
                      }
                      
                      [weakSelf.objectsArray filterUsingPredicate:[NSPredicate predicateWithFormat:@"imageUrl != %@", downloadedImage]];
                      
                      weakSelf.inProgress = NO;
                      [weakSelf loadNextPhoto];
                  }];
    
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

+ (BOOL) imageDownloadedForUrl:(NSString *)url{
    if (!url)
        return NO;
    
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    
    BOOL cacheImageExists = [sdManager diskImageExistsForURL:[NSURL URLWithString:url]];
    
    if (cacheImageExists) {
        [sdManager downloadImageWithURL:[NSURL URLWithString:url] options:SDWebImageHighPriority progress:nil
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                  if (error!=nil) {
                                      NSLog(@"Error downloading image: %@", error.debugDescription);
                                  }
                                  else if(finished)
                                  {
                                      [[CoreManager localNotificationService] postNotificationName:STLoadImageNotification object:nil userInfo:@{kImageUrlKey:url, kImageSizeKey:NSStringFromCGSize(image.size)}];
                                  }
                              }];


    }
    return cacheImageExists;
}

@end
