//
//  RIShippingMethodForm.m
//  Jumia
//
//  Created by Pedro Lopes on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIShippingMethodForm.h"
#import "RIShippingMethodFormField.h"

@implementation RIShippingMethodForm

+ (RIShippingMethodForm *)parseForm:(NSDictionary *)formJSON
{
    RIShippingMethodForm* newForm = [[RIShippingMethodForm alloc] init];
    
    if (VALID_NOTEMPTY(formJSON, NSDictionary)) {
        
        if ([formJSON objectForKey:@"id"]) {
            newForm.uid = [formJSON objectForKey:@"id"];
        }
        if ([formJSON objectForKey:@"action"]) {
            newForm.action = [formJSON objectForKey:@"action"];
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
    NSMutableArray *options = nil;
    if(VALID_NOTEMPTY(form, RIShippingMethodForm))
    {
        options = [[NSMutableArray alloc] init];
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
