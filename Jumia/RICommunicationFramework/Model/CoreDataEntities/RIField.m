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
#import "RIFieldRatingStars.h"

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
@dynamic apiCall;
@dynamic form;
@dynamic options;
@dynamic ratingStars;
@dynamic linkText;
@dynamic linkUrl;
@dynamic pattern;
@dynamic patternMessage;

+ (RIField *)parseField:(NSDictionary *)fieldJSON;
{
    RIField* newField = (RIField*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIField class])];
    
    if ([fieldJSON objectForKey:@"key"]) {
        newField.key = [fieldJSON objectForKey:@"key"];
    }
    if ([fieldJSON objectForKey:@"type"]) {
        newField.type = [fieldJSON objectForKey:@"type"];
    }

    id value = [fieldJSON objectForKey:@"value"];
    if (VALID(value, NSString))
    {
        newField.value = (NSString *)value;
    }
    else if(VALID(value, NSNumber))
    {
        newField.value = [((NSNumber *)value) stringValue];
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
    
    if (VALID_NOTEMPTY([fieldJSON objectForKey:@"dataset"], NSArray))
    {
        NSArray *dataSetArray = [fieldJSON objectForKey:@"dataset"];
        
        for (NSString *tempString in dataSetArray) {
            RIFieldDataSetComponent *component = [RIFieldDataSetComponent parseDataSetComponent:tempString];
            component.field = newField;
            [newField addDataSetObject:component];
        }
    }
    else if (VALID_NOTEMPTY([fieldJSON objectForKey:@"dataset"], NSDictionary))
    {
        NSDictionary *dataSetDictionary = [fieldJSON objectForKey:@"dataset"];
        if(VALID_NOTEMPTY([dataSetDictionary objectForKey:@"api_call"], NSString))
        {
            newField.apiCall = [dataSetDictionary objectForKey:@"api_call"];
        }
    }
    
    if (VALID_NOTEMPTY([fieldJSON objectForKey:@"data_set"], NSArray)) {
        
        NSArray *dataSetArray = [fieldJSON objectForKey:@"data_set"];
        if (VALID_NOTEMPTY(dataSetArray, NSArray)) {
            
            for (NSDictionary* fieldRatingStarsJSON in dataSetArray) {
                RIFieldRatingStars* newFieldRatingStars = [RIFieldRatingStars parseFieldRatingStars:fieldRatingStarsJSON];
                newFieldRatingStars.field = newField;
                [newField addRatingStarsObject:newFieldRatingStars];
            }
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
        
        if([rules objectForKey:@"match"]){
            NSDictionary *match = [rules objectForKey:@"match"];
            if(VALID_NOTEMPTY(match, NSDictionary)){
                
                if([match objectForKey:@"pattern"]){
                    newField.pattern = [match objectForKey:@"pattern"];
                }
                if([match objectForKey:@"message"]){
                    newField.patternMessage = [match objectForKey:@"message"];
                }
            }
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
    
    if ([fieldJSON objectForKey:@"link_text"]) {
        newField.linkText = [fieldJSON objectForKey:@"link_text"];
    }
    
    if ([fieldJSON objectForKey:@"link_url"]) {
        newField.linkUrl = [fieldJSON objectForKey:@"link_url"];
    }
    
    return newField;
}

+ (void)saveField:(RIField *)field;
{
    for (RIFieldRatingStars* fieldRatingStars in field.ratingStars) {
        [RIFieldRatingStars saveFieldRatingStars:fieldRatingStars];
    }
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:field];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
