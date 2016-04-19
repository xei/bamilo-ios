//
//  JACheckBoxWithOptionsComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 29/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACheckBoxWithOptionsComponent.h"
#import "RIFieldOption.h"
#import "JANewsletterComponent.h"

@interface JACheckBoxWithOptionsComponent ()

@end

@implementation JACheckBoxWithOptionsComponent

-(void)setupWithField:(RIField*)field
{
    self.field = field;
    
    self.values = [[NSMutableDictionary alloc] init];
    
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, 0.0f, self.frame.size.width - 12.0f, 25.0f)];
    [self.title setFont:JACheckBoxTitle];
    [self.title setTextColor:JAGreyColor];
    [self addSubview:self.title];
    
    if(VALID_NOTEMPTY(field.label, NSString))
    {
        [self.title setText:field.label];
    }
    
    self.separator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 25.0f, self.frame.size.width, 1.0f)];
    [self.separator setBackgroundColor:JAOrange1Color];
    [self addSubview:self.separator];
    
    CGFloat startingY = 26.0f;
    for(int i = 0; i < [[field options] count]; i++)
    {
        RIFieldOption *option = [[field options] objectAtIndex:i];
        NSString *fieldKey = [self.field name];
        fieldKey = [fieldKey stringByReplacingOccurrencesOfString:@"[]" withString:[NSString stringWithFormat:@"[%d]", i]];
        
        JANewsletterComponent *check = [JANewsletterComponent getNewJANewsletterComponent];
        [check setup];
        [check setupWithField:field];
        [check.labelText setText:option.label];
        [check.switchComponent setTag:i];
        [check.switchComponent setAccessibilityLabel:option.label];
        [check setFrame:CGRectMake(0, 0, self.frame.size.width, check.frame.size.height)];        
        
        if ([option.isUserSubscribed boolValue])
        {
            check.switchComponent.on = YES;
            [self.values setObject:option.value forKey:fieldKey];
        }
        else
        {
            check.switchComponent.on = NO;
        }
        
        [check.switchComponent addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
        
        CGRect frame = check.frame;
        frame.origin.y = startingY;
        check.frame = frame;
        startingY += check.frame.size.height;

        [check.separator setHidden:NO];
        if(i == ([[field options] count] - 1))
        {
            [check.separator setHidden:YES];
        }
        
        [self addSubview:check];
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, startingY)];
}

-(void)changedState:(UISwitch*)sender
{
    NSInteger tag = sender.tag;
    if(VALID_NOTEMPTY([self.field options], NSOrderedSet) && tag < [[self.field options] count])
    {
        RIFieldOption *option = [[self.field options] objectAtIndex:tag];
                
        NSString *fieldKey = [self.field name];
        fieldKey = [fieldKey stringByReplacingOccurrencesOfString:@"[]" withString:[NSString stringWithFormat:@"[%ld]", tag]];
        
        if([sender isOn])
        {
            [self.values setObject:[option value] forKey:fieldKey];
        }
        else
        {
            [self.values removeObjectForKey:fieldKey];
        }
    }
}

@end
