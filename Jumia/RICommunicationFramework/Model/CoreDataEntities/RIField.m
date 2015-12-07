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
@dynamic required;
@dynamic requiredMessage;
@dynamic type;
@dynamic value;
@dynamic dataSet;
@dynamic apiCallEndpoint;
@dynamic apiCallParameters;
@dynamic form;
@dynamic options;
@dynamic ratingStars;
@dynamic linkText;
@dynamic linkTargetString;
@dynamic pattern;
@dynamic patternMessage;
@dynamic relatedFields;
@dynamic parentField;
@dynamic checked;
@dynamic dateFormat;

+ (RIField *)parseField:(NSDictionary *)fieldJSON;
{
    RIField* newField = (RIField*)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIField class])];
    
    if ([fieldJSON objectForKey:@"key"]) {
        newField.key = [fieldJSON objectForKey:@"key"];
    }
    if ([fieldJSON objectForKey:@"type"]) {
        newField.type = [fieldJSON objectForKey:@"type"];
    }
    if ([fieldJSON objectForKey:@"name"]) {
        newField.name = [fieldJSON objectForKey:@"name"];
    }
    if ([fieldJSON objectForKey:@"label"]) {
        newField.label = [fieldJSON objectForKey:@"label"];
    }
    id value = [fieldJSON objectForKey:@"value"];
    if (VALID(value, NSString)) {
        newField.value = (NSString *)value;
    }
    else if(VALID(value, NSNumber)) {
        newField.value = [((NSNumber *)value) stringValue];
    }
    if ([fieldJSON objectForKey:@"checked"]) {
        newField.checked = [fieldJSON objectForKey:@"checked"];
    }
    if ([fieldJSON objectForKey:@"format"]) {
        newField.dateFormat = [fieldJSON objectForKey:@"format"];
    }
    
    if(VALID_NOTEMPTY([fieldJSON objectForKey:@"api_call"], NSString)) {
        NSDictionary* apicall = [fieldJSON objectForKey:@"api_call"];
        if (VALID_NOTEMPTY([apicall objectForKey:@"endpoint"], NSString)) {
            newField.apiCallEndpoint = [apicall objectForKey:@"endpoint"];
        }
        if (VALID_NOTEMPTY([apicall objectForKey:@"params"], NSArray)) {
            NSArray* params = [apicall objectForKey:@"params"];
            NSMutableDictionary* newParams = [NSMutableDictionary new];
            for (NSDictionary* parameter in params) {
                if (VALID_NOTEMPTY(parameter, NSDictionary)) {
                    NSString* key = [parameter objectForKey:@"key"];
                    NSString* param = [parameter objectForKey:@"param"];
                    if (VALID_NOTEMPTY(key, NSString) && VALID_NOTEMPTY(param, NSString)) {
                        [newParams setObject:param forKey:key];
                    }
                }
            }
            newField.apiCallParameters = [newParams copy];
        }
    }
    
    //$$$ LINK IS NOW AN OBJECT, CHECK LATER
    if ([fieldJSON objectForKey:@"label"]) {
        newField.linkText = [fieldJSON objectForKey:@"label"];
    }
    if ([fieldJSON objectForKey:@"target"]) {
        newField.linkTargetString = [fieldJSON objectForKey:@"target"];
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
    
    if (VALID_NOTEMPTY([fieldJSON objectForKey:@"dataset"], NSArray))
    {
        NSArray *dataSetArray = [fieldJSON objectForKey:@"dataset"];
        
        id exampleObject = [dataSetArray firstObject];
        
        if ([exampleObject isKindOfClass:[NSString class]]) {
            for (NSString *tempString in dataSetArray) {
                RIFieldDataSetComponent *component = [RIFieldDataSetComponent parseDataSetComponentWithString:tempString];
                component.field = newField;
                [newField addDataSetObject:component];
            }
        } else if ([exampleObject isKindOfClass:[NSDictionary class]]) {
            for (NSDictionary* tempDictionary in dataSetArray) {
                RIFieldDataSetComponent *component = [RIFieldDataSetComponent parseDataSetComponentWithDictionary:tempDictionary];
                component.field = newField;
                [newField addDataSetObject:component];
            }
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
    
    //RULES PARSING
    NSDictionary* rules = [fieldJSON objectForKey:@"rules"];
    
    if (VALID_NOTEMPTY(rules, NSDictionary)) {
        
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
    
    
    if ([fieldJSON objectForKey:@"related_data"]) {
        
        NSDictionary* relatedJSON = [fieldJSON objectForKey:@"related_data"];

        NSString* typeForRelatedFields = [relatedJSON objectForKey:@"type"];
        NSString* nameForRelatedFields = [relatedJSON objectForKey:@"name"];
        
        
        if ([typeForRelatedFields isEqualToString:@"choice"]) {
            
            if (VALID_NOTEMPTY(relatedJSON, NSDictionary)) {
                RIField* relatedField = [RIField parseField:relatedJSON];
                relatedField.parentField = newField;
                relatedField.type = typeForRelatedFields;
                relatedField.name = nameForRelatedFields;
                [newField addRelatedFieldsObject:relatedField];
            }
        }
        
        NSArray* relatedFieldsArrayJSON = [relatedJSON objectForKey:@"fields"];
        for (NSDictionary* relatedFieldJSON in relatedFieldsArrayJSON) {
            if (VALID_NOTEMPTY(relatedFieldJSON, NSDictionary)) {
                
                RIField* relatedField = [RIField parseField:relatedFieldJSON];
                relatedField.parentField = newField;
                relatedField.type = typeForRelatedFields;
                relatedField.name = nameForRelatedFields;
                
                [newField addRelatedFieldsObject:relatedField];
            }
        }
    }
    
    return newField;
}

+ (void)saveField:(RIField *)field andContext:(BOOL)save
{
    for (RIFieldRatingStars* fieldRatingStars in field.ratingStars) {
        [RIFieldRatingStars saveFieldRatingStars:fieldRatingStars andContext:NO];
    }
    for (RIFieldOption* fieldOption in field.options) {
        [RIFieldOption saveFieldOption:fieldOption andContext:NO];
    }
    for (RIFieldDataSetComponent* datasetComponent in field.dataSet) {
        [RIFieldDataSetComponent saveFieldDataSetComponent:datasetComponent andContext:NO];
    }
    for (RIField* relatedField in field.relatedFields) {
        [RIField saveField:relatedField andContext:NO];
    }
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:field];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

@end
