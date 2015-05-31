//
//  STFacebookAlbumsLoader.m
//  Status
//
//  Created by Andrus Cosmin on 31/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookHelper.h"
#import <FBSDKCoreKit.h>
#import <FBSDKLoginKit.h>

NSString *const kGetAlbumsGraph = @"/me/albums?fields=name,count,cover_photo,id";
NSString *const kGetPhotosGraph = @"/%@/photos?fields=source,picture&limit=30";
@implementation STFacebookHelper

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
                 [weakSelf loadFBCoverPicturesWithIds:coverIds withLoadFbCompletion:^(NSDictionary *resultAlbum) {
                     for (NSString *coverId in [resultAlbum allKeys]) {
                         NSMutableDictionary *dict = nil;
                         for (NSDictionary *album in newObjects) {
                             if ([album[@"cover_photo"] isEqualToString:coverId]) {
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

//+(void)loadPermissionsWithBlock:(refreshCompletion)refreshCompletion{
//    
//    [[[FBSDKGraphRequest alloc]
//      initWithGraphPath:@"me/permissions"
//      parameters: nil
//      HTTPMethod:@"GET"]
//     startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//         if (!error) {
//             NSMutableArray *permissions = [NSMutableArray new];
//             for(NSDictionary *perm in result[@"data"])
//             {
//                 if ([perm[@"status"] isEqualToString:@"granted"]) {
//                     [permissions addObject:perm[@"permission"]];
//                 }
//             }
//             refreshCompletion([NSArray arrayWithArray:permissions]);
//         }
//         else
//             refreshCompletion(nil);
//     }];
//}

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
    NSArray *requiredPermissions = @[@"user_birthday",@"email",@"user_about_me",@"user_location"];
    NSArray *acceptedPermissions = [[[FBSDKAccessToken currentAccessToken] permissions] allObjects];
    NSMutableArray *deniedPermissions = [NSMutableArray new];
    for (NSString *permission in requiredPermissions){
        if (![acceptedPermissions containsObject:permission]) {
            [deniedPermissions addObject:permission];
        }
    }
    if ([deniedPermissions count]>0) {
        FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
        [loginManager logInWithReadPermissions:deniedPermissions handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
            [self requestForExtendedInfoWithCompletion:completion];
            
        }];
    }
    else
        [self requestForExtendedInfoWithCompletion:completion];
}

- (void)requestForExtendedInfoWithCompletion:(void (^)(NSDictionary *info))completion {
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me?fields=birthday,email,picture.type(large),name,gender,bio,location"
                                                                   parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            completion(result);
        }
        else
            completion(nil);
        
    }];
}

- (void)postImageWithDescription:(NSString *)description imgUrl:(NSString *)imgUrl completion:(facebookCompletion)completion {
    NSString * descriptionString = description.length ? description : @"what's YOUR status?";
    
    NSDictionary *dictPrivacy = [NSDictionary dictionaryWithObjectsAndKeys:@"CUSTOM",@"value", @"ALL_FRIENDS", @"friends", nil];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%@ via %@", descriptionString, STInviteLink] ,@"caption",
                                   [self stringFromDict:dictPrivacy],@"privacy",
                                   @"STATUS", @"title",
                                   descriptionString, @"description",
                                   @"http://getstatusapp.co/",@"link",
                                   imgUrl, @"url",
                                   nil];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/photos"
                                                                   parameters:params
                                                                   HTTPMethod:@"POST"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        completion(result, error);
    }];
}

-(void) shareImageWithImageUrl:(NSString *)imgUrl description:(NSString *)description andCompletion:(facebookCompletion) completion{
    [FBSDKAccessToken refreshCurrentAccessToken:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (error!=nil) {
            completion(nil, error);
        }
        else
        {
            if (![[[FBSDKAccessToken currentAccessToken] permissions] containsObject:@"publish_actions"]) {
                FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
                [loginManager logInWithPublishPermissions:@[@"publish_actions"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                    if (error!=nil) {
                        completion(nil, error);
                    }
                    else
                        [self postImageWithDescription:description imgUrl:imgUrl completion:completion];
                }];
            }
            else
                [self postImageWithDescription:description imgUrl:imgUrl completion:completion];
        }
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


@end
