//
//  STMissingProductTVCTableViewController.h
//  Status
//
//  Created by Cosmin Andrus on 24/10/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STProductNotIndexedTVCProtocol <NSObject>

-(void)missingProductTVCDidCancel;

@end

@interface STMissingProductTVCTableViewController : UITableViewController

@property (nonatomic, weak) id<STProductNotIndexedTVCProtocol>delegate;

-(BOOL)validate;
-(NSString *)brandName;
-(NSString *)productName;
-(NSString *)productURL;
-(void)invalidateFields;

@end
