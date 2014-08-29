//
//  JABirthDateComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABirthDateComponent.h"

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
    self.dayField = day;
    self.monthField = month;
    self.yearField = year;
    
    [self.textField setPlaceholder:label];
    
    if(VALID_NOTEMPTY(day.requiredMessage, NSString))
    {
        [self.textField setTextColor:UIColorFromRGB(0x666666)];
        [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
        
        [self.requiredSymbol setHidden:NO];
        [self.requiredSymbol setTextColor:UIColorFromRGB(0xfaa41a)];
    }
    
    if(VALID_NOTEMPTY([[self dayField] value], NSString) && VALID_NOTEMPTY([[self monthField] value], NSString) && VALID_NOTEMPTY([[self yearField] value], NSString))
    {
        [self.textField setText:[NSString stringWithFormat:@"%@-%@-%@", [[self dayField] value], [[self monthField] value], [[self yearField] value]]];
    }
}

-(void)setValue:(NSDate*)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    
    NSInteger day = [components day];
    [[self dayField] setValue:[NSString stringWithFormat:@"%d", day]];
    
    NSInteger month = [components month];
    [[self monthField] setValue:[NSString stringWithFormat:@"%d", month]];
    
    NSInteger year = [components year];
    [[self yearField] setValue:[NSString stringWithFormat:@"%d", year]];
    
    [self.textField setText:[NSString stringWithFormat:@"%d-%d-%d", day, month, year]];
}

-(NSDate*)getValue
{
    NSDate *value = nil;
    if(VALID_NOTEMPTY([self dayField], RIField) && VALID_NOTEMPTY([[self dayField] value], NSString)
       && VALID_NOTEMPTY([self monthField], RIField) && VALID_NOTEMPTY([[self monthField] value], NSString)
       && VALID_NOTEMPTY([self yearField], RIField) && VALID_NOTEMPTY([[self yearField] value], NSString))
    {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        [components setDay:[[[self dayField] value] intValue]];
        [components setMonth:[[[self monthField] value] intValue]];
        [components setYear:[[[self yearField] value] intValue]];
        value = [calendar dateFromComponents:components];
    }
    return value;
}

-(BOOL)isValid
{
    if ((self.dayField.requiredMessage.length > 0) && (self.textField.text.length == 0))
    {
        [self.textField setTextColor:UIColorFromRGB(0xcc0000)];
        [self.textField setValue:UIColorFromRGB(0xcc0000) forKeyPath:@"_placeholderLabel.textColor"];
        
        return NO;
    }
    
    self.textField.backgroundColor = [UIColor whiteColor];
    
    return YES;
}

@end