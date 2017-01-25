//
//  RIPaymentMethodFormField.m
//  Jumia
//
//  Created by Pedro Lopes on 29/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIPaymentMethodFormField.h"

@implementation RIPaymentMethodFormField

+ (RIPaymentMethodFormField *)parseField:(NSDictionary *)fieldJSON;
{
    RIPaymentMethodFormField* newField = [[RIPaymentMethodFormField alloc] init];
    
    if ([fieldJSON objectForKey:@"key"]) {
        newField.key = [fieldJSON objectForKey:@"key"];
    }
    if ([fieldJSON objectForKey:@"name"]) {
        newField.name = [fieldJSON objectForKey:@"name"];
    }
    if ([fieldJSON objectForKey:@"value"]) {
        newField.value = [fieldJSON objectForKey:@"value"];
    }
    if ([fieldJSON objectForKey:@"label"]) {
        newField.label = [fieldJSON objectForKey:@"label"];
    }
    if ([fieldJSON objectForKey:@"type"]) {
        newField.type = [fieldJSON objectForKey:@"type"];
    }
    if ([fieldJSON objectForKey:@"scenario"]) {
        newField.scenario = [fieldJSON objectForKey:@"scenario"];
    }
    
    NSDictionary* rules = [fieldJSON objectForKey:@"rules"];
    if (VALID_NOTEMPTY(rules, NSDictionary)) {
        if (VALID_NOTEMPTY([rules objectForKey:@"required"], NSDictionary)) {
            newField.required= true;
        }
    }
    
    if (VALID_NOTEMPTY([fieldJSON objectForKey:@"options"], NSArray)) {
        NSArray* optionsObject = [fieldJSON objectForKey:@"options"];
        
        NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
        for(NSDictionary *optionObject in optionsObject)
        {
            if(VALID_NOTEMPTY(optionObject, NSDictionary))
            {
                RIPaymentMethodFormOption *option = [RIPaymentMethodFormOption parseField:optionObject];
                [optionsArray addObject:option];
            }
        }
        
        newField.options = [optionsArray copy];
    }
    
    return newField;
}

@end
