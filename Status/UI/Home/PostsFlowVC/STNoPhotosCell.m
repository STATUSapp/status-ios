//
//  STNoPhotosCell.m
//  Status
//
//  Created by Cosmin Andrus on 02/02/15.
//  Copyright (c) 2015 Andrus Cosmin. All rights reserved.
//

#import "STNoPhotosCell.h"
#import "STPost.h"

@interface STNoPhotosCell()
@property (weak, nonatomic) IBOutlet UIButton *profileNameBtn;
@property (weak, nonatomic) IBOutlet UILabel *noPhotosLabel;

@end

@implementation STNoPhotosCell

-(void)setUpCellWithUserName:(NSString *)userName andFlow:(STFlowType)flowType{
    [self.profileNameBtn setTitle:[NSString stringWithFormat:@"%@ Profile ", userName] forState:UIControlStateNormal];
    
    switch (flowType) {
        case STFlowTypeMyGallery:{
            self.noPhotosLabel.text = @"You don't have any photo. Take a photo";
            break;
        }
        case STFlowTypeUserGallery:{
            self.noPhotosLabel.text = [NSString stringWithFormat:@"Ask %@ to take a photo", userName];
            break;
        }
        default:
            break;
    }
}

-(void)configureWithUserName:(NSString *)userName
            isTheCurrentUser:(BOOL)isOwner{
    [self.profileNameBtn setTitle:[NSString stringWithFormat:@"%@ Profile ", userName] forState:UIControlStateNormal];
    
    if (isOwner) {
        self.noPhotosLabel.text = @"You don't have any photo. Take a photo";
    }
    else
        self.noPhotosLabel.text = [NSString stringWithFormat:@"Ask %@ to take a photo", userName];
}

- (NSString *)reuseIdentifier{
    return @"STNoPhotosCellIdentifier";
}
@end
