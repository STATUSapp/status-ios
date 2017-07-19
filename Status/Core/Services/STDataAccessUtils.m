//
//  STDataAccessUtils.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STDataAccessUtils.h"
#import "STDataModelObjects.h"
#import "STRequests.h"
#import "STUsersPool.h"
#import "STPostsPool.h"
#import "STPost.h"
#import "STCatalogParentCategory.h"
#import "STCatalogCategory.h"
#import "STBrandObj.h"
#import "STShopProduct.h"
#import "STUserProfile.h"
#import "STConversationUser.h"
#import "STNotificationObj.h"
#import "CoreManager.h"
#import "STLocalNotificationService.h"
#import "STShopProductsUploader.h"
#import "STNavigationService.h"
#import "STCommission.h"
#import "STWithdrawDetailsObj.h"

@implementation STDataAccessUtils

#pragma mark - Users
+(void)getUserDataForUserId:(NSString *)userId
             withCompletion:(STDataAccessCompletionBlock)completion{
    STRequestCompletionBlock respnseCompletion = ^(id response, NSError *error){
        if([response[@"status_code"] integerValue] == STWebservicesSuccesCod){
            STListUser *receivedUser = [STListUser new];
            receivedUser.uuid = userId;
            receivedUser.thumbnail = response[@"small_photo_link"];
            receivedUser.userName = response[@"user_name"];
            [[CoreManager usersPool] addUsers:@[receivedUser]];
            completion(@[receivedUser], nil);
        }
        else
            completion(nil, error);
    };
    [STGetUserInfoRequest getInfoForUser:userId
                              completion:respnseCompletion
                                 failure:^(NSError *error) {
                                     completion(nil, error);
                                 }];
    
}

+(void)getSuggestUsersForFollowType:(STFollowType)followType
                         withOffset:(NSNumber *)offset
                      andCompletion:(STDataAccessCompletionBlock)completion{
    [STGetSuggestUsersRequest getSuggestUsersForFollowType:followType
                                                withOffset:offset
                                            withCompletion:^(id response, NSError *error) {
        if (error!=nil) {
            completion(nil, error);
        }
        else
        {
            NSMutableArray *objects = [NSMutableArray new];
            if (followType == STFollowTypePeople) {
                for (NSDictionary *dict in response[@"data"]) {
                    STSuggestedUser *su = [STSuggestedUser suggestedUserWithDict:dict];
                    [objects addObject:su];
                }
            }
            else
            {
                for (NSDictionary *dict in [response[@"data"] valueForKey:@"facebookFriends"]) {
                    STSuggestedUser *su = [STSuggestedUser suggestedUserWithDict:dict];
                    [objects addObject:su];
                }
                for (NSDictionary *dict in [response[@"data"] valueForKey:@"emails"]) {
                    STSuggestedUser *su = [STSuggestedUser suggestedUserWithDict:dict];
                    [objects addObject:su];
                }
            }
            [[CoreManager usersPool] addUsers:objects];
            completion([NSArray arrayWithArray:objects], nil);
            
        }
        
    } failure:^(NSError *error) {
        completion(nil, error);
    }];
}

+(void)getLikesForPostId:(NSString *)postId
          withCompletion:(STDataAccessCompletionBlock)completion{
    STRequestCompletionBlock completionBlock = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            NSMutableArray *objects = [NSMutableArray new];
            for (NSDictionary *dict in response[@"data"]) {
                STListUser *lu = [STListUser listUserWithDict:dict];
                [objects addObject:lu];
            }
            [[CoreManager usersPool] addUsers:objects];
            completion([NSArray arrayWithArray:objects], nil);
        }
    };
    
    [STGetPostLikesRequest getPostLikes:postId withCompletion:completionBlock failure:nil];
}

