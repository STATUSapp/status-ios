//
//  STTopCell.m
//  Status
//
//  Created by Cosmin Andrus on 15/07/2018.
//  Copyright © 2018 Andrus Cosmin. All rights reserved.
//

#import "STTopCell.h"
#import "STTopBase.h"
#import "UILabel+TopRanking.h"

@interface STTopCell ()
@property (weak, nonatomic) IBOutlet UILabel *topBadge;
@property (weak, nonatomic) IBOutlet UILabel *topDetail;

@end

@implementation STTopCell

- (void) configureWithTop:(STTopBase *)top{
    [self.topBadge configureWithTop:top];
    [self.topDetail setAttributedText:[top topDetails]];
}

+ (CGSize)cellSize{
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    return CGSizeMake(screenSize.width, 37.f);
}
@end
