//
//  STNearbyCollectionLayout.h
//  Status
//
//  Created by Cosmin Andrus on 01/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STNearbyLayoutDelegate <NSObject>

-(CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface STNearbyCollectionLayout : UICollectionViewLayout

@property (nonatomic, weak) id<STNearbyLayoutDelegate>delegate;
@property (nonatomic, assign) NSInteger numberOfColumns;
@property (nonatomic, assign) CGFloat cellPadding;
@property (nonatomic, assign) BOOL newDataAvailable;

@end
