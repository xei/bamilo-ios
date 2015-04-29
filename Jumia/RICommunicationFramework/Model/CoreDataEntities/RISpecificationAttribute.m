//
//  RISpecificationAttribute.m
//  Jumia
//
//  Created by epacheco on 21/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RISpecificationAttribute.h"
#import "RISpecification.h"

@implementation RISpecificationAttribute

@dynamic key;
@dynamic value;
@dynamic specification;

+(RISpecificationAttribute*)parseSpecificationAttribute:(NSDictionary *)specificationAttributteJSON

{
    RISpecificationAttribute *newSpecificationAttribute = (RISpecificationAttribute*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISpecificationAttribute class])];
    

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

+ (void)saveSpacificationAttribute:(RISpecificationAttribute *)specificationAttribute
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:specificationAttribute];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end