+ (void)getFollowingForUserId:(NSString *)userId offset:(NSNumber *)offset withCompletion:(STDataAccessCompletionBlock)completion {
    STRequestCompletionBlock completionBlock = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            NSMutableArray *objects = [NSMutableArray new];
            for (NSDictionary *dict in response[@"data"]) {
                STListUser *lu = [STListUser listUserWithDict:dict];
                [objects addObject:lu];
            }
            [[CoreManager usersPool] addUsers:objects];
            completion([NSArray arrayWithArray:objects], nil);
        }
    };
    
    [STGetFollowingRequest getFollowingForUser:userId withOffset:offset withCompletion:completionBlock failure:^(NSError *error) {
        
        NSData * data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSDictionary * response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", response);
        completion(nil, error);
    }];
}

+ (void)getFollowersForUserId:(NSString *)userId offset:(NSNumber *)offset withCompletion:(STDataAccessCompletionBlock)completion {
    STRequestCompletionBlock completionBlock = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            NSMutableArray *objects = [NSMutableArray new];
            for (NSDictionary *dict in response[@"data"]) {
                STListUser *lu = [STListUser listUserWithDict:dict];
                [objects addObject:lu];
            }
            [[CoreManager usersPool] addUsers:objects];
            completion([NSArray arrayWithArray:objects], nil);
        }
    };
    
    [STGetFollowersRequest getFollowersForUser:userId withOffset:offset withCompletion:completionBlock failure:^(NSError *error) {
        
        NSData * data = error.userInfo[@"com.alamofire.serialization.response.error.data"];
        NSDictionary * response = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        NSLog(@"%@", response);
        completion(nil, error);
    }];
}

+(void)getConversationUsersForScope:(STSearchScopeControl)scope
                       searchString:(NSString *)searchString
                         fromOffset:(NSInteger)offset
                      andCompletion:(STDataAccessCompletionBlock)completion{
    
    STRequestCompletionBlock completion1 = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
            
            NSMutableArray *objects = [NSMutableArray new];
            for (NSDictionary *dict in response[@"data"]) {
                STConversationUser *cu = [STConversationUser conversationUserFromDict:dict];
                [objects addObject:cu];
            }
            completion([NSArray arrayWithArray:objects], nil);
        }
        else
            completion(nil, [NSError errorWithDomain:@"com.status.error" code:11011 userInfo:nil]);
        
    };
    
    STRequestFailureBlock failBlock = ^(NSError *error){
        NSLog(@"Error on getting users");
        completion(nil, error);
    };

    
    [STGetUsersRequest getUsersForScope:scope
                         withSearchText:searchString
                              andOffset:offset
                             completion:completion1
                                failure:failBlock];
}


+(void)getFlowTemplatesWithCompletion:(STDataAccessCompletionBlock)completion{
    STRequestCompletionBlock completionBlock = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            NSMutableArray *objects = [NSMutableArray new];
            NSArray *responseArray = response[@"data"];
            NSLog(@"Flows: %@", responseArray);
            NSMutableArray *flowsArray = [NSMutableArray arrayWithArray:@[@"nearby", @"home", @"popular", @"recent"]];
            for (NSDictionary *dict in responseArray) {
                STFlowTemplate *ft = [STFlowTemplate flowTemplateFromDict:dict];
                [objects addObject:ft];
                NSString *type = ft.type;
                if ([flowsArray containsObject:type]) {
                    [flowsArray removeObject:type];
                }
            }
            
            for (NSString *type in flowsArray) {
                STFlowTemplate *ft = [STFlowTemplate flowTemplateFromDict:@{@"type":type, @"url":[NSNull null]}];
                [objects addObject:ft];
            }
            completion([NSArray arrayWithArray:objects], nil);
        }
    };
    
    [STFlowImagesRequest getFlowImagesWithCompletion:completionBlock failure:^(NSError *error) {
        NSLog(@"Get flow images error: %@", error.debugDescription);
        completion(@[], error);
    }];
    
