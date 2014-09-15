//
//  STImageCacheController.m
//  Status
//
//  Created by Andrus Cosmin on 17/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STImageCacheController.h"
#import "STWebServiceController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NSString+MD5.h"
#import "UIImage+ImageEffects.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"

NSUInteger const STImageDownloadSpecialPriority = -1;
@interface STImageCacheController()

@property (nonatomic, strong) NSMutableArray *currentPosts;
@property (nonatomic, strong) NSMutableArray *sortedFlows;
@property (nonatomic, assign) BOOL inProgress;
@end

@implementation STImageCacheController
+(STImageCacheController *) sharedInstance{
    static STImageCacheController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

#pragma mark - NOT_USE_SD_WEB_MARK
#if !USE_SD_WEB

-(void) loadImageWithName:(NSString *) imageFullLink andCompletion:(loadImageCompletion) completion isForFacebook:(BOOL)forFacebook{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    
    NSString *usedLastPath = forFacebook==YES?[imageFullLink md5]:[imageFullLink lastPathComponent];
    NSString *imageCachePath = [self getImageCachePath:forFacebook];
    NSString *imageFullPath = [imageCachePath stringByAppendingPathComponent:usedLastPath];
    __block UIImage *img = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageFullPath]) {
        [[STWebServiceController sharedInstance] downloadImage:imageFullLink storedName:forFacebook==YES?usedLastPath:nil withCompletion:^(NSURL *imageURL) {
            if (completion!=nil) {
                img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
                completion(img);
            }
        }];
    }
    else
    {
        if (completion!=nil) {
            img = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFullPath]];
            completion(img);
        }
    }
}

-(void) loadPostImageWithName:(NSString *) imageFullLink andCompletion:(loadPostImageCompletion) completion{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    
    NSString *usedLastPath = [imageFullLink lastPathComponent];
    NSString *imageCachePath = [self getImageCachePath:NO];
    NSString *imageFullPath = [imageCachePath stringByAppendingPathComponent:usedLastPath];
    __block UIImage *img = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageFullPath]) {
        //start the downloading queue and the view will be notified;
        if (![[_currentPosts valueForKey:@"link"] containsObject:imageFullLink]) {
            if (imageFullLink!=nil) {
                [self startImageDownloadForNewFlowType:STImageDownloadSpecialPriority andDataSource:@[@{@"full_photo_link":imageFullLink}]];
            }
        }
        
    }
    else
    {
        if (completion!=nil) {
            img = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFullPath]];
            NSString *bluredLink = [self blurPostLinkWith:imageFullLink imageCachePath:imageCachePath];
            UIImage *bluredImg= [UIImage imageWithData:[NSData dataWithContentsOfFile:bluredLink]];
            completion(img, bluredImg);
        }
    }
}

- (NSString *)blurPostLinkWith:(NSString *)imageFullLink imageCachePath:(NSString *)imageCachePath {
    NSString *extention = [imageFullLink pathExtension];
    NSString *blurName = [[[[imageFullLink lastPathComponent] stringByDeletingPathExtension] stringByAppendingString:@"-blur."] stringByAppendingString:extention];
    NSString *imageFullPath = [imageCachePath stringByAppendingPathComponent:blurName];
    return imageFullPath;
}

- (void)saveImageForBlurPosts:(NSString *)imageCachePath imageFullLink:(NSString *)imageFullLink imageURL:(NSURL *)imageURL {
    if ([imageFullLink rangeOfString:kBasePhotoDownload].location!=NSNotFound) {
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
        img = [img imageCropedFullScreenSize];
        img = [img applyLightEffect];
        NSString *imageFullPath = [self blurPostLinkWith:imageFullLink imageCachePath:imageCachePath];
        //TOOD: this is a right compresion?
        NSData *imagData = UIImageJPEGRepresentation(img, 0.25f);
        [imagData writeToFile:imageFullPath atomically:YES];
    }
}

-(void) downloadImageWithName:(NSString *) imageFullLink andCompletion:(downloadImageComp) completion{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    NSString *imageCachePath = [self getImageCachePath:NO];
    NSString *imageFullPath = [imageCachePath stringByAppendingPathComponent:imageFullLink.lastPathComponent];
    __weak STImageCacheController *weakSelf = self;
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageFullPath]) {
        [[STWebServiceController sharedInstance] downloadImage:imageFullLink storedName:nil withCompletion:^(NSURL *imageURL) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [weakSelf saveImageForBlurPosts:imageCachePath imageFullLink:imageFullLink imageURL:imageURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(imageFullLink);
                });
            });
        }];
    }
    else
    {
        completion(imageFullLink);
    }
}

