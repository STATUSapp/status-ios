//
//  STFacebookAlbumsLoader.m
//  Status
//
//  Created by Andrus Cosmin on 31/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookHelper.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKAppInviteContent.h>
#import <FBSDKShareKit/FBSDKAppInviteDialog.h>
#import <FBSDKShareKit/FBSDKShareLinkContent.h>
#import <FBSDKShareKit/FBSDKShareDialog.h>
#import <FBSDKShareKit/FBSDKHashtag.h>
#import <FBSDKShareKit/FBSDKSharePhotoContent.h>
#import <FBSDKShareKit/FBSDKSharePhoto.h>

#import "STNavigationService.h"
#import "STImageCacheController.h"

NSString *const kGetAlbumsGraph = @"/me/albums?fields=name,count,cover_photo,id";
NSString *const kGetPhotosGraph = @"/%@/photos?fields=source,picture&limit=30";

@interface STFacebookHelper()<FBSDKAppInviteDialogDelegate, FBSDKSharingDelegate>
@property (nonatomic, strong) STNativeAdsController *fbNativeAdService;
@end

@implementation STFacebookHelper

-(instancetype)init{
    self = [super init];
    if (self) {
        self.fbNativeAdService = [STNativeAdsController new];
    }
    return self;
}

-(void)loadPhotosForAlbum:(NSString *)albumId withRefreshBlock:(refreshCompletion)refreshCompletion{
    
    
    __block NSString *graph = [NSString stringWithFormat:kGetPhotosGraph,albumId];
    loaderCompletion startBlock;
    loaderCompletion __block nextBlock;
    
    nextBlock = [startBlock = ^(NSString *nextLink){
        
        NSLog(@"Next Link: %@", nextLink);
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:nextLink
          parameters: nil
          HTTPMethod:@"GET"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             NSArray *photosArray = result[@"data"];
             NSLog(@"Photos array: %@", photosArray);
             refreshCompletion(photosArray);
             NSString *nextCursor = result[@"paging"][@"cursors"][@"after"];
             if (nextCursor!=nil) {
                 nextBlock([NSString stringWithFormat:@"%@&after=%@",graph, nextCursor]);
             }
             else
                 nextBlock = nil;

         }];
    } copy];
    
    startBlock(graph);
}

-(void)loadAlbumsWithRefreshBlock:(refreshCompletion)refreshCompletion{
    
    loaderCompletion startBlock;
    loaderCompletion __block nextBlock;
    __weak STFacebookHelper *weakSelf = self;
    nextBlock = [startBlock = ^(NSString *nextLink){
        __strong STFacebookHelper *strongSelf = weakSelf;
        NSLog(@"Next Link: %@", nextLink);
        
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:nextLink
          parameters: nil
          HTTPMethod:@"GET"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             if (error!=nil) {
                 NSLog(@"Load error");
             }
             else
             {
                 NSMutableArray *coverIds = [NSMutableArray new];
                 __block NSMutableArray *newObjects = [NSMutableArray new];
                 for (NSDictionary *dict in result[@"data"]) {
                     if ([dict[@"count"] integerValue] != 0) {
                         [newObjects addObject:dict];
                         if (dict[@"cover_photo"]) {
                             [coverIds addObject:dict[@"cover_photo"]];
                         }
                     }
                 }
                 [strongSelf loadFBCoverPicturesWithIds:[coverIds valueForKey:@"id"] withLoadFbCompletion:^(NSDictionary *resultAlbum) {
                     for (NSString *coverId in [resultAlbum allKeys]) {
                         NSMutableDictionary *dict = nil;
                         for (NSDictionary *album in newObjects) {
                             if ([album[@"cover_photo"][@"id"] isEqualToString:coverId]) {
                                 dict = [NSMutableDictionary dictionaryWithDictionary:album];
                                 break;
                             }
                         }
                         if (dict!=nil) {
                             
                             NSInteger index = [newObjects indexOfObject:dict];
                             NSString *pictureId = resultAlbum[coverId][@"picture"];
                             
                             if (pictureId!=nil) {
                                 dict[@"picture"] = pictureId;
                                 [newObjects replaceObjectAtIndex:index withObject:dict];
                             }
                             
                         }
                     }
                     if (refreshCompletion!=nil) {
                         refreshCompletion(newObjects);
                     }
                     NSString *nextCursor = result[@"paging"][@"cursors"][@"after"];
                     if (nextCursor!=nil) {
                         nextBlock([NSString stringWithFormat:@"%@&after=%@",kGetAlbumsGraph, nextCursor]);
                     }
                     else
                         nextBlock = nil;
                 }];
             }

             
         }];
    } copy];
    
    startBlock(kGetAlbumsGraph);
}

-(void) loadFBCoverPicturesWithIds:(NSArray *)coverIds withLoadFbCompletion:(loadFBPicturesCompletion)completion{
    if (coverIds.count == 0) {
        completion(nil);
        return;
    }
    NSString *graphCoverIds = [NSString stringWithFormat:@"/?ids=%@&fields=picture", [coverIds componentsJoinedByString:@","]];
    
    [[[FBSDKGraphRequest alloc]
      initWithGraphPath:graphCoverIds
      parameters: nil
      HTTPMethod:@"GET"]
     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
         completion(result);

     }];
}

