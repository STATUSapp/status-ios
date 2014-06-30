//
//  STTutorial.h
//  Status
//
//  Created by Silviu on 01/05/14.
//  Copyright (c) 2014 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STTutorialDelegate <NSObject>

-(void)tutorialDidDissmiss;

@end

@interface STTutorialViewController : UICollectionViewController

@property (nonatomic, strong) UIImage * backgroundImageForLastElement;
@property (nonatomic, weak) id <STTutorialDelegate> delegate;
+ (STTutorialViewController *)newInstance;

@end