-(void) loadFBCoverPictureForAlbum:(NSDictionary *)album andCompletion:(loadImageCompletion)completion{
    NSString *coverImagePath = [album[@"cover_photo"] stringByAppendingString:@".jpg"];
    NSString *imageCachePath = [self getImageCachePath:YES];
    NSString *imageFullPath = [imageCachePath stringByAppendingPathComponent:coverImagePath];
    __block UIImage *img = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageFullPath]) {
        if (album[@"picture"] == nil) {
            NSLog(@"Error on loading album picture");
            completion(nil);
            return;
        }
        [[STWebServiceController sharedInstance] downloadImage:album[@"picture"] storedName:coverImagePath withCompletion:^(NSURL *imageURL) {
            if (completion!=nil) {
                img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
                completion(img);
            }
        }];
    }
    else
    {
        if (completion!=nil) {
            img = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFullPath]];
            completion(img);
        }
    }
}

-(NSString *) getImageCachePath:(BOOL)forFacebook{
    
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = NSTemporaryDirectory();//[paths objectAtIndex:0];
    NSString *imageCachePath = [documentsDirectory stringByAppendingPathComponent:(forFacebook == YES)?@"/FacebookImageCache":@"/ImageCache"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageCachePath]){
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:imageCachePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    }
    
    return imageCachePath;
}


-(void) cleanTemporaryFolder{
    NSString *tmpPath = [self getImageCachePath:NO];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSString *file in [fm contentsOfDirectoryAtPath:tmpPath error:&error]) {
        BOOL success = [fm removeItemAtPath:[tmpPath stringByAppendingPathComponent:file] error:&error];
        if (!success || error) {
            NSLog(@"Delete has failed");
        }
    }
}

-(void)changeFlowType:(STFlowType) flowType needsSort:(BOOL)needsSort{
    if (_sortedFlows == nil) {
        //default sort
        _sortedFlows = [NSMutableArray arrayWithArray:@[@(STImageDownloadSpecialPriority),@(STFlowTypeAllPosts), @(STFlowTypeDiscoverNearby), @(STFlowTypeMyProfile), @(STFlowTypeUserProfile), @(STFlowTypeSinglePost)]];
    }
    
    if ([[_sortedFlows firstObject] integerValue]!=flowType) {
        [_sortedFlows removeObject:@(flowType)];
        [_sortedFlows insertObject:@(flowType) atIndex:0];
    }
    
    if (needsSort==YES) {
        [self sortDownloadArray];
    }
}

-(void)sortDownloadArray{
    [_currentPosts sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [@([_sortedFlows indexOfObject:@([obj1[@"flowType"] integerValue])]) compare:@([_sortedFlows indexOfObject:@([obj2[@"flowType"] integerValue])])];
    }];

}

-(void)startImageDownloadForNewFlowType:(STFlowType)flowType andDataSource:(NSArray *)newPosts{

    [self changeFlowType:flowType needsSort:NO];
    
    if (_currentPosts == nil) {
        _currentPosts = [NSMutableArray new];
    }
    
    //sort the flows - move the current to the top
    NSArray *imagesLinksArray = [newPosts valueForKey:@"full_photo_link"];

    for (NSString *link in imagesLinksArray) {
        NSString *imageCachePath = [self getImageCachePath:NO];
        NSString *imageFullPath = [imageCachePath stringByAppendingPathComponent:link.lastPathComponent];
        if (![[NSFileManager defaultManager] fileExistsAtPath:imageFullPath]) {
            [_currentPosts addObject:@{@"link":link, @"flowType":@(flowType)}];
        }

    }
    [self sortDownloadArray];
    [self loadNextPhoto];
}

-(void)loadNextPhoto{
    NSLog(@"Photo for download count: %lu", (unsigned long)_currentPosts.count);
    while (_currentPosts.count == 0) {
        _inProgress = NO;
        return;
    }
    if (_inProgress == YES) {
        return;
    }
    _inProgress = YES;
    __weak STImageCacheController *weakSelf = self;
    [self downloadImageWithName:[[_currentPosts firstObject] valueForKey:@"link"] andCompletion:^(NSString *downloadedImage) {
        [[NSNotificationCenter defaultCenter] postNotificationName:STLoadImageNotification object:[NSString stringWithString:downloadedImage]];
        NSUInteger index = [[_currentPosts valueForKey:@"link"] indexOfObject:downloadedImage];
        if (index!=NSNotFound) {
            [_currentPosts removeObjectAtIndex:index];
        }
        _inProgress = NO;
        [weakSelf loadNextPhoto];
    }];
    
}

