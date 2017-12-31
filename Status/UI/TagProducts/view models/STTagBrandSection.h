//
//  STTagBrandSection.h
//  Status
//
//  Created by Cosmin Andrus on 29/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class STBrandObj;

@interface STTagBrandSection : NSObject

@property (nonatomic, strong, readonly) NSString *sectionName;
@property (nonatomic, strong, readonly) NSArray<STBrandObj *>*sectionItems;

-(instancetype)initWithObject:(STBrandObj *)object;
-(instancetype)initWithObjects:(NSArray <STBrandObj *> *)objects;

-(void)addObjectToItems:(STBrandObj *)object;
-(void)addObjectsToItems:(NSArray <STBrandObj *> *)objects;

@end
