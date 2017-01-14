//
//  STInviteFriendsByEmailRequest.m
//  Status
//
//  Created by Cosmin Adelin Andrus on 27/09/15.
//  Copyright © 2015 Andrus Cosmin. All rights reserved.
//

#import "STInviteFriendsByEmailRequest.h"

@implementation STInviteFriendsByEmailRequest
- (void)inviteFriends:(NSArray *)friends
       withCompletion:(STRequestCompletionBlock)completion{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    NSString *fullUrl = [NSString stringWithFormat:@"%@%@", kBaseURL, kInviteFriendsByEmail];
    NSURL *url = [NSURL URLWithString:fullUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:30.0];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [request setHTTPMethod:@"POST"];
    NSMutableDictionary *params = [self getDictParamsWithToken];
    params[@"friends"] = friends ;

    [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
    
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"dataAsString %@", [NSString stringWithUTF8String:[data bytes]]);
        
        NSError *error1;
        NSMutableDictionary * receivedJson = [NSJSONSerialization
                                           JSONObjectWithData:data
                                           options:kNilOptions
                                           error:&error1];
        completion(receivedJson, error);
        
    }];
    
    [postDataTask resume];
}

- (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary
{
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        NSString *keyValueString = @"";
        if ([obj isKindOfClass:[NSString class]]) {
            keyValueString = obj;
        }
        else if ([obj isKindOfClass:[NSDictionary class]] ||
                 [obj isKindOfClass:[NSArray class]]){
            NSData *dictData = [NSJSONSerialization dataWithJSONObject:obj options:NSJSONWritingPrettyPrinted error:nil];
            keyValueString = [[NSString alloc] initWithData:dictData encoding:NSUTF8StringEncoding];
        }
        NSString *escapedString = [keyValueString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

        NSString *param = [NSString stringWithFormat:@"%@=%@", key, escapedString];
        [parameterArray addObject:param];
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}
@end
