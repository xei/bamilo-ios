//
//  RIFieldDataSetComponent.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIFieldDataSetComponent.h"
#import "RIField.h"


@implementation RIFieldDataSetComponent

@dynamic value;
@dynamic pattern;
@dynamic patternMessage;
@dynamic label;
@dynamic field;

+ (RIFieldDataSetComponent *)parseDataSetComponentWithString:(NSString *)text
{
    RIFieldDataSetComponent *component = (RIFieldDataSetComponent *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIFieldDataSetComponent class])];
    component.value = text;
    
    return component;
}

+ (RIFieldDataSetComponent *)parseDataSetComponentWithDictionary:(NSDictionary *)dictionary;
{
    RIFieldDataSetComponent *component = (RIFieldDataSetComponent *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIFieldDataSetComponent class])];

    if (VALID_NOTEMPTY(dictionary, NSDictionary)) {
        
        if([dictionary objectForKey:@"label"]){
            component.label = [dictionary objectForKey:@"label"];
        }
        
        if([dictionary objectForKey:@"value"]){
            component.value = [dictionary objectForKey:@"value"];
        }
        
        if([dictionary objectForKey:@"match"]){
            NSDictionary *match = [dictionary objectForKey:@"match"];
            if(VALID_NOTEMPTY(match, NSDictionary)){
                
                if([match objectForKey:@"pattern"]){
                    component.pattern = [match objectForKey:@"pattern"];
                }
                if([match objectForKey:@"message"]){
                    component.patternMessage = [match objectForKey:@"message"];
                }
            }
        }
    }
    
    return component;
}

+ (void)saveFieldDataSetComponent:(RIFieldDataSetComponent *)component
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:component];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
