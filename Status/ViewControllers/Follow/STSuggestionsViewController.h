//
//  STSuggestionsViewController.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STRequests.h"

@protocol STSuggestionsDelegate <NSObject>

-(void)userDidEndApplyingSugegstions;

@end

@interface STSuggestionsViewController : UIViewController
@property (nonatomic, weak) id <STSuggestionsDelegate>delegate;
@property (nonatomic) STFollowType followType;
+(STSuggestionsViewController *)instatiateWithDelegate:(id)delegate
                                         andFollowTyep:(STFollowType)followType;
@end