#else
#pragma mark - NOT_USE_SD_WEB_MARK
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
                              {
                                  completion(image);
                                  
                              }
                              else
                                  completion(nil);
                          }];
    

}

-(void) loadPostImageWithName:(NSString *) imageFullLink
           withPostCompletion:(loadPostImageCompletion) completion
            andBlurCompletion:(loadBlurPostCompletion)blurCompl{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    
    if (![sdManager diskImageExistsForURL:[NSURL URLWithString:imageFullLink]]) {
        if (![[_currentPosts valueForKey:@"link"] containsObject:imageFullLink]) {
            if (imageFullLink!=nil) {
                
                [self startImageDownloadForNewFlowType:STImageDownloadSpecialPriority andDataSource:@[@{@"full_photo_link":imageFullLink}]];
                completion(nil);
                if (blurCompl!=nil) {
                    blurCompl(nil);
                }
            }
        }
        else{
            completion(nil);
            if (blurCompl!=nil) {
                blurCompl(nil);
            }
        }
        
    }
    else
    {
        if (blurCompl!=nil) {
            NSString *bluredLink = [self blurPostLinkWithURL:imageFullLink];
            UIImage *bluredImg= [UIImage imageWithData:[NSData dataWithContentsOfFile:bluredLink]];
            blurCompl(bluredImg);
        }
        [sdManager downloadImageWithURL:[NSURL URLWithString:imageFullLink] options:SDWebImageHighPriority progress:nil
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                  if (error!=nil) {
                                      NSLog(@"Error loading image from disk: %@", error.debugDescription);
                                      completion(nil);
                                      if (blurCompl!=nil) {
                                          blurCompl(nil);
                                      }
                                  }
                                  else if (finished==YES){
                                      completion(image);

                                  }
                                  else{
                                      completion(nil);
                                      if (blurCompl!=nil) {
                                          blurCompl(nil);
                                      }
                                  }
                                  
                              }];

    }
    
    
}

- (NSString *)blurPostLinkWithURL:(NSString *)imageFullLink{
    NSString *extention = [imageFullLink pathExtension];
    NSString *blurName = [[[[imageFullLink lastPathComponent] stringByDeletingPathExtension] stringByAppendingString:@"-blur."] stringByAppendingString:extention];
    NSString *imageFullPath = [[self getImageCachePath:NO] stringByAppendingPathComponent:blurName];
    return imageFullPath;
}

- (void)saveImageForBlur:(UIImage *)image imageURL:(NSURL *)imageURL {
    //TODO: save into the same container
    if ([imageURL.absoluteString rangeOfString:kBasePhotoDownload].location!=NSNotFound) {
        UIImage *img = image;
        img = [img imageCropedFullScreenSize];
        img = [img applyLightEffect];
        NSString *imageFullPath = [self blurPostLinkWithURL:imageURL.absoluteString];
        //TOOD: this is a right compresion?
        NSData *imagData = UIImageJPEGRepresentation(img, 0.25f);
        [imagData writeToFile:imageFullPath atomically:YES];
    }
}

-(void) downloadImageWithName:(NSString *) imageFullLink andCompletion:(loadImageComp) completion{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    __weak STImageCacheController *weakSelf = self;
    [sdManager downloadImageWithURL:[NSURL URLWithString:imageFullLink] options:SDWebImageHighPriority progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (error!=nil) {
                                                          NSLog(@"Error downloading image: %@", error.debugDescription);
                                                          completion(imageFullLink, NO);
                                                      }
                                                      else if(finished)
                                                      {
                                                          if (cacheType == SDImageCacheTypeNone) {
                                                              dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                                                  [weakSelf saveImageForBlur:image imageURL:imageURL];
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      completion(imageFullLink, YES);
                                                                  });
                                                              });
                                                          }
                                                          else
                                                              completion(imageFullLink,NO);
                                                          
                                                      }
                                                      else
                                                          completion(imageFullLink,NO);
                                                  }];

}

