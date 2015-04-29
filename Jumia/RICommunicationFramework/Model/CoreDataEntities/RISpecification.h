//
//  RISpecification.h
//  Jumia
//
//  Created by epacheco on 21/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "RISpecificationAttribute.h"

@class RIProduct, RISpecificationAttribute, RISpecification;

@interface RISpecification : NSManagedObject

@property (nonatomic, retain) NSString *headLabel;
@property (nonatomic, retain) NSMutableArray *specificationAttributes;


+(RISpecification*)parseSpecification:(NSDictionary *)specificationsJSON;

+ (void)saveSpecification:(RISpecification*)specification;


@end


