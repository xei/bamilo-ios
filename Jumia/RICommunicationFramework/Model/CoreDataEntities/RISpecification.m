//
//  RISpecification.m
//  Jumia
//
//  Created by epacheco on 21/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "RISpecification.h"
#import "RISpecificationAttribute.h"

@implementation RISpecification

@dynamic headLabel;
@dynamic specificationAttributes;

+(RISpecification*)parseSpecification:(NSDictionary *)specificationsJSON
{
    
    RISpecification *newSpecification = (RISpecification*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RISpecification class])];
    
    //NSDictionary *dataDic = [specificationsJSON objectForKey:@"data"];
    //if(VALID_NOTEMPTY(dataDic, NSDictionary)){
        //NSDictionary *specificationJSON = [specificationsJSON objectForKey:@"specifications"];
        if(VALID_NOTEMPTY(specificationsJSON, NSDictionary)){
            if([specificationsJSON objectForKey:@"head_label"]){
                newSpecification.headLabel = [specificationsJSON objectForKey:@"head_label"];
            }
            
            if([specificationsJSON objectForKey:@"body"]){
                NSDictionary* attributesJSON = [specificationsJSON objectForKey:@"body"];
                for (NSDictionary* attributeJSON in attributesJSON)
                 {
                     if (VALID_NOTEMPTY(attributeJSON, NSDictionary)){
                   
                    RISpecificationAttribute* attribute = [RISpecificationAttribute parseSpecificationAttribute:attributeJSON];
                    [newSpecification.specificationAttributes addObject:attribute];
                    }
                }
            }
        }
    return newSpecification;
}

+ (void)saveSpecification:(RISpecification*)specification andContext:(BOOL)save
{
    if (specification.specificationAttributes) {
        for (RISpecificationAttribute *attribute in specification.specificationAttributes) {
            if (!attribute.specification) {
                attribute.specification = specification;
            }
            [RISpecificationAttribute saveSpacificationAttribute:attribute andContext:NO];
        }
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:specification];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}


@end
