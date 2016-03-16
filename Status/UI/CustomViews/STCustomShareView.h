//
//  STCustomShareView.h
//  Status
//
//  Created by Andrus Cosmin on 04/03/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCustomShareView : UIView

+(void)presentViewForPostId:(NSString *)postUuid
         withExtendedRights:(BOOL)extendedRights;
+(void)dismissView;

@end
