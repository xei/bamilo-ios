//
//  RISpecificationAttribute.h
//  Jumia
//
//  Created by epacheco on 21/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RISpecification.h"


@class RIProduct, RISpecification;

@interface RISpecificationAttribute : NSManagedObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *value;
@property (nonatomic, retain) RISpecification *specification;

+(RISpecificationAttribute*)parseSpecificationAttribute:(NSDictionary *)specificationAttributteJSON;

+ (void)saveSpacificationAttribute:(RISpecificationAttribute *)specificationAttribute andContext:(BOOL)save;

@end
