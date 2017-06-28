//
//  STSnackBar.h
//  Status
//
//  Created by Cosmin Andrus on 27/06/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STSnackBar : UIView

+ (STSnackBar *)snackBarWithOwner:(id)owner;
-(void)configureWithMessage:(NSString *)message;

@end
