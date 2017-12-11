//
//  STSnackWithActionBar.h
//  Status
//
//  Created by Cosmin Andrus on 03/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface STSnackWithActionBar : UIView

+(STSnackWithActionBar *)snackBarWithActionWithOwner:(id)owner
                                           andAction:(SEL)action;
-(void)configureWithMessage:(NSString *)messageString
                  andAction:(NSString *)actionString
;
@end