//    STFlowTemplate *ft = [STFlowTemplate flowTemplateFromDict:@{@"type":@"home", @"url":@"http://api.getstatusapp.co/media/image_55b653be33a6b_55b653be34371.jpg"}];
//    STFlowTemplate *ft1 = [STFlowTemplate flowTemplateFromDict:@{@"type":@"popular", @"url":@"http://api.getstatusapp.co/media/image_55b653be33a6b_55b653be34371.jpg"}];
//    STFlowTemplate *ft2 = [STFlowTemplate flowTemplateFromDict:@{@"type":@"nearby", @"url":@"http://api.getstatusapp.co/media/image_55b653be33a6b_55b653be34371.jpg"}];
//    STFlowTemplate *ft3 = [STFlowTemplate flowTemplateFromDict:@{@"type":@"recent", @"url":@"http://api.getstatusapp.co/media/image_55b653be33a6b_55b653be34371.jpg"}];
//    STFlowTemplate *ft4 = [STFlowTemplate flowTemplateFromDict:@{@"type":@"other", @"url":@"http://api.getstatusapp.co/media/image_55b653be33a6b_55b653be34371.jpg"}];
//
//    STFlowTemplate *ft5 = [STFlowTemplate flowTemplateFromDict:@{@"type":@"other", @"url":@"http://api.getstatusapp.co/media/image_55b653be33a6b_55b653be34371.jpg"}];
//
//    completion(@[ft, ft1, ft2, ft3, ft4, ft5], nil);
}

#pragma mark - upload Stuff to server
+(void)followUsers:(NSArray *)users
    withCompletion:(STDataUploadCompletionBlock)completion{
    if (!users || users.count == 0) {
        completion(nil);
        return;
    }
    [STFollowUsersRequest followUsers:users
                       withCompletion:^(id response, NSError *error) {
                           completion(error);
                           
                       } failure:^(NSError *error) {
                           completion(error);
                       }];
}
+(void)unfollowUsers:(NSArray *)users
    withCompletion:(STDataUploadCompletionBlock)completion{
    if (!users || users.count == 0) {
        completion(nil);
        return;
    }
    [STUnfollowUsersRequest unfollowUsers:users
                       withCompletion:^(id response, NSError *error) {
                           completion(error);
                           
                       } failure:^(NSError *error) {
                           completion(error);
                       }];
}

#pragma mark - Shop Products

+ (void)getCatalogParentEntitiesWithCompletion:(STDataAccessCompletionBlock)completion{
    [STGetCatalogParentCategoriesRequest getCatalogParentEntities:^(id response, NSError *error) {
        
        NSMutableArray *result = [@[] mutableCopy];
        for (NSDictionary *dict in response) {
            STCatalogParentCategory *pCat = [STCatalogParentCategory parentCategoryFromDict:dict];
            [result addObject:pCat];
        }
        
        NSSortDescriptor *uuidSD = [NSSortDescriptor sortDescriptorWithKey:@"uuid" ascending:YES];
        
        [result sortUsingDescriptors:@[uuidSD]];
        
        completion(result, nil);
        
    } failure:^(NSError *error) {
        completion(nil, error);
    }];
}

+ (void)getCatalogCategoriesForParentCategoryId:(NSString *) parentCategoryId
                                 withCompletion:(STDataAccessCompletionBlock)completion{
    [STGetCatalogCategoriesRequest getCatalogCategoriesForparentCategoryId:parentCategoryId
                                                     withCompletion:^(id response, NSError *error) {
                                                             NSMutableArray *result = [@[] mutableCopy];
                                                             for (NSDictionary *dict in response) {
                                                                 STCatalogCategory *category = [STCatalogCategory categoryFromDict:dict];
                                                                 [result addObject:category];
                                                             }
                                                             
                                                             completion(result, nil);

                                                     } failure:^(NSError *error) {
                                                         completion(nil, error);
                                                         
                                                     }];
}

+ (void)getUsedCatalogCategoriesWithCompletion:(STDataAccessCompletionBlock)completion{
    [STGetUsedCatalogCategoriesRequest getUsedCatalogCategoriesWithCompletion:^(id response, NSError *error) {
        NSMutableArray *result = [@[] mutableCopy];
        for (NSDictionary *dict in response) {
            STCatalogCategory *category = [STCatalogCategory categoryFromDict:dict];
            [result addObject:category];
        }
        
        completion(result, nil);
    } failure:^(NSError *error) {
        completion(nil, error);

    }];
}


