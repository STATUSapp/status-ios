//
//  STTagBrandSection.h
//  Status
//
//  Created by Cosmin Andrus on 29/12/2017.
//  Copyright © 2017 Andrus Cosmin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Brand;

@interface STTagBrandSection : NSObject

@property (nonatomic, strong, readonly) NSString *sectionName;
@property (nonatomic, strong, readonly) NSArray<Brand *>*sectionItems;

-(instancetype)initWithSectionName:(NSString *)sectionName;

-(instancetype)initWithObject:(Brand *)object;
-(instancetype)initWithObjects:(NSArray <Brand *> *)objects;

-(void)addObjectToItems:(Brand *)object;
-(void)addObjectsToItems:(NSArray <Brand *> *)objects;

@end
