//
//  JARadioComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARadioComponent.h"
#import "RIFieldDataSetComponent.h"
#import "RIRegion.h"
#import "RICity.h"

@interface JARadioComponent ()

@property (strong, nonatomic) RIField *field;
@property (strong, nonatomic) NSString *storedValue;

@end

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
    self.storedValue = @"";
    self.hasError = NO;
    self.field = field;
    [self.textField setPlaceholder:field.label];
    
    if([field.required boolValue])
    {
        [self.textField setTextColor:UIColorFromRGB(0x666666)];
        [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
        
        [self.requiredSymbol setHidden:NO];
        [self.requiredSymbol setTextColor:UIColorFromRGB(0xfaa41a)];
    }
    
    if(VALID_NOTEMPTY(field.value, NSString))
    {
        self.storedValue = field.value;
        if(![@"list" isEqualToString:field.type])
        {
            [self.textField setText:field.value];
        }
    }
    
    if(VALID_NOTEMPTY(field.dataSet, NSOrderedSet))
    {
        NSMutableArray *contentArray = [[NSMutableArray alloc] init];
        for (RIFieldDataSetComponent *component in field.dataSet) {
            [contentArray addObject:component.value];
        }
        self.dataset = [contentArray copy];
    }
    else if(VALID_NOTEMPTY(field.apiCall, NSString))
    {
        self.apiCall = field.apiCall;
    }
}

-(BOOL)isComponentWithKey:(NSString*)key
{
    return ([key isEqualToString:self.field.key]);
}

-(void)setValue:(NSString*)value
{
    self.storedValue = value;
    [self.textField setText:value];
}

-(void)setRegionValue:(RIRegion*)value
{
    self.storedValue = [value uid];
    [self.textField setText:[value name]];
}

-(void)setCityValue:(RICity*)value
{
    self.storedValue = [value uid];
    [self.textField setText:[value value]];
}

-(NSDictionary*)getValues
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if([self.field.required boolValue] || VALID_NOTEMPTY(self.storedValue, NSString))
    {
        [parameters setValue:self.storedValue forKey:self.field.name];
    }
    return parameters;
}

-(NSString*)getSelectedValue
{
    return self.storedValue;
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
    [self.textField setTextColor:UIColorFromRGB(0x666666)];
    [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    
    if(self.hasError)
    {
        self.hasError = NO;
        [self.textField setText:@""];
    }
}

-(BOOL)isValid
{
    if ([self.field.required  boolValue] && (self.textField.text.length == 0))
    {
        [self.textField setTextColor:UIColorFromRGB(0xcc0000)];
        [self.textField setValue:UIColorFromRGB(0xcc0000) forKeyPath:@"_placeholderLabel.textColor"];
        
        return NO;
    }
    
    [self.textField setTextColor:UIColorFromRGB(0x666666)];
    [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    
    return YES;
}

-(void)resetValue
{
    [self cleanError];
    
    if(VALID_NOTEMPTY(self.field.value, NSString))
    {
        self.storedValue = self.field.value;
        if(![@"list" isEqualToString:self.field.type])
        {
            [self.textField setText:self.field.value];
        }
    }
}

-(NSString*)getApiCallUrl
{
    NSString *apiCallUrl = nil;
    
    if(VALID_NOTEMPTY(self.field, RIField) && [@"list" isEqualToString:[self.field type]] && VALID_NOTEMPTY([self.field apiCall], NSString))
    {
        apiCallUrl = [self.field apiCall];
    }
    
    return apiCallUrl;
}

@end
