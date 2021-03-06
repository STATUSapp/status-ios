//
//  STTutorialModel.h
//  Status
//
//  Created by Cosmin Andrus on 05/12/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, STTutorial) {
    STTutorialDiscover = 0,
    STTutorialShopStyle,
    STTutorialTagProducts,
    STTutorialShareOutfit,
    STTutorialCount
};

@interface STTutorialModel : NSObject

@property (nonatomic, assign) STTutorial type;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, strong) NSString *imageName;

@end