+ (void)getBrandsEntitiesWithCompletion:(STDataAccessCompletionBlock)completion{
    [STGetBrandsRequest getBrandsEntities:^(id response, NSError *error) {
        
        NSMutableArray *result = [@[] mutableCopy];
        for (NSDictionary *dict in response) {
            STBrandObj *brandObj = [STBrandObj brandObjFromDict:dict];
            [result addObject:brandObj];
        }
        
        completion(result, nil);
        
    } failure:^(NSError *error) {
        completion(nil, error);
        
    }];
    
}

+ (void)getSuggestionsForCategory:(NSString *)categoryId
                         andBrand:(NSString *)brandId
                    andCompletion:(STDataAccessCompletionBlock)completion{
    [STGetSuggestionsRequest getSuggestionsEntitiesForCategory:categoryId
                                                    andBrandId:brandId
                                                 andCompletion:^(id response, NSError *error) {
                                                     
                                                     NSMutableArray *result = [@[] mutableCopy];
                                                     for (NSDictionary *dict in response) {
                                                         STShopProduct *shopObj = [STShopProduct shopProductWithDict:dict];
                                                         [result addObject:shopObj];
                                                     }
                                                     
                                                     completion(result, nil);
                                                     
                                                 } failure:^(NSError *error) {
                                                     completion(nil, error);
                                                 }];
}

+ (void)getUsedSuggestionsForCategory:(NSString *)categoryId
                    andCompletion:(STDataAccessCompletionBlock)completion{
    [STGetUsedSuggestionsRequest getUsedSuggestionsEntitiesForCategory:categoryId
                                                 andCompletion:^(id response, NSError *error) {
                                                     
                                                     NSMutableArray *result = [@[] mutableCopy];
                                                     for (NSDictionary *dict in response) {
                                                         STShopProduct *shopObj = [STShopProduct shopProductWithDict:dict];
                                                         [result addObject:shopObj];
                                                     }
                                                     
                                                     completion(result, nil);
                                                     
                                                 } failure:^(NSError *error) {
                                                     completion(nil, error);
                                                 }];
}



#pragma mark - Get Posts

+ (STRequestCompletionBlock)postsDefaultHandlerWithCompletion:(STDataAccessCompletionBlock)completion
{
    STRequestCompletionBlock responseCompletion = ^(id response, NSError *error){
        NSMutableArray *objects = [NSMutableArray new];
        if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
            id data = response[@"data"];
            NSArray *dataArray = nil;
            if ([data isKindOfClass:[NSArray class]]) {
                dataArray = [NSArray arrayWithArray:data];
            }
            else if ([data isKindOfClass:[NSDictionary class]]){
                dataArray = [NSArray arrayWithObject:data];
            }
            if (dataArray) {
                for (NSDictionary *dict in dataArray) {
                    STPost *post = [STPost postWithDict:dict];
                    [objects addObject:post];
                }
            }
            else
            {
#ifdef DEBUG
                NSAssert(NO, @"We should never get this case");
#endif
            }
        }
        completion(objects, error);
    };
    return responseCompletion;
}

+ (STRequestFailureBlock)postsDefaultErrorHandlerWithCompletion:(STDataAccessCompletionBlock)completion
{
    STRequestFailureBlock failBlock = ^(NSError *error){
        NSLog(@"error with %@", error.debugDescription);
        completion(@[], error);
    };
    return failBlock;
}

+(void)getPostsForFlow:(STFlowType)flowType
                offset:(NSInteger)offset
        withCompletion:(STDataAccessCompletionBlock)completion{
    STRequestCompletionBlock responseCompletion = [self postsDefaultHandlerWithCompletion:completion];
    STRequestFailureBlock failBlock = [self postsDefaultErrorHandlerWithCompletion:completion];
    [STGetPostsRequest getPostsWithOffset:offset
                                 flowType:flowType
                           withCompletion:responseCompletion
                                  failure:failBlock];

}

