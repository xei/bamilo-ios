//
//  RIField.m
//  Comunication Project
//
//  Created by Telmo Pinto on 23/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIField.h"
#import "RIForm.h"


@implementation RIField

@dynamic key;
@dynamic type;
@dynamic requiredMessage;
@dynamic min;
@dynamic max;
@dynamic regex;
@dynamic value;
@dynamic name;
@dynamic uid;
@dynamic form;

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
    
    NSDictionary* rules = [fieldJSON objectForKey:@"rules"];
    
    if (VALID_NOTEMPTY(rules, NSDictionary)) {
        
        if ([rules objectForKey:@"regex"]) {
            newField.regex = [fieldJSON objectForKey:@"regex"];
        }
        if ([rules objectForKey:@"min"]) {
            newField.min = [fieldJSON objectForKey:@"min"];
        }
        if ([rules objectForKey:@"max"]) {
            newField.max = [fieldJSON objectForKey:@"max"];
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
