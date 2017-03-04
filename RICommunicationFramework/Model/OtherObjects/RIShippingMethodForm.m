//
//  RIShippingMethodForm.m
//  Jumia
//
//  Created by Pedro Lopes on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIShippingMethodForm.h"
#import "RIShippingMethodPickupStationOption.h"

@implementation RIShippingMethodForm

+ (RIShippingMethodForm *)parseForm:(NSDictionary *)formJSON
{
    RIShippingMethodForm* newForm = [[RIShippingMethodForm alloc] init];
    
    if (VALID_NOTEMPTY(formJSON, NSDictionary)) {
        
        if ([formJSON objectForKey:@"type"]) {
            newForm.type = [formJSON objectForKey:@"type"];
        }
        if ([formJSON objectForKey:@"action"]) {
            newForm.targetString = [formJSON objectForKey:@"action"];
        }
        if ([formJSON objectForKey:@"method"]) {
            newForm.method = [formJSON objectForKey:@"method"];
        }
        
        NSArray* fieldsObject = [formJSON objectForKey:@"fields"];
        if (VALID_NOTEMPTY(fieldsObject, NSArray)) {
            NSMutableArray *fields = [[NSMutableArray alloc] init];
            for (NSDictionary *fieldObject in fieldsObject) {
                RIShippingMethodFormField* newField = [RIShippingMethodFormField parseField:fieldObject];
                [fields addObject:newField];
            }
            newForm.fields = [fields copy];
        }
    }
    
    return newForm;
}

+ (NSArray *) getShippingMethods:(RIShippingMethodForm *) form
{
    NSArray *shippingMethods = nil;
    if(VALID_NOTEMPTY(form, RIShippingMethodForm))
    {
        for(RIShippingMethodFormField *field in form.fields)
        {
            if([@"shipping_method" isEqualToString:[field.key lowercaseString]])
            {
                shippingMethods = [field.options objectForKey:@"shipping_method"];
                break;
            }
        }
    }
    return shippingMethods;
}

+ (NSArray *) getOptionsForScenario:(NSString *) key
                             inForm:(RIShippingMethodForm *) form
{
    NSMutableArray *options = [[NSMutableArray alloc] init];
    if(VALID_NOTEMPTY(form, RIShippingMethodForm))
    {
        for(RIShippingMethodFormField *field in form.fields)
        {
            if([key isEqualToString:field.scenario])
            {
                [options addObject:field];
            }
        }
    }
    return [options copy];
}

+ (NSDictionary *) getRegionsForShippingMethod:(NSString*)shippingMethod inForm:(RIShippingMethodForm *) form
{
    NSMutableDictionary *regions = [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(form, RIShippingMethodForm))
    {
        for(RIShippingMethodFormField *field in form.fields)
        {
            if([shippingMethod isEqualToString:field.scenario] && [@"pickup_station" isEqualToString:[field.key lowercaseString]])
            {
                NSArray *options = [field.options objectForKey:shippingMethod];
                for(RIShippingMethodPickupStationOption *pickupStation in options)
                {
                    if(VALID_NOTEMPTY(pickupStation.regions, NSDictionary))
                    {
                        [regions addEntriesFromDictionary:pickupStation.regions];
                    }
                }
            }
        }
    }
    return [regions copy];
}

+ (NSArray *) getPickupStationsForRegion:(NSString*)regionId shippingMethod:(NSString*)shippingMethod inForm:(RIShippingMethodForm *) form
{
    NSMutableArray *pickupStations = [[NSMutableArray alloc] init];
    if(VALID_NOTEMPTY(form, RIShippingMethodForm))
    {
        for(RIShippingMethodFormField *field in form.fields)
        {
            if([shippingMethod isEqualToString:field.scenario] && [@"pickup_station" isEqualToString:[field.key lowercaseString]])
            {
                NSArray *options = [field.options objectForKey:shippingMethod];
                for(RIShippingMethodPickupStationOption *pickupStation in options)
                {
                    if(VALID_NOTEMPTY(pickupStation.regions, NSDictionary))
                    {
                        NSArray *pickupStationRegionIds = [pickupStation.regions allKeys];
                        if(VALID_NOTEMPTY(pickupStationRegionIds, NSArray))
                        {
                            for(NSString *pickupStationRegionId in pickupStationRegionIds)
                            {
                                if([pickupStationRegionId isEqualToString:regionId])
                                {
                                    [pickupStations addObject:pickupStation];
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return [pickupStations copy];
}

+ (NSDictionary *) getParametersForForm:(RIShippingMethodForm *)form
{
    NSString *scenario = @"";
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    for(RIShippingMethodFormField *field in form.fields)
    {
        if([@"shipping_method" isEqualToString:[field.key lowercaseString]])
        {
            scenario = field.value;
            [parameters setValue:field.value forKey:field.name];
            break;
        }
    }
    if(VALID_NOTEMPTY(scenario, NSString))
    {
        NSArray *options = [RIShippingMethodForm getOptionsForScenario:scenario inForm:form];
        if(VALID_NOTEMPTY(options, NSArray))
        {
            for(RIShippingMethodFormField *option in options)
            {
                [parameters setValue:option.value forKey:option.name];
            }
        }
    }
    
    return [parameters copy];
}

@end
