//
//  STWhiteNavBarViewController.h
//  Status
//
//  Created by Cosmin Andrus on 19/05/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STWhiteNavBarViewController : UIViewController

-(void)setNavigationTitle:(NSString *)title;

//hook methods
-(BOOL)shouldHideLeftButton;
@end