+ (STRequestCompletionBlock)nearbyPostsHandlerWithCompletion:(STDataAccessCompletionBlock)completion
{
    STRequestCompletionBlock responseCompletion = ^(id response, NSError *error){
        NSMutableArray *objects = [NSMutableArray new];
        if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
            for (NSDictionary *dict in response[@"data"]) {
            
                STUserProfile *up = [STUserProfile userProfileWithDict:dict];
                [objects addObject:up];
            }
            completion(objects, error);
        }
        else if ([response[@"status_code"] integerValue] == 404){
            completion(objects, [NSError errorWithDomain:@"LOCATION_MISSING_ERROR" code:404 userInfo:nil]);
        }
        else
            completion(objects, error);
    };
    return responseCompletion;
}

+(void)getNearbyPostsWithOffset:(NSInteger)offset
                 withCompletion:(STDataAccessCompletionBlock)completion{
    STRequestCompletionBlock responseCompletion = [self nearbyPostsHandlerWithCompletion:completion];
    STRequestFailureBlock failBlock = [self postsDefaultErrorHandlerWithCompletion:completion];
    [STGetNearbyProfilesRequest getNearbyProfilesWithOffset:offset
                                             withCompletion:responseCompletion
                                                    failure:failBlock];
    
}

+(void)getPostsForUserId:(NSString *)userId
                offset:(NSInteger)offset
        withCompletion:(STDataAccessCompletionBlock)completion{
    STRequestCompletionBlock responseCompletion = [self postsDefaultHandlerWithCompletion:completion];
    STRequestFailureBlock failBlock = [self postsDefaultErrorHandlerWithCompletion:completion];
    [STGetUserPostsRequest getPostsForUser:userId
                                withOffset:offset
                            withCompletion:responseCompletion
                                   failure:failBlock];
}

+(void)getPostWithPostId:(NSString *)postId
          withCompletion:(STDataAccessCompletionBlock)completion{
    STRequestCompletionBlock responseCompletion = [self postsDefaultHandlerWithCompletion:completion];
    STRequestFailureBlock failBlock = [self postsDefaultErrorHandlerWithCompletion:completion];
    [STGetPostDetailsRequest getPostDetails:postId
                             withCompletion:responseCompletion
                                    failure:failBlock];
}

+(void)setPostSeenForPostId:(NSString *)postId
      withCompletion:(STDataUploadCompletionBlock)completion{
    [STSetPostSeenRequest setPostSeen:postId
                       withCompletion:^(id response, NSError *error) {
                           if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
                               completion(nil);
                           }
                           else
                               completion([NSError errorWithDomain:@"INTERNAL_ERROR" code:110011 userInfo:nil]);
                       } failure:^(NSError *error) {
                           completion(error);
                       }];
}

+ (void)setPostLikeUnlikeWithPostId:(NSString *)postId
                     withCompletion:(STDataUploadCompletionBlock)completion{
    STRequestCompletionBlock completion1 = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            [STDataAccessUtils getPostWithPostId:postId withCompletion:^(NSArray *objects, NSError *error) {
                if (!error) {
                    [[CoreManager postsPool] addPosts:objects];
                    completion(nil);
                }
                else
                    completion(error);
            }];
        }
    };
    
    STRequestFailureBlock failBlock = ^(NSError *error){
        completion(error);
    };
    
    [STSetPostLikeRequest setPostLikeForPostId:postId
                                withCompletion:completion1
                                       failure:failBlock];
}

+ (void)deletePostWithId:(NSString *)postId
          withCompletion:(STDataUploadCompletionBlock)completion{
    STRequestCompletionBlock completion1 = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue] ==STWebservicesSuccesCod) {
            [[CoreManager postsPool] removePostsWithIDs:@[postId]];
            completion(nil);
        }
        else
            completion(error);
    };
    
    STRequestFailureBlock failBlock = ^(NSError *error){
        completion(error);
    };

    [STDeletePostRequest deletePost:postId
                     withCompletion:completion1
                            failure:failBlock];

}
+ (void)reportPostWithId:(NSString *)postId
          withCompletion:(STDataUploadCompletionBlock)completion{
    STRequestCompletionBlock completion1 = ^(id response, NSError *error){
        NSString *message = nil;
        NSString *title = @"Report Post";
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            message = @"A message was sent to the admin.";
        }
        else
        {
            message = @"This post was already reported.";
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        
        [[CoreManager navigationService] presentAlertController:alert];
        completion(nil);
    };
    
    STRequestFailureBlock failBlock = ^(NSError *error){
        completion(error);
    };

    
    [STRepostPostRequest reportPostWithId:postId
                           withCompletion:completion1
                                  failure:failBlock];

}

