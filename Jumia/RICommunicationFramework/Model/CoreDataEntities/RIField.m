//
//  RIField.m
//  Jumia
//
//  Created by Pedro Lopes on 29/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIField.h"
#import "RIFieldDataSetComponent.h"
#import "RIFieldOption.h"
#import "RIForm.h"


@implementation RIField

@dynamic key;
@dynamic label;
@dynamic max;
@dynamic min;
@dynamic name;
@dynamic regex;
@dynamic required;
@dynamic requiredMessage;
@dynamic type;
@dynamic uid;
@dynamic value;
@dynamic dataSet;
@dynamic form;
@dynamic options;

+ (RIField *)parseField:(NSDictionary *)fieldJSON;
{
    RIField* newField = (RIField*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIField class])];
    
    if ([fieldJSON objectForKey:@"key"]) {
        newField.key = [fieldJSON objectForKey:@"key"];
    }
    if ([fieldJSON objectForKey:@"type"]) {
        newField.type = [fieldJSON objectForKey:@"type"];
    }
    if ([fieldJSON objectForKey:@"value"]) {
        newField.value = [fieldJSON objectForKey:@"value"];
    }
    if ([fieldJSON objectForKey:@"id"]) {
        newField.uid = [fieldJSON objectForKey:@"id"];
    }
    if ([fieldJSON objectForKey:@"name"]) {
        newField.name = [fieldJSON objectForKey:@"name"];
    }
    if ([fieldJSON objectForKey:@"label"]) {
        newField.label = [fieldJSON objectForKey:@"label"];
    }
    
    if ([fieldJSON objectForKey:@"dataset"]) {
        NSArray *dataSetArray = [fieldJSON objectForKey:@"dataset"];
        
        for (NSString *tempString in dataSetArray) {
            RIFieldDataSetComponent *component = [RIFieldDataSetComponent parseDataSetComponent:tempString];
            component.field = newField;
            [newField addDataSetObject:component];
        }
    }
    
    if ([fieldJSON objectForKey:@"options"]) {
        NSArray *optionsArray = [fieldJSON objectForKey:@"options"];
        
        for (NSDictionary *optionObject in optionsArray) {
            if(VALID_NOTEMPTY(optionObject, NSDictionary))
            {
                RIFieldOption *option = [RIFieldOption parseFieldOption:optionObject];
                option.field = newField;
                [newField addOptionsObject:option];          
            }
        }
    }
    
    NSDictionary* rules = [fieldJSON objectForKey:@"rules"];
    
    if (VALID_NOTEMPTY(rules, NSDictionary)) {
        
        if ([rules objectForKey:@"regex"]) {
            newField.regex = [rules objectForKey:@"regex"];
        }
        if ([rules objectForKey:@"min"]) {
            newField.min = [rules objectForKey:@"min"];
        }
        if ([rules objectForKey:@"max"]) {
            newField.max = [rules objectForKey:@"max"];
        }
        
        id required = [rules objectForKey:@"required"];
        if (VALID_NOTEMPTY(required, NSDictionary) && [required objectForKey:@"message"]) {
            newField.required = [NSNumber numberWithBool:YES];
            newField.requiredMessage = [required objectForKey:@"message"];
        }
        else if(required)
        {
            newField.required = [NSNumber numberWithBool:[required boolValue]];
        }
    }
    
    return newField;
}

+ (void)saveField:(RIField *)field;
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:field];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
