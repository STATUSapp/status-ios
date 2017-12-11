//
//  STSnackBarBaseService+Subclass.h
//  Status
//
//  Created by Cosmin Andrus on 10/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STSnackBarBaseService.h"

@interface STSnackBarBaseService ()

@property (nonatomic, strong, readwrite) UIView *snackBar;
@property (nonatomic, assign, readwrite) BOOL snackBarOnScreen;
@property (nonatomic, strong, readwrite) NSTimer *timer;

@end
