//
//  STCustomShareView.h
//  Status
//
//  Created by Andrus Cosmin on 04/03/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STContextualMenuDelegate <NSObject>
@required
- (void)contextualMenuReportPost;
- (void)contextualMenuDeletePost;
- (void)contextualMenuEditPost;
- (void)contextualMenuMoveAndScalePost;
- (void)contextualMenuSavePostLocally;
- (void)contextualMenuSharePostonFacebook;
- (void)contextualMenuAskUserToUpload;
- (void)contextualMenuCopyShareUrl;
- (void)contextualMenuCopyProfileUrl;

@end

@interface STContextualMenu : UIView

+(void)presentViewWithDelegate:(id<STContextualMenuDelegate>)delegate
            withExtendedRights:(BOOL)extendedRights;
+(void)presentProfileViewWithDelegate:(id<STContextualMenuDelegate>)delegate;
+(void)dismissView;

@end
