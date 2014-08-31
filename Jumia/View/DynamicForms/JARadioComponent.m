//
//  JARadioComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARadioComponent.h"
#import "RIFieldDataSetComponent.h"

@implementation JARadioComponent

+(JARadioComponent *)getNewJARadioComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JARadioComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JARadioComponent class]]) {
            return (JARadioComponent *)obj;
        }
    }
    
    return nil;
}

-(void)setupWithField:(RIField*)field
{
    self.hasError = NO;
    self.field = field;
    [self.textField setPlaceholder:field.label];
    
    if(VALID_NOTEMPTY(field.requiredMessage, NSString))
    {
        [self.textField setTextColor:UIColorFromRGB(0x666666)];
        [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
        
        [self.requiredSymbol setHidden:NO];
        [self.requiredSymbol setTextColor:UIColorFromRGB(0xfaa41a)];
    }
    
    if(VALID_NOTEMPTY(field.value, NSString))
    {
        [self.textField setText:field.value];
    }
    
    NSMutableArray *contentArray = [[NSMutableArray alloc] init];
    for (RIFieldDataSetComponent *component in field.dataSet) {
        [contentArray addObject:component.value];
    }
    self.dataset = [contentArray copy];
}

-(void)setValue:(NSString*)value
{
    [[self field] setValue:value];
    [self.textField setText:value];
}

-(NSString*)getValue
{
    NSString *value = nil;
    if(VALID_NOTEMPTY([self field], RIField) && VALID_NOTEMPTY([[self field] value], NSString))
    {
        value = [[self field] value];
    }
    return value;
}

-(void)setError:(NSString*)error
{
    [self.textField setTextColor:UIColorFromRGB(0xcc0000)];
    [self.textField setValue:UIColorFromRGB(0xcc0000) forKeyPath:@"_placeholderLabel.textColor"];

    if(ISEMPTY(self.textField.text))
    {
        self.hasError = YES;
        [self.textField setText:error];
    }
}

-(void)cleanError
{
    if(self.hasError)
    {
        [self.textField setTextColor:UIColorFromRGB(0x666666)];
        [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];

        if(self.hasError)
        {
            self.hasError = NO;
            [self.textField setText:@""];
        }
    }
}

- (BOOL)isValid
{
    if ((self.field.requiredMessage.length > 0) && (self.textField.text.length == 0))
    {
        [self.textField setTextColor:UIColorFromRGB(0xcc0000)];
        [self.textField setValue:UIColorFromRGB(0xcc0000) forKeyPath:@"_placeholderLabel.textColor"];
        
        return NO;
    }
    
    [self.textField setTextColor:UIColorFromRGB(0x666666)];
    [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    
    return YES;
}

@end
