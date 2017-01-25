//
//  RISpecification.m
//  Jumia
//
//  Created by Telmo Pinto on 20/08/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RISpecification.h"
#import "RISpecificationAttribute.h"

@implementation RISpecification

+(RISpecification*)parseSpecification:(NSDictionary *)specificationsJSON
{
    RISpecification *newSpecification = [[RISpecification alloc] init];
    
    //NSDictionary *dataDic = [specificationsJSON objectForKey:@"data"];
    //if(VALID_NOTEMPTY(dataDic, NSDictionary)){
    //NSDictionary *specificationJSON = [specificationsJSON objectForKey:@"specifications"];
    if(VALID_NOTEMPTY(specificationsJSON, NSDictionary)){
        if([specificationsJSON objectForKey:@"head_label"]){
            newSpecification.headLabel = [specificationsJSON objectForKey:@"head_label"];
        }
        
        if([specificationsJSON objectForKey:@"body"]){
            NSDictionary* attributesJSON = [specificationsJSON objectForKey:@"body"];
            
            NSMutableSet *newSpecificationAttributes = [NSMutableSet new];
            for (NSDictionary* attributeJSON in attributesJSON)
            {
                if (VALID_NOTEMPTY(attributeJSON, NSDictionary)){
                    
                    RISpecificationAttribute* attribute = [RISpecificationAttribute parseSpecificationAttribute:attributeJSON];
                    [newSpecificationAttributes addObject:attribute];
                }
            }
            newSpecification.specificationAttributes = [newSpecificationAttributes copy];
        }
    }
    return newSpecification;
}

@end
