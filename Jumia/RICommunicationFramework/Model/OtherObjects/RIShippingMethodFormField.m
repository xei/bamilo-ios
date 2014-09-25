//
//  RIShippingMethodFormField.m
//  Jumia
//
//  Created by Pedro Lopes on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIShippingMethodFormField.h"
#import "RIShippingMethodPickupStationOption.h"

@implementation RIShippingMethodFormField

+ (RIShippingMethodFormField *)parseField:(NSDictionary *)fieldJSON;
{
    RIShippingMethodFormField* newField = [[RIShippingMethodFormField alloc] init];    
    
    if ([fieldJSON objectForKey:@"id"]) {
        newField.uid = [fieldJSON objectForKey:@"id"];
    }
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
        } else if ([rules objectForKey:@"required"]) {
            newField.required  = [[rules objectForKey:@"required"] boolValue];
        }
    }
    
    if (VALID_NOTEMPTY([fieldJSON objectForKey:@"options"], NSDictionary) && VALID_NOTEMPTY(newField.key, NSString)) {
        NSDictionary* optionsObject = [fieldJSON objectForKey:@"options"];
        NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
        
        NSArray *optionsKeys = [optionsObject allKeys];
        for(NSString *optionKey in optionsKeys)
        {
            NSDictionary *optionDictionaryObject = [optionsObject objectForKey:optionKey];
            if(VALID_NOTEMPTY(optionDictionaryObject, NSDictionary) && VALID_NOTEMPTY([optionDictionaryObject objectForKey:@"label"], NSString))
            {
                NSDictionary *optionDictionary = [NSDictionary dictionaryWithObject:[optionDictionaryObject objectForKey:@"label"] forKey:optionKey];
                [optionsArray addObject:optionDictionary];
            }
        }
        
        newField.options = [NSDictionary dictionaryWithObject:[optionsArray copy] forKey:[newField.key lowercaseString]];
    }
    else if (VALID_NOTEMPTY([fieldJSON objectForKey:@"options"], NSArray) && VALID_NOTEMPTY(newField.scenario, NSString)) {
        {
            NSArray* optionsObject = [fieldJSON objectForKey:@"options"];
            NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
            
            for(NSDictionary *optionObject in optionsObject)
            {
                if(VALID_NOTEMPTY(optionObject, NSDictionary))
                {
                    if([@"pickupstation" isEqualToString:[newField.scenario lowercaseString]])
                    {
                        RIShippingMethodPickupStationOption *option = [RIShippingMethodPickupStationOption parsePickupStation:optionObject];
                        [optionsArray addObject:option];
                    }
                }
            }
            
            newField.options = [NSDictionary dictionaryWithObject:[optionsArray copy] forKey:newField.scenario];
        }
    }
    
    return newField;
}

@end
