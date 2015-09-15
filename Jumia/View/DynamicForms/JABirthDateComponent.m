//
//  JABirthDateComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABirthDateComponent.h"

@interface JABirthDateComponent ()
{
    RIField *_field;
    NSInteger _storedDay;
    NSInteger _storedMonth;
    NSInteger _storedYear;
    NSString *_storedValue;
}

@end

@implementation JABirthDateComponent

+(JABirthDateComponent *)getNewJABirthDateComponent
{
    NSString* xibName = @"JABirthDateComponent";
    if (RI_IS_RTL) {
        xibName = [xibName stringByAppendingString:@"_RTL"];
    }
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:xibName
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JABirthDateComponent class]]) {
            return (JABirthDateComponent *)obj;
        }
    }
    
    return nil;
}

-(void)setupWithField:(RIField*)field
{
    _field = field;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.hasError = NO;
    
    _storedDay = -1;
    _storedMonth = -1;
    _storedYear = -1;
    
    if(VALID_NOTEMPTY(field.label, NSString))
    {
        [self.textField setPlaceholder:field.label];
    }
    
    self.textField.font = [UIFont fontWithName:kFontRegularName size:self.textField.font.pointSize];
    [self.textField setTextColor:UIColorFromRGB(0x666666)];
    [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    
    if([field.required boolValue])
    {
        [self.requiredSymbol setHidden:NO];
        [self.requiredSymbol setTextColor:UIColorFromRGB(0xfaa41a)];
    }
    
    if(VALID_NOTEMPTY(field.value, NSString))
    {
        _storedValue = field.value;
        [self.textField setText:field.value];
    }
}

-(BOOL)isComponentWithKey:(NSString*)key
{
    return [key isEqualToString:_field.key];
}

-(void)setValue:(NSDate*)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    
    _storedDay = [components day];
    _storedMonth = [components month];
    _storedYear = [components year];
    
    
    NSString *day = [NSString stringWithFormat:@"%ld", (long)_storedDay];
    NSString *month = [NSString stringWithFormat:@"%ld", (long)_storedMonth];
    if (_storedDay < 10) {
        day = [NSString stringWithFormat:@"0%ld", (long)_storedDay];
    }
    if (_storedMonth < 10) {
        month = [NSString stringWithFormat:@"0%ld", (long)_storedMonth];
    }
    
    [self.textField setText:[NSString stringWithFormat:@"%@-%@-%ld", day, month, (long)_storedYear]];
}

-(NSDate*)getDate
{
    NSDate *value = nil;
    if(-1 != _storedDay && -1 != _storedMonth && -1 != _storedYear)
    {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:_storedDay];
        [components setMonth:_storedMonth];
        [components setYear:_storedYear];
        value = [calendar dateFromComponents:components];
    }
    return value;
}

-(NSMutableDictionary*)getValues
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if([_field.required boolValue] || VALID_NOTEMPTY(self.textField.text, NSString))
    {
        if(!self.hasError)
        {
            _storedValue = _textField.text;
        }
        [parameters setValue:_storedValue forKey:_field.name];
    }
    return parameters;
}

-(void)setError:(NSString*)error
{
    self.textField.font = [UIFont fontWithName:kFontRegularName size:self.textField.font.pointSize];
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
    self.textField.font = [UIFont fontWithName:kFontRegularName size:self.textField.font.pointSize];
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
    self.textField.font = [UIFont fontWithName:kFontRegularName size:self.textField.font.pointSize];
    if (([_field.required boolValue]) && (self.textField.text.length == 0))
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
    
    _storedDay = -1;
    _storedMonth = -1;
    _storedYear = -1;
    
    [self.textField setText:@""];
}

@end