//
//  JBWhatsAppActivity.m
//  DemoProject
//
//  Created by Javier Berlana on 19/07/13.
//  Copyright (c) 2013 Sweetbits. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this
//  software and associated documentation files (the "Software"), to deal in the Software
//  without restriction, including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons
//  to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies
//  or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
//  PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
//  FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

#import "STWhatsAppActivity.h"
#import "STInviteController.h"

@implementation STWhatsAppActivity

- (NSString *)activityType {
    return @"ro.status.WHATSAPP";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"whatsapp"];
}

- (NSString *)activityTitle
{
    return @"WhatsApp";
}

- (NSURL *)getURLFromString:(NSString *)message
{
    NSString *url = @"whatsapp://";
    
    if (message)
    {
        url = [NSString stringWithFormat:@"%@send?text=%@",url,[message stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    }
    
    return [NSURL URLWithString:url];
}

-(NSString *)getStringFromActivities:(NSArray *)activityItems{
    NSString *resultString = @"";
    for (id activityItem in activityItems)
    {
        if ([activityItem isKindOfClass:[NSString class]])
        {
            resultString = [resultString stringByAppendingFormat:@" %@",activityItem];
        }
    }
    return resultString;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSString *shareString = [self getStringFromActivities:activityItems];
    NSURL *whatsAppURL = [self getURLFromString:shareString];
    return [[UIApplication sharedApplication] canOpenURL: whatsAppURL];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSString *shareString = [self getStringFromActivities:activityItems];
    NSURL *whatsAppURL = [self getURLFromString:shareString];
    if ([[UIApplication sharedApplication] canOpenURL: whatsAppURL]) {
        [[UIApplication sharedApplication] openURL: whatsAppURL];
    }    
}

-(void)activityDidFinish:(BOOL)completed{
    [[STInviteController sharedInstance] setCurrentDateForSelectedItem];
}

@end
