//
//  JABirthDateComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABirthDateComponent.h"

@interface JABirthDateComponent ()

@property (strong, nonatomic) RIField *dayField;
@property (strong, nonatomic) RIField *monthField;
@property (strong, nonatomic) RIField *yearField;
@property (assign, nonatomic) NSInteger storedDay;
@property (assign, nonatomic) NSInteger storedMonth;
@property (assign, nonatomic) NSInteger storedYear;

@end

@implementation JABirthDateComponent

+(JABirthDateComponent *)getNewJABirthDateComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JABirthDateComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JABirthDateComponent class]]) {
            return (JABirthDateComponent *)obj;
        }
    }
    
    return nil;
}

-(void)setupWithLabel:(NSString*)label day:(RIField*)day month:(RIField*)month year:(RIField*)year
{
    self.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.hasError = NO;
    
    self.dayField = day;
    self.monthField = month;
    self.yearField = year;
    
    self.storedDay = -1;
    self.storedMonth = -1;
    self.storedYear = -1;
    
    [self.textField setPlaceholder:label];
    
    self.textField.font = [UIFont fontWithName:kFontRegularName size:self.textField.font.pointSize];
    [self.textField setTextColor:UIColorFromRGB(0x666666)];
    [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];

    if([day.required boolValue])
    {        
        [self.requiredSymbol setHidden:NO];
        [self.requiredSymbol setTextColor:UIColorFromRGB(0xfaa41a)];
    }
    
    if(-1 != self.storedDay && -1 != self.storedMonth && -1 != self.storedYear)
    {
        [self.textField setText:[NSString stringWithFormat:@"%ld-%ld-%ld", (long)self.storedDay, (long)self.storedMonth, (long)self.storedYear]];
    }
}

-(BOOL)isComponentWithKey:(NSString*)key
{
    return ([key isEqualToString:self.dayField.key] || [key isEqualToString:self.monthField.key] || [key isEqualToString:self.yearField.key]);
}

-(void)setValue:(NSDate*)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    
    self.storedDay = [components day];
    self.storedMonth = [components month];
    self.storedYear = [components year];
    
    [self.textField setText:[NSString stringWithFormat:@"%ld-%ld-%ld", (long)self.storedDay, (long)self.storedMonth, (long)self.storedYear]];
}

-(NSDate*)getDate
{
    NSDate *value = nil;
    if(-1 != self.storedDay && -1 != self.storedMonth && -1 != self.storedYear)
    {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:self.storedDay];
        [components setMonth:self.storedMonth];
        [components setYear:self.storedYear];
        value = [calendar dateFromComponents:components];
    }
    return value;
}

-(NSMutableDictionary*)getValues
{
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    
    if(self.storedDay > -1)
    {
        [values setObject:[NSString stringWithFormat:@"%ld", (long)self.storedDay] forKey:self.dayField.name];
    }
    if(self.storedMonth > -1)
    {
        [values setObject:[NSString stringWithFormat:@"%ld", (long)self.storedMonth] forKey:self.monthField.name];
    }
    if(self.storedYear > -1)
    {
        [values setObject:[NSString stringWithFormat:@"%ld", (long)self.storedYear] forKey:self.yearField.name];
    }
    
    return values;
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
    if (([self.dayField.required boolValue]) && (self.textField.text.length == 0))
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
    
    self.storedDay = -1;
    self.storedMonth = -1;
    self.storedYear = -1;
    
    [self.textField setText:@""];
}

@end