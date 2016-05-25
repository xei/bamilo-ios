//
//  JADynamicField.m
//  Jumia
//
//  Created by Telmo Pinto on 08/06/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JADynamicField.h"

@implementation JADynamicField

-(BOOL)isComponentWithKey:(NSString*)key
{
    return ([key isEqualToString:self.field.key]);
}

-(BOOL)isComponentWithName:(NSString*)name
{
    return ([name isEqualToString:self.field.name]);
}

- (void)setValue:(id)value
{
    
}

- (NSDictionary *)getValues
{
    return @{};
}

- (NSDictionary *)getLabels
{
    return @{};
}

@end
