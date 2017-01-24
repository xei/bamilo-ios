//
//  RIShippingMethodFormField.m
//  Jumia
//
//  Created by Pedro Lopes on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIShippingMethodFormField.h"
#import "RIShippingMethod.h"
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
    
    if (VALID_NOTEMPTY([fieldJSON objectForKey:@"options"], NSArray)) {
        if (VALID_NOTEMPTY(newField.scenario, NSString)) {
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
                    } else {
                        NSArray *optionsKeys = [optionObject allKeys];
                        for(NSString *optionKey in optionsKeys)
                        {
                            NSDictionary *optionDictionaryObject = [optionObject objectForKey:optionKey];
                            RIShippingMethod *shippingMethod = [RIShippingMethod parseShippingMethod:optionDictionaryObject];
                            if(VALID_NOTEMPTY(shippingMethod, RIShippingMethod))
                            {
                                NSDictionary *optionDictionary = [NSDictionary dictionaryWithObject:shippingMethod forKey:optionKey];
                                [optionsArray addObject:optionDictionary];
                            }
                        }
                    }
                }
            }
            
            newField.options = [NSDictionary dictionaryWithObject:[optionsArray copy] forKey:newField.scenario];
        } else if (VALID_NOTEMPTY(newField.key, NSString)) {
            NSArray* optionJSONsArray = [fieldJSON objectForKey:@"options"];
            NSMutableArray* optionsFinalArray = [NSMutableArray new];
            
            if (VALID_NOTEMPTY(optionJSONsArray, NSArray)) {
                for(NSDictionary *optionJSON in optionJSONsArray)
                {
                    RIShippingMethod *shippingMethod = [RIShippingMethod parseShippingMethod:optionJSON];
                    if(VALID_NOTEMPTY(shippingMethod, RIShippingMethod))
                    {
                        NSDictionary *optionDictionary = [NSDictionary dictionaryWithObject:shippingMethod forKey:shippingMethod.value];
                        [optionsFinalArray addObject:optionDictionary];
                    }
                }
                
                newField.options = [NSDictionary dictionaryWithObject:[optionsFinalArray copy] forKey:[newField.key lowercaseString]];
            }
        }
    }
    
    return newField;
}

@end