+ (void)updatePostWithId:(NSString *)postId
          withNewCaption:(NSString *)newCaption
          withCompletion:(STDataUploadCompletionBlock)completion{
    [STUpdatePostCaptionRequest setPostCaption:newCaption
                                     forPostId:postId
                                withCompletion:^(id response, NSError *error) {
                                    if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                                        STPost *post = [[CoreManager postsPool] getPostWithId:postId];
                                        post.caption = newCaption;
                                        [[CoreManager postsPool] addPosts:@[post]];
                                        completion(nil);
                                    }
                                    else{
                                        completion([NSError errorWithDomain:@"com.status.error" code:11011 userInfo:nil]);
                                    }
                                } failure:^(NSError *error) {
                                    NSLog(@"Error: %@", error.debugDescription);
                                    completion(error);
                                }];

}

+ (void)editPpostWithId:(NSString *)postId
           withNewImageData:(NSData *)imageData
         withNewCaption:(NSString *)newCaption
       withShopProducts:(NSArray <STShopProduct *> *) shopProducts
         withCompletion:(STDataAccessCompletionBlock)completion{

    //check if all the shop products have a valid uuid
    //if not, upload all the shop_products, obtain an id and then upload the post
    STRequestCompletionBlock completion1 = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            
            [[CoreManager localNotificationService] postNotificationName:STHomeFlowShouldBeReloadedNotification object:nil userInfo:nil];
            
            NSString * postUuid = postId;
            if(postId == nil)
                postUuid = response[@"post_id"];
            
            [STDataAccessUtils getPostWithPostId:postUuid
                                  withCompletion:^(NSArray *objects, NSError *error) {
                                      if (!error) {
                                          [[CoreManager postsPool] addPosts:objects];
                                          completion(objects, nil);
                                      }
                                      else
                                          completion(nil, error);
                                  }];
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Something went wrong. You can try again later." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [[CoreManager navigationService] presentAlertController:alert];
            completion(nil,[NSError errorWithDomain:@"com.status.error" code:11011 userInfo:nil]);
            
        }
    };
    
    STRequestFailureBlock failBlock = ^(NSError *error){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Something went wrong. You can try again later." preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [[CoreManager navigationService] presentAlertController:alert];
        completion(nil,error);
    };

    
    shopProductsCompletion shopProductCompletion = ^(NSArray<STShopProduct *> *shopProds, ShopProductsUploadStatus status) {
        if (status == ShopProductsUploadStatusComplete) {
            [STUploadPostRequest uploadPostForId:postId
                                        withData:imageData
                                      andCaption:newCaption
                                    shopProducts:shopProds
                                  withCompletion:completion1
                                         failure:failBlock];
        }
        else
            failBlock([NSError errorWithDomain:@"com.status.prerequisite" code:10001 userInfo:nil]);
    };
    
    [[STShopProductsUploader new] uploadShopProducts:shopProducts
                                      withCompletion:shopProductCompletion];

    

}

+ (void)inviteUserToUpload:(NSString *)userID
              withUserName:(NSString *)userName
withCompletion:(STDataUploadCompletionBlock)completion{
    STRequestCompletionBlock completion1 = ^(id response, NSError *error){
        NSInteger statusCode = [response[@"status_code"] integerValue];
        if (statusCode ==STWebservicesSuccesCod || statusCode == STWebservicesFounded) {
            NSString *message = [NSString stringWithFormat:@"Congrats, you%@ asked %@ to take a photo. We'll announce you when the new photo is on STATUS.",statusCode == STWebservicesSuccesCod?@"":@" already", userName];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                                           message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [[CoreManager navigationService] presentAlertController:alert];
            completion(nil);
        }
        else
            completion([NSError errorWithDomain:@"com.status.error" code:11011 userInfo:nil]);
    };
    [STInviteUserToUploadRequest inviteUserToUpload:userID withCompletion:completion1 failure:^(NSError *error) {
        completion(error);
    }];
}

