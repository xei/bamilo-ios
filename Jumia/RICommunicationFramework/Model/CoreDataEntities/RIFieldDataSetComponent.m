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
@dynamic field;

+ (RIFieldDataSetComponent *)parseDataSetComponent:(NSString *)text
{
    RIFieldDataSetComponent *component = (RIFieldDataSetComponent *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIFieldDataSetComponent class])];
    component.value = text;
    
    return component;
}

+ (void)saveFieldDataSetComponent:(RIFieldDataSetComponent *)component
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:component];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
