//
//  RIField.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIField.h"
#import "RIFieldDataSetComponent.h"
#import "RIForm.h"


@implementation RIField

@dynamic key;
@dynamic max;
@dynamic min;
@dynamic name;
@dynamic regex;
@dynamic requiredMessage;
@dynamic type;
@dynamic uid;
@dynamic value;
@dynamic form;
@dynamic dataSet;
@dynamic label;

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
        
        NSDictionary* required = [rules objectForKey:@"required"];
        if (VALID_NOTEMPTY(required, NSDictionary) && [required objectForKey:@"message"]) {
            newField.requiredMessage = [required objectForKey:@"message"];
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
