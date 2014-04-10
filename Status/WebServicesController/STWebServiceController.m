//
//  STWebServiceController.m
//  Status
//
//  Created by Andrus Cosmin on 16/02/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import "STWebServiceController.h"
#import "STConstants.h"
#import "STImageCacheController.h"
#import "AFHTTPRequestOperationManager.h"

@implementation STWebServiceController
+(STWebServiceController *) sharedInstance{
    static STWebServiceController *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _sharedManager = [[self alloc] init];
        _sharedManager.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL] sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        NSArray *responseSerializers = @[[AFJSONResponseSerializer serializer], [AFHTTPResponseSerializer serializer]];
        [_sharedManager.sessionManager setResponseSerializer:[AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers]];
        //_sharedManager.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedManager.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [_sharedManager.sessionManager.requestSerializer setValue:@"Accept" forHTTPHeaderField:@"application/json"];
        [_sharedManager.sessionManager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
        _sharedManager.isPerformLoginOrRegistration=FALSE;
        
        });
    
    return _sharedManager;
}

- (NSError*)translateToHTTPError:(NSURLSessionDataTask *)task error:(NSError *)error
{
    NSInteger statusCode = ((NSHTTPURLResponse*)task.response).statusCode;
    if (error.code == NSURLErrorCancelled) { //cancelled
        statusCode = NSURLErrorCancelled;
    }
    
    NSError *err = [NSError errorWithDomain:error.domain
                                       code:statusCode
                                   userInfo:error.userInfo];
    return err;
}

-(void) getPostsWithOffset:(long) offest withCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion{
    long limit = 50;
#if PAGGING_ENABLED
    limit = POSTS_PAGGING;
#endif
    [self.sessionManager GET:kGetPosts parameters:@{@"limit": @(limit), @"offset":@(offest), @"token":self.accessToken,@"test_param":@"test-value"} success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
        errorCompletion(error);
    }];
    
}

-(void) downloadImage:(NSString *) imageFullLink withCompletion:(downloadImageCompletion) completion{
    
    if ([imageFullLink isKindOfClass:[NSNull class]]) {
        imageFullLink = nil;
    }
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *downloadURL = [NSURL URLWithString:[imageFullLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];

    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSError *error = nil;
        NSURL *documentsDirectoryPath = [NSURL fileURLWithPath:[[STImageCacheController sharedInstance] getImageCachePath]];
        [documentsDirectoryPath setResourceValue:[NSNumber numberWithBool:YES]
                                          forKey:NSURLIsExcludedFromBackupKey error:&error];
        return [documentsDirectoryPath URLByAppendingPathComponent:[imageFullLink lastPathComponent]];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        completion(filePath);
    }];
    [downloadTask resume];
    
}

-(void) loginUserWithInfo:(NSDictionary *) info withCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion{
    [self.sessionManager POST:kLoginUser parameters:info success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
        errorCompletion(error);
    }];
}

-(void) registerUserWithInfo:(NSDictionary *) info withCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion{
    [self.sessionManager POST:kRegisterUser parameters:info success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
        errorCompletion(error);
    }];
}

-(void) getUserProfilePictureFromFacebook:(NSString *) userID WithCompletion:(successCompletion) completion{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *downloadURL = [NSURL URLWithString:[[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", userID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        
        completion(responseObject);
    }];
    
    [dataTask resume];
    
}

-(void) uploadPictureWithData:(NSData *) imageData withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion{

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];

    AFHTTPRequestOperation *op = [manager POST:kPostPhoto parameters:@{@"token":self.accessToken} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"image" fileName:@"image.jpg" mimeType:@"image/jpg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completion(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@ ", operation.responseString);
        errorCompletion(error);
    }];
    [op start];
    
}

-(void) setPostLiked:(NSString *) postId withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion{
    [self.sessionManager POST:kSetPostLiked parameters:@{@"post_id":postId, @"token":self.accessToken} success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
        errorCompletion(error);
    }];
}

-(void) setReportStatus:(NSString *) postId withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion{
    [self.sessionManager POST:kReport_Post parameters:@{@"post_id":postId, @"token":self.accessToken} success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
        errorCompletion(error);
    }];
}

-(void) getUserPosts:(NSString *) userId withOffset:(long) offset completion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion{
    long limit = 50;
#if PAGGING_ENABLED
    limit = POSTS_PAGGING;
#endif
    [self.sessionManager GET:kGetUserPosts parameters:@{@"limit": @(limit), @"offset":@(offset), @"token":self.accessToken,@"user_id":userId} success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
        errorCompletion(error);
    }];
}

-(void) setPostSeen:(NSString *) postId withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion{
    //__weak STWebServiceController *weakSelf = self;
    NSLog(@"Send set_seen to post id : %@", postId);
    [self.sessionManager POST:kSetPostSeen parameters:@{@"post_id":postId, @"token":self.accessToken} success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        errorCompletion(error);
    }];
}

-(void) getPostLikes:(NSString *) postID withCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion{
    [self.sessionManager GET:kGetPostLikes parameters:@{@"post_id": postID, @"token":self.accessToken} success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
        errorCompletion(error);
    }];
}

-(void) setAPNToken:(NSString *) apn_token withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion{
    [self.sessionManager POST:kSetApnToken parameters:@{@"apn_token":apn_token, @"token":self.accessToken} success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
        errorCompletion(error);
    }];
}

-(void) getPostDetails:(NSString *) postID withCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion{
    [self.sessionManager GET:kGetPost parameters:@{@"post_id": postID, @"token":self.accessToken} success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
        errorCompletion(error);
    }];
}
-(void) getNotificationsWithCompletion:(successCompletion) completion andErrorCompletion:(errorCompletion) errorCompletion{
    [self.sessionManager GET:kGetNotifications parameters:@{@"token":self.accessToken} success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
        errorCompletion(error);
    }];
}

-(void) deletePost:(NSString *) post_id withCompletion:(successCompletion) completion orError:(errorCompletion) errorCompletion{
    [self.sessionManager POST:kDeletePost parameters:@{@"post_id":post_id, @"token":self.accessToken} success:^(NSURLSessionDataTask *task, id responseObject) {
        /*NSDictionary *responseDict = [NSJSONSerialization
                                      JSONObjectWithData:responseObject
                                      options:NSJSONReadingMutableLeaves
                                      error:nil];*/
        completion(responseObject);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"Error: %@", error.debugDescription);
        errorCompletion(error);
    }];
}

@end
