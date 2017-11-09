//
//  STAdPost.h
//  Status
//
//  Created by Cosmin Andrus on 09/11/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STPost.h"

@class STFacebookAdModel;

@interface STAdPost : STPost

@property (nonatomic, strong, readonly) STFacebookAdModel *adModel;

@end
