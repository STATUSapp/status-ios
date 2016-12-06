//
//  STSideBySideContainerProtocol.h
//  Status
//
//  Created by Cosmin Andrus on 29/11/2016.
//  Copyright © 2016 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol STSideBySideContainerProtocol <NSObject>

- (void)containerEndedScrolling;
- (void)containerStartedScrolling;

@end
