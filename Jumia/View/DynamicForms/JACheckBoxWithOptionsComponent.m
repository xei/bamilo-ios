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
#import "RINewsletterCategory.h"

@interface JACheckBoxWithOptionsComponent ()

@property (nonatomic, strong) IBOutlet UIView *subViews;

@end

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
    
    CGFloat startingY = 0.0f;
    for(int i = 0; i < [[field options] count]; i++)
    {
        RIFieldOption *option = [[field options] objectAtIndex:i];
        NSString *fieldKey = [self.field name];
        fieldKey = [fieldKey stringByReplacingOccurrencesOfString:@"[]" withString:[NSString stringWithFormat:@"[%@]", [option value]]];
        
        JANewsletterComponent *check = [JANewsletterComponent getNewJANewsletterComponent];
        [check setup];
        [check setupWithField:field];
        [check.textLabel setText:option.label];
        [check.optionSwitch setTag:i];

        NSArray *newsletterOption = [RINewsletterCategory getNewsletter];
        
        if (ISEMPTY(newsletterOption) || 0 == newsletterOption.count)
        {
            check.optionSwitch.on = NO;
            [self.values setObject:@"-1" forKey:fieldKey];
        }
        else
        {
            BOOL finded = NO;
            
            for (RINewsletterCategory *newsletter in newsletterOption)
            {
                if ([[newsletter.idNewsletterCategory stringValue] isEqualToString:option.value])
                {
                    [self.values setObject:option.value forKey:fieldKey];                    
                    check.optionSwitch.on = YES;
                    finded = YES;
                    break;
                }
            }
            
            if (!finded)
            {
                check.optionSwitch.on = NO;
                [self.values setObject:@"-1" forKey:fieldKey];
            }
        }
        
        [check.optionSwitch addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
        
        CGRect frame = check.frame;
        frame.origin.y = startingY;
        check.frame = frame;
        startingY += check.frame.size.height;

        [check.lineImageView setHidden:NO];
        if(i == ([[field options] count] - 1))
        {
            [check.lineImageView setHidden:YES];
        }
        
        [self.subViews addSubview:check];
    }
    
    [self.subViews setFrame:CGRectMake(self.subViews.frame.origin.x, self.subViews.frame.origin.y, self.subViews.frame.size.width, startingY)];
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, CGRectGetMaxY(self.separator.frame) +startingY)];
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
            [self.values setObject:@"-1" forKey:fieldKey];
        }
    }
}

@end
