//
//  STFacebookAlbumsLoader.m
//  Status
//
//  Created by Andrus Cosmin on 31/08/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STFacebookAlbumsLoader.h"
#import <FacebookSDK/FacebookSDK.h>

NSString *const kGetAlbumsGraph = @"/me/albums?fields=name,count,cover_photo,id";
NSString *const kGetPhotosGraph = @"/%@/photos?fields=source,picture&limit=30";
@implementation STFacebookAlbumsLoader

-(void)loadPhotosForAlbum:(NSString *)albumId withRefreshBlock:(refreshCompletion)refreshCompletion{
    
    
    __block NSString *graph = [NSString stringWithFormat:kGetPhotosGraph,albumId];
    loaderCompletion startBlock;
    loaderCompletion __block nextBlock;
    
    nextBlock = [startBlock = ^(NSString *nextLink){
        
        NSLog(@"Next Link: %@", nextLink);
        [FBRequestConnection startWithGraphPath:nextLink
                                     parameters:nil//@{@"limit": @"5"}
                                     HTTPMethod:@"GET"
                              completionHandler:^(
                                                  FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error
                                                  ) {
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
    __weak STFacebookAlbumsLoader *weakSelf = self;
    nextBlock = [startBlock = ^(NSString *nextLink){
        
        NSLog(@"Next Link: %@", nextLink);
        [FBRequestConnection startWithGraphPath:nextLink
                                     parameters:nil//@{@"limit":@"1"}
                                     HTTPMethod:@"GET"
                              completionHandler:^(
                                                  FBRequestConnection *connection,
                                                  id result,
                                                  NSError *error
                                                  ) {
                                  
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

+(void)loadPermissionsWithBlock:(refreshCompletion)refreshCompletion{
    
    [FBRequestConnection startWithGraphPath:@"me/permissions"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (!error) {
                                  NSMutableArray *permissions = [NSMutableArray new];
                                  for(NSDictionary *perm in result[@"data"])
                                  {
                                      if ([perm[@"status"] isEqualToString:@"granted"]) {
                                          [permissions addObject:perm[@"permission"]];
                                      }
                                  }
                                  refreshCompletion([NSArray arrayWithArray:permissions]);
                              }
                              else
                                  refreshCompletion(nil);
                          }];
}

-(void) loadFBCoverPicturesWithIds:(NSArray *)coverIds withLoadFbCompletion:(loadFBPicturesCompletion)completion{
    if (coverIds.count == 0) {
        completion(nil);
        return;
    }
    NSString *graphCoverIds = [NSString stringWithFormat:@"/?ids=%@&fields=picture", [coverIds componentsJoinedByString:@","]];
    [FBRequestConnection startWithGraphPath:graphCoverIds
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              completion(result);
                          }];
}

@end
