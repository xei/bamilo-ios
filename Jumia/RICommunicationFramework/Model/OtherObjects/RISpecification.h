//
//  RISpecification.h
//  Jumia
//
//  Created by Telmo Pinto on 20/08/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RISpecification : NSObject

@property (nonatomic, retain) NSString *headLabel;
@property (nonatomic, retain) NSSet *specificationAttributes;

+(RISpecification*)parseSpecification:(NSDictionary *)specificationsJSON;

@end
