//
//  STFacebookAddCell.h
//  Status
//
//  Created by Cosmin Andrus on 09/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class STAdPost;

@interface STFacebookAddCell : UICollectionViewCell

-(void)configureWithAdPost:(STAdPost *)adPost;
+(CGSize)cellSizeWithAdPost:(STAdPost *)adPost;
@end
