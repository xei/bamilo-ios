//
//  JACheckBoxWithOptionsComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 29/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACheckBoxWithOptionsComponent.h"
#import "RIFieldOption.h"

@implementation JACheckBoxWithOptionsComponent

+ (JACheckBoxWithOptionsComponent *)getNewJACheckBoxWithOptionsComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JACheckBoxWithOptionsComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JACheckBoxWithOptionsComponent class]]) {
            return (JACheckBoxWithOptionsComponent *)obj;
        }
    }
    
    return nil;
}

-(void)setupWithField:(RIField*)field
{
    self.field = field;
    
    self.values = [[NSMutableDictionary alloc] init];
    
    self.layer.cornerRadius = 5.0f;
    
    [self.title setTextColor:UIColorFromRGB(0x666666)];
    if(VALID_NOTEMPTY(field.label, NSString))
    {
        [self.title setText:field.label];
    }
    
    [self.separator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    
    CGFloat startingY = CGRectGetMaxY(self.separator.frame);
    for(int i = 0; i < [[field options] count]; i++)
    {
        RIFieldOption *option = [[field options] objectAtIndex:i];
        
        JACheckBoxComponent *check = [JACheckBoxComponent getNewJACheckBoxComponent];
        [check.labelText setText:option.label];
        [check.switchComponent setTag:i];
        [check.switchComponent addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
        
        CGRect frame = check.frame;
        frame.origin.y = startingY;
        check.frame = frame;
        startingY += check.frame.size.height;
        
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
        fieldKey = [fieldKey stringByReplacingOccurrencesOfString:@"[]" withString:[NSString stringWithFormat:@"[%@]", [option value]]];
        
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
