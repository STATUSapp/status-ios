//
//  STTagProductsEmptyWardrobe.h
//  Status
//
//  Created by Cosmin Andrus on 05/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STTagProductsEmptyWardrobeProtocol <NSObject>

-(void)wizzardOptionSelected;
-(void)manualOptionSelected;

@end

@interface STTagProductsEmptyWardrobe : UIViewController

@property (nonatomic, weak) id<STTagProductsEmptyWardrobeProtocol>delegate;

@end
