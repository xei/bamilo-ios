//
//  RISpecificationAttribute.m
//  Jumia
//
//  Created by Telmo Pinto on 20/08/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RISpecificationAttribute.h"

@implementation RISpecificationAttribute

+(RISpecificationAttribute*)parseSpecificationAttribute:(NSDictionary *)specificationAttributteJSON
{
    RISpecificationAttribute *newSpecificationAttribute = [[RISpecificationAttribute alloc] init];
    
    if(VALID_NOTEMPTY(specificationAttributteJSON, NSDictionary)){
        //for(NSDictionary *attributes in specificationAttributteJSON){
        
        if([specificationAttributteJSON objectForKey:@"key"]){
            newSpecificationAttribute.key = [specificationAttributteJSON objectForKey:@"key"];
        }
        
        if([specificationAttributteJSON objectForKey:@"value"]){
            newSpecificationAttribute.value = [specificationAttributteJSON objectForKey:@"value"];
        }
    }
    
    return newSpecificationAttribute;
    
}

@end
