//
//  STTutorialViewController.h
//  Status
//
//  Created by Cosmin Andrus on 11/02/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STTutorialDelegate <NSObject>

- (void)loginButtonPressed:(id)sender;
- (void)multipleTapOnShopStyle;
@end

@interface STTutorialViewController : UIViewController
@property (nonatomic, weak) id <STTutorialDelegate> delegate;
@property (nonatomic) BOOL skipFirstItem;
@end
