//
//  STSnackBarBaseService.h
//  Status
//
//  Created by Cosmin Andrus on 10/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STSnackBarBaseService : NSObject

@property (nonatomic, strong, readonly) UIView *snackBar;
@property (nonatomic, assign, readonly) BOOL snackBarOnScreen;
@property (nonatomic, strong, readonly) NSTimer *timer;

-(void)setupTimer;
-(void)hideSnackBar;

@end