-(void) loadFBCoverPictureForAlbum:(NSDictionary *)album andCompletion:(loadImageCompletion)completion{
    //TODO: change this to sdweb
    NSString *coverImagePath = [album[@"cover_photo"] stringByAppendingString:@".jpg"];
    NSString *imageCachePath = [self getImageCachePath:YES];
    NSString *imageFullPath = [imageCachePath stringByAppendingPathComponent:coverImagePath];
    __block UIImage *img = nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageFullPath]) {
        if (album[@"picture"] == nil) {
            NSLog(@"Error on loading album picture");
            completion(nil);
            return;
        }
        [[STWebServiceController sharedInstance] downloadImage:album[@"picture"] storedName:coverImagePath withCompletion:^(NSURL *imageURL) {
            if (completion!=nil) {
                img = [UIImage imageWithData:[NSData dataWithContentsOfURL:imageURL]];
                completion(img);
            }
        }];
    }
    else
    {
        if (completion!=nil) {
            img = [UIImage imageWithData:[NSData dataWithContentsOfFile:imageFullPath]];
            completion(img);
        }
    }
}

-(NSString *) getImageCachePath:(BOOL)forFacebook{
    
    //NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = NSTemporaryDirectory();//[paths objectAtIndex:0];
    NSString *imageCachePath = [documentsDirectory stringByAppendingPathComponent:(forFacebook == YES)?@"/FacebookImageCache":@"/ImageCache"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageCachePath]){
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:imageCachePath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    }
    
    return imageCachePath;
}


-(void) cleanTemporaryFolder{
    NSString *tmpPath = [self getImageCachePath:NO];
    NSError *error = nil;
    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSString *file in [fm contentsOfDirectoryAtPath:tmpPath error:&error]) {
        BOOL success = [fm removeItemAtPath:[tmpPath stringByAppendingPathComponent:file] error:&error];
        if (!success || error) {
            NSLog(@"Delete has failed");
        }
    }
    
    [[SDImageCache sharedImageCache] clearDisk];
}

-(void)changeFlowType:(STFlowType) flowType needsSort:(BOOL)needsSort{
    if (_sortedFlows == nil) {
        //default sort
        _sortedFlows = [NSMutableArray arrayWithArray:@[@(STImageDownloadSpecialPriority),@(STFlowTypeAllPosts), @(STFlowTypeDiscoverNearby), @(STFlowTypeMyProfile), @(STFlowTypeUserProfile), @(STFlowTypeSinglePost)]];
    }
    
    if ([[_sortedFlows firstObject] integerValue]!=flowType) {
        [_sortedFlows removeObject:@(flowType)];
        [_sortedFlows insertObject:@(flowType) atIndex:0];
    }
    
    if (needsSort==YES) {
        [self sortDownloadArray];
    }
}

-(void)sortDownloadArray{
    [_currentPosts sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        return [@([_sortedFlows indexOfObject:@([obj1[@"flowType"] integerValue])]) compare:@([_sortedFlows indexOfObject:@([obj2[@"flowType"] integerValue])])];
    }];
    
}

-(void)startImageDownloadForNewFlowType:(STFlowType)flowType andDataSource:(NSArray *)newPosts{
    
    [self changeFlowType:flowType needsSort:NO];
    if (_currentPosts == nil) {
        _currentPosts = [NSMutableArray new];
    }
    
    //sort the flows - move the current to the top
    NSArray *imagesLinksArray = [newPosts valueForKey:@"full_photo_link"];
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    for (NSString *link in imagesLinksArray) {
        if (![sdManager diskImageExistsForURL:[NSURL URLWithString:link]]) {
            [_currentPosts addObject:@{@"link":link, @"flowType":@(flowType)}];
        }
        
    }
    [self sortDownloadArray];
    [self loadNextPhoto];
}

-(void)loadNextPhoto{
    NSLog(@"Photo for download count: %lu", (unsigned long)_currentPosts.count);
    while (_currentPosts.count == 0) {
//        [[SDImageCache sharedImageCache] clearMemory];
        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        _inProgress = NO;
        return;
    }
    if (_inProgress == YES) {
        return;
    }
    _inProgress = YES;
    __weak STImageCacheController *weakSelf = self;
    [self downloadImageWithName:[[_currentPosts firstObject] valueForKey:@"link"] andCompletion:^(NSString *downloadedImage, BOOL downloaded) {
        
        if (downloaded==YES) {
            [[NSNotificationCenter defaultCenter] postNotificationName:STLoadImageNotification object:[NSString stringWithString:downloadedImage]];
        }
        NSUInteger index = [[weakSelf.currentPosts valueForKey:@"link"] indexOfObject:downloadedImage];
        if (index!=NSNotFound) {
            [weakSelf.currentPosts removeObjectAtIndex:index];
        }
        weakSelf.inProgress = NO;
        [weakSelf loadNextPhoto];
    }];
    
}

#endif
@end
