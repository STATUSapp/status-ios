//
//  STSuggestionsViewController.h
//  Status
//
//  Created by Cosmin Adelin Andrus on 17/05/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STRequests.h"


@interface STSuggestionsViewController : UIViewController

@property (nonatomic) STFollowType followType;
+(UINavigationController *)instatiateWithFollowType:(STFollowType)followType;

@end