#pragma mark - Notifications

+ (void)getNotificationsWithCompletion:(STDataAccessCompletionBlock)completion{
    STRequestCompletionBlock completion1 = ^(id response, NSError *error){
        if ([response[@"status_code"] integerValue]==STWebservicesSuccesCod) {
            
            NSMutableArray *objects = [NSMutableArray new];
            for (NSDictionary *dict in response[@"data"]) {
                STNotificationObj *no = [STNotificationObj notificationObjFromDict:dict];
                [objects addObject:no];
            }
            completion(objects, nil);
        }
        else
            completion(nil, [NSError errorWithDomain:@"com.status.error" code:11011 userInfo:nil]);
    };
    STRequestFailureBlock failBlock = ^(NSError *error){
        completion(nil, error);
    };
    
    [STGetNotificationsRequest getNotificationsWithCompletion:completion1 failure:failBlock];

}

#pragma mark - UserProfile

+ (void)getUserProfileForUserId:(NSString *)userId
                  andCompletion:(STDataAccessCompletionBlock)completion{
//    STRequestCompletionBlock responseCompletion = [self nearbyPostsHandlerWithCompletion:completion];
    STRequestFailureBlock failBlock = [self postsDefaultErrorHandlerWithCompletion:completion];
    [STGetUserProfileRequest getProfileForUserID:userId
                                  withCompletion:^(id response, NSError *error) {
                                      NSMutableArray *objects = [NSMutableArray new];
                                      if ([response[@"status_code"] integerValue] == STWebservicesSuccesCod) {
                                          STUserProfile *up = [STUserProfile userProfileWithDict:response];
                                          [objects addObject:up];

                                          completion(objects, error);
                                      }
                                  }failure:failBlock];

}

#pragma mark - Commissions
+ (void)getUserCommissionsWithCompletion:(STDataAccessCompletionBlock)completion{
    STRequestFailureBlock failBlock = [self postsDefaultErrorHandlerWithCompletion:completion];
    [STUserCommissionsRequest getUserCommissionsWithCompletion:^(id response, NSError *error) {
        NSMutableArray *objects = [NSMutableArray new];
        if (!error) {
            //TODO: check response structure
            NSMutableArray *mockResponse = [NSMutableArray new];
            NSDictionary *commissionDict1 = @{@"id": @"10",
                                              @"product_image":@"https://p1.akcdn.net/full/140807607.calvin-klein-ck-collection-tricou-negru-logo-alb.jpg",
                                              @"product_name":@"Logo T-shirt",
                                              @"product_brand_name":@"CK Jeans",
                                              @"commission_date":@"2017-05-09",
                                              @"commission_state":@"paid",
                                              @"commission_ammount": @(10.30)};
            
            NSDictionary *commissionDict2 = @{@"id": @"11",
                                              @"product_image":@"http://www.tricouri-brand.com/image/cache/catalog/Tricouri/3-600x600.jpg",
                                              @"product_name":@"Logo T-shirt",
                                              @"product_brand_name":@"CK Jeans",
                                              @"commission_date":@"2017-05-10",
                                              @"commission_state":@"paid",
                                              @"commission_ammount": @(6.28)};
            
            NSDictionary *commissionDict3 = @{@"id": @"12",
                                              @"product_image":@"http://www.kosh.ro/3273697220-3305-thickbox_default/tricou-dama-calvin-klein.jpg",
                                              @"product_name":@"Fitted Floral Logo T-shirt",
                                              @"product_brand_name":@"CK Jeans",
                                              @"commission_date":@"2017-05-12",
                                              @"commission_state":@"paid",
                                              @"commission_ammount": @(5.95)};
            
            NSDictionary *commissionDict4 = @{@"id": @"13",
                                              @"product_image":@"http://www.tricouri-brand.com/image/cache/catalog/Tricouri/3-600x600.jpg",
                                              @"product_name":@"Logo T-shirt",
                                              @"product_brand_name":@"CK Jeans",
                                              @"commission_date":@"2017-05-15",
                                              @"commission_state":@"withdrawn",
                                              @"commission_ammount": @(16.29)};
            
            NSDictionary *commissionDict5 = @{@"id": @"14",
                                              @"product_image":@"https://p1.akcdn.net/full/140807607.calvin-klein-ck-collection-tricou-negru-logo-alb.jpg",
                                              @"product_name":@"Logo T-shirt",
                                              @"product_brand_name":@"CK Jeans",
                                              @"commission_date":@"2017-05-19",
                                              @"commission_state":[NSNull null],
                                              @"commission_ammount": @(29.37)};
            
            NSDictionary *commissionDict6 = @{@"id": @"15",
                                              @"product_image":@"http://www.kosh.ro/3273697220-3305-thickbox_default/tricou-dama-calvin-klein.jpg",
                                              @"product_name":@"Fitted Floral Logo T-shirt",
                                              @"product_brand_name":@"CK Jeans",
                                              @"commission_date":@"2017-05-22",
                                              @"commission_state":[NSNull null],
                                              @"commission_ammount": @(75.91)};

            [mockResponse addObject:commissionDict1];
            [mockResponse addObject:commissionDict2];
            [mockResponse addObject:commissionDict3];
            [mockResponse addObject:commissionDict4];
            [mockResponse addObject:commissionDict5];
            [mockResponse addObject:commissionDict6];

            //TODO: change it to the server response
            for (NSDictionary *dict in mockResponse) {
                STCommission *commision = [STCommission commissionsObjWithDict:dict];
                [objects addObject:commision];
            }
        }
        completion (objects, error);
        
    } failure:failBlock];
}
+ (void)withdrawCommissionsWithCompletion:(STDataUploadCompletionBlock)completion{
    [STUserCommissionsRequest withdrawnUserCommissionsWithCompletion:^(id response, NSError *error) {
        //TODO: check response structure
        completion(error);
        
    } failure:^(NSError *error) {
        completion(error);
    }];
}

