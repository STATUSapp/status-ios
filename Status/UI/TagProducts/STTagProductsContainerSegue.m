//
//  STTagProductsContainerSegue.m
//  Status
//
//  Created by Cosmin Andrus on 27/10/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import "STTagProductsContainerSegue.h"

@implementation STTagProductsContainerSegue
-(instancetype)initWithIdentifier:(NSString *)identifier source:(UIViewController *)source destination:(UIViewController *)destination{
    self = [super initWithIdentifier:identifier source:source destination:destination];
    if (self) {
        
    }
    return self;
}

- (void)perform {
    // Add your own animation code here.
//    [[self sourceViewController] presentViewController:[self destinationViewController] animated:NO completion:nil];
}
@end
