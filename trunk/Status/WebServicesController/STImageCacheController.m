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

@interface STImageCacheController()
{
    NSMutableArray *currentPosts;
}
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

-(void) downloadImageWithName:(NSString *) imageFullLink andCompletion:(downloadImageComp) completion{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    NSString *usedLastPath = [imageFullLink lastPathComponent];
    NSString *imageCachePath = [self getImageCachePath:NO];
    NSString *imageFullPath = [imageCachePath stringByAppendingPathComponent:usedLastPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageFullPath]) {
        [[STWebServiceController sharedInstance] downloadImage:imageFullLink storedName:nil withCompletion:^(NSURL *imageURL) {
            completion(imageFullLink);
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

-(void)startImageDownloadForNewDataSource:(NSArray *)newPosts{
    currentPosts = [NSMutableArray arrayWithArray:[newPosts valueForKey:@"full_photo_link"]];
    [self loadNextPhoto];
}

-(void)loadNextPhoto{
    while (currentPosts.count == 0) {
        return;
    }
    __weak STImageCacheController *weakSelf = self;
    [self downloadImageWithName:[currentPosts firstObject] andCompletion:^(NSString *downloadedImage) {
        [currentPosts removeObject:downloadedImage];
        [weakSelf loadNextPhoto];
    }];
    
}

@end
