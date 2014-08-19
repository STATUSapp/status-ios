//
//  STWebServiceController.h
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "STConstants.h"

typedef void (^successCompletion)(NSDictionary *response);
typedef void (^errorCompletion) (NSError *error);
typedef void (^downloadImageCompletion) (NSURL *imageURL);
@interface STWebServiceController : NSObject
@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, assign) BOOL isPerformLoginOrRegistration;
+(STWebServiceController *) sharedInstance;
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
-(void) getPostsWithOffset:(long) offest withCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion;
-(void) downloadImage:(NSString *) imageFullLink storedName:(NSString *)storedName withCompletion:(downloadImageCompletion) completion;
-(void) loginUserWithInfo:(NSDictionary *) info withCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion;
-(void) registerUserWithInfo:(NSDictionary *) info withCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion;
-(void) getUserProfilePictureFromFacebook:(NSString *) userID WithCompletion:(successCompletion) completion;
-(void) uploadPictureWithData:(NSData *) imageData withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion;
-(void) setPostLiked:(NSString *) postId withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion;
-(void) setReportStatus:(NSString *) postId withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion;
-(void) getUserPosts:(NSString *) userId withOffset:(long) offset completion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion;
-(void) setPostSeen:(NSString *) postId withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion;
-(void) getPostLikes:(NSString *) postID withCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion;
-(void) setAPNToken:(NSString *) apn_token withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion;
-(void) getPostDetails:(NSString *) postID withCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion;
-(void) getNotificationsWithCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion;
-(void) getUnreadNotificationsCountWithCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion;
-(void) deletePost:(NSString *) post_id withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion;
-(void) inviteUserToUpload:(NSString *) userId withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion;
-(void) setUserLocationWithCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion;
-(void) getNearbyPostsWithOffset:(long) offset completion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion;
-(void) getUsersForScope:(STSearchScopeControl)scope withSearchText:(NSString *)searchText withOffset:(long) offset completion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion;
-(void) getUserInfo:(NSString*)userId wirhCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion;
@end
