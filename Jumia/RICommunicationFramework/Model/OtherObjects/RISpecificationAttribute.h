//
//  RISpecificationAttribute.h
//  Jumia
//
//  Created by Telmo Pinto on 20/08/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RISpecificationAttribute : NSObject

@property (nonatomic, retain) NSString *key;
@property (nonatomic, retain) NSString *value;

+(RISpecificationAttribute*)parseSpecificationAttribute:(NSDictionary *)specificationAttributteJSON;

@end