- (void)getUserExtendedInfoWithCompletion:(void (^)(NSDictionary *info))completion {
    NSArray *requiredPermissions = @[@"user_birthday",@"email"];
    NSArray *acceptedPermissions = [[[FBSDKAccessToken currentAccessToken] permissions] allObjects];
    NSMutableArray *deniedPermissions = [NSMutableArray new];
    for (NSString *permission in requiredPermissions){
        if (![acceptedPermissions containsObject:permission]) {
            [deniedPermissions addObject:permission];
        }
    }
    if ([deniedPermissions count]>0) {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        __weak STFacebookHelper *weakSelf = self;
        [loginManager logInWithReadPermissions:deniedPermissions
                            fromViewController:nil
                                       handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                           __strong STFacebookHelper *strongSelf = weakSelf;
                                           if (error!=nil) {
                                               //TODO: add log here
                                           }

            [strongSelf requestForExtendedInfoWithCompletion:completion];
            
        }];
    }
    else
        [self requestForExtendedInfoWithCompletion:completion];
}

- (void)requestForExtendedInfoWithCompletion:(void (^)(NSDictionary *info))completion {
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=birthday,email,picture.type(large),name,gender,about"
                                                                   parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                completion(result);
            }
            else{
                //TODO: add log here
                completion(nil);
            }
        });
        
    }];
}

-(void)shareImageFromLink:(NSString *)imageLink{
    [[CoreManager imageCacheService] loadImageWithName:imageLink
                                         andCompletion:^(UIImage *img) {
                                             FBSDKHashtag *hashtag = [FBSDKHashtag hashtagWithString:@"#STATUSapp"];
                                             UIViewController *viewController = [STNavigationService viewControllerForSelectedTab];
                                             FBSDKSharePhoto *photo = [FBSDKSharePhoto photoWithImage:img userGenerated:NO];
                                             FBSDKSharePhotoContent *contentPhoto = [[FBSDKSharePhotoContent alloc] init];
                                             contentPhoto.photos = @[photo];
                                             contentPhoto.hashtag = hashtag;
                                             FBSDKShareDialog *dialog = [FBSDKShareDialog showFromViewController:viewController
                                                            withContent:contentPhoto
                                                                delegate:self];
                                             dialog.mode = FBSDKShareDialogModeNative;
                                         }];

}

-(NSString *) stringFromDict:(NSDictionary *) dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
        return @"";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

//-(void)promoteTheApp{
//    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
//    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/905201786200515"];
//    content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://api2.getstatusapp.co/fbAppInvitePreviewImage.jpeg"];
//    [FBSDKAppInviteDialog showFromViewController:nil
//                                     withContent:content
//                                        delegate:self];
//
//}

#pragma mark - User Friends
- (void)getMyFriendsWithCompletion:(refreshCompletion)completion {
    loaderCompletion startBlock;
    loaderCompletion __block nextBlock;
    __block NSMutableArray *friendsArray = [NSMutableArray new];
    NSString *graph = @"/me/friends";
    nextBlock = [startBlock = ^(NSString *nextLink){
        
//        NSLog(@"Next Link: %@", nextLink);
        [[[FBSDKGraphRequest alloc]
          initWithGraphPath:nextLink
          parameters: nil
          HTTPMethod:@"GET"]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
             [friendsArray addObjectsFromArray:result[@"data"]];
//             NSLog(@"Photos array: %@", friendsArray);
             NSString *nextCursor = [[result[@"paging"][@"next"] componentsSeparatedByString:@"?"] lastObject];
             if (nextCursor!=nil) {
                 nextBlock([NSString stringWithFormat:@"%@?%@",graph, nextCursor]);
             }
             else
             {
                 nextBlock = nil;
                 completion(friendsArray);
             }
         }];
    } copy];
    
    startBlock([NSString stringWithFormat:@"%@?fields=name",graph]);
}

-(void)loadUserFriendsWithCompletion:(refreshCompletion)completion{
    
    if(![[[[FBSDKAccessToken currentAccessToken] permissions] allObjects] containsObject:@"user_friends"])
    {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        __weak STFacebookHelper *weakSelf = self;
        [loginManager logInWithReadPermissions:@[@"user_friends"]
                            fromViewController:nil
                                       handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                           __strong STFacebookHelper *strongSelf = weakSelf;
                                           [strongSelf getMyFriendsWithCompletion:completion];
                                       }];
        
    }
    else
        [self getMyFriendsWithCompletion:completion];
}
#pragma mark FBSDKAppInviteDialogDelegate
- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results{
    NSLog(@"Results: %@", results);
}
-(void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error{
    NSLog(@"Result error: %@", error);
}

#pragma mark - FBSDKSharingDelegate

-(void)sharerDidCancel:(id<FBSDKSharing>)sharer{
    NSLog(@"Share canceled");
}

-(void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error{
    NSLog(@"Share failed with error: %@", error.description);
}

-(void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results{
    NSLog(@"Share complete with results: %@", results);
}

#pragma mark - FB Native Ads

+ (STNativeAdsController *)fbNativeAdsService{
    return [[CoreManager facebookService] fbNativeAdService];
}

@end
