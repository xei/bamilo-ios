//
//  RIFieldOption.m
//  Jumia
//
//  Created by Pedro Lopes on 29/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIFieldOption.h"
#import "RIField.h"


@implementation RIFieldOption

@dynamic isDefault;
@dynamic label;
@dynamic value;
@dynamic isUserSubscribed;
@dynamic field;

+ (RIFieldOption *)parseFieldOption:(NSDictionary *)fieldOptionObject
{
    RIFieldOption *fieldOption = (RIFieldOption *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIFieldOption class])];

    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"is_default"], NSString))
    {
        fieldOption.isDefault = [NSNumber numberWithBool:[[fieldOptionObject objectForKey:@"is_default"] boolValue]];
    }
    
    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"label"], NSString))
    {
        fieldOption.label = [fieldOptionObject objectForKey:@"label"];
    }
    
    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"value"], NSString))
    {
        fieldOption.value = [fieldOptionObject objectForKey:@"value"];
    }
    
    if (VALID_NOTEMPTY([fieldOptionObject objectForKey:@"user_subscribed"], NSNumber))
    {
        fieldOption.isUserSubscribed = [fieldOptionObject objectForKey:@"user_subscribed"];
    }
    
    return fieldOption;
}

+ (void)saveFieldOption:(RIFieldOption *)option andContext:(BOOL)save
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:option];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

@end
