//
//  STImageCacheController.m
//  Status
//
//  Created by Andrus Cosmin on 17/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STImageCacheController.h"
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

- (void)callEmptyCompletions:(loadPostImageCompletion)completion blurCompl:(loadBlurPostCompletion)blurCompl
{
    completion(nil);
    if (blurCompl!=nil)
        blurCompl(nil);
}

-(void) loadPostImageWithName:(NSString *) imageFullLink
           withPostCompletion:(loadPostImageCompletion) completion
            andBlurCompletion:(loadBlurPostCompletion)blurCompl{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    
    SDWebImageManager *sdManager = [SDWebImageManager sharedManager];
    
    if (![sdManager diskImageExistsForURL:[NSURL URLWithString:imageFullLink]]) {
        if (imageFullLink && ![[_currentPosts valueForKey:@"link"] containsObject:imageFullLink])
            [self startImageDownloadForNewFlowType:STImageDownloadSpecialPriority andDataSource:@[@{@"full_photo_link":imageFullLink}]];
        [self callEmptyCompletions:completion blurCompl:blurCompl];
    }
    else
    {
        if (blurCompl!=nil) {
            NSString *bluredLink = [self blurPostLinkWithURL:imageFullLink];
            UIImage *bluredImg= [UIImage imageWithData:[NSData dataWithContentsOfFile:bluredLink]];
            if (bluredImg!=nil) {
                blurCompl(bluredImg);
            }
        }
        [sdManager downloadImageWithURL:[NSURL URLWithString:imageFullLink] options:SDWebImageHighPriority progress:nil
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                  if (error!=nil) {
                                      NSLog(@"Error loading image from disk: %@", error.debugDescription);
                                      [self callEmptyCompletions:completion blurCompl:blurCompl];

                                  }
                                  else if (finished==YES){
                                      if (completion!=nil) {
                                          completion(image);
                                      }
                                      NSString *bluredLink = [self blurPostLinkWithURL:imageFullLink];
                                      if (![[NSFileManager defaultManager] fileExistsAtPath:bluredLink]) {
                                          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                              [self saveImageForBlur:image imageURL:[NSURL URLWithString:imageFullLink]];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  if (blurCompl!=nil) {
                                                      UIImage *bluredImage = [UIImage imageWithContentsOfFile:bluredLink];
                                                      blurCompl(bluredImage);
                                                  }
                                              });
                                          });
                                      }
                                  }
                                  else
                                      [self callEmptyCompletions:completion blurCompl:blurCompl];
                                  
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
    if ([imageURL.absoluteString rangeOfString:kBasePhotoDownload].location!=NSNotFound) {
        UIImage *img = image;
        img = [img imageCropedFullScreenSize];
        img = [img applyLightEffect];
        NSString *imageFullPath = [self blurPostLinkWithURL:imageURL.absoluteString];
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
                                                          NSString *imageFullPath = [self blurPostLinkWithURL:imageURL.absoluteString];
                                                          if (![[NSFileManager defaultManager] fileExistsAtPath:imageFullPath]) {
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

-(NSString *) getImageCachePath:(BOOL)forFacebook{
    
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

@end
