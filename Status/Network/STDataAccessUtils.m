//
//  STDataAccessUtils.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STDataAccessUtils.h"
#import "STDataModelObjects.h"
#import "STGetFollowersRequest.h"
#import "STGetFollowingRequest.h"

@implementation STDataAccessUtils
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
                STListUser *lu = [STListUser likeUserWithDict:dict];
                [objects addObject:lu];
            }
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
                STListUser *lu = [STListUser likeUserWithDict:dict];
                [objects addObject:lu];
            }
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
                STListUser *lu = [STListUser likeUserWithDict:dict];
                [objects addObject:lu];
            }
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
@end