#pragma mark - User Withdraw Details
+ (void)getUserWithdrawDetailsWithCompletion:(STDataAccessCompletionBlock)completion{
    STRequestFailureBlock failBlock = [self postsDefaultErrorHandlerWithCompletion:completion];
    [STUserWithDrawnDetailsRequest getUserWithdrawnDetailsWithCompletion:^(id response, NSError *error) {
        //TODO: check response structure
        STWithdrawDetailsObj *withdrawDetailsObj = nil;
        
        if (!error && [response count]) {
            withdrawDetailsObj = [STWithdrawDetailsObj withdrawDetailsObjWithDictionary:response];

        }
        
        if (!withdrawDetailsObj) {
            withdrawDetailsObj = [STWithdrawDetailsObj new];
//            withdrawDetailsObj.firstname = @"Andrus";
//            withdrawDetailsObj.lastname = @"Cosmin-Adelin";
//            withdrawDetailsObj.email = @"andrus.cosmin@yahoo.com";
//            withdrawDetailsObj.phone_number = @"0765510112";
//            withdrawDetailsObj.company = @"Andrus SRL";
//            withdrawDetailsObj.vat_number = @"13567864";
//            withdrawDetailsObj.register_number = @"437584-AC";
//            withdrawDetailsObj.country = @"Romania";
//            withdrawDetailsObj.city = @"Bucharest";
//            withdrawDetailsObj.address = @"intr.Ciulin, nr.6, Berceni";
//            withdrawDetailsObj.iban = @"RO34INGB000023628273";
        }
        
        if (withdrawDetailsObj) {
            completion(@[withdrawDetailsObj], error);
        }
        else
            completion(@[], error);
    } failure:failBlock];
}
+ (void)postUserWithdrawDetails:(STWithdrawDetailsObj *)withdrawObj
                 withCompletion:(STDataUploadCompletionBlock)completion{
    [STUserWithDrawnDetailsRequest postUserWithdrawnDetails:withdrawObj
                                             withCompletion:^(id response, NSError *error) {
                                                 //TODO: check response structure
                                                 completion(error);
                                             } failure:^(NSError *error) {
                                                 completion(error);
                                             }];
}


@end
