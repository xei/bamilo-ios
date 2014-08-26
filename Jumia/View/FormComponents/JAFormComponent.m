//
//  JAFormComponent.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAFormComponent.h"
#import "RIForm.h"
#import "RIFieldDataSetComponent.h"

@implementation JAFormComponent

+(NSArray*)generateForm:(NSArray*)fields startingY:(CGFloat)startingY
{
    BOOL addedBirth = NO;
    NSMutableArray *formViews = [[NSMutableArray alloc] init];
    for (RIField *field in fields)
    {
        if ([field.type isEqualToString:@"string"] || [field.type isEqualToString:@"email"])
        {
            JATextField *textField = [JATextField getNewJATextField];
            textField.field = field;
            
            textField.layer.cornerRadius = 4.0f;
            CGRect frame = textField.frame;
            frame.origin.y = startingY;
            textField.frame = frame;
            startingY += textField.frame.size.height;
            
            textField.textField.placeholder = field.label;
            
            [formViews addObject:textField];
        }
        else if ([field.type isEqualToString:@"password"] || [field.type isEqualToString:@"password2"])
        {
            JATextField *textField = [JATextField getNewJATextField];
            textField.field = field;
            
            textField.layer.cornerRadius = 4.0f;
            CGRect frame = textField.frame;
            frame.origin.y = startingY;
            textField.frame = frame;
            startingY += textField.frame.size.height;
            
            textField.textField.placeholder = field.label;
            textField.textField.secureTextEntry = YES;
            
            [formViews addObject:textField];
        }
        else if ([field.type isEqualToString:@"integer"])
        {
            if (!addedBirth)
            {
                JABirthDateComponent *birthDate = [JABirthDateComponent getNewJABirthDateComponent];
                birthDate.labelText.text = @"Birthdate";
                
                birthDate.layer.cornerRadius = 4.0f;
                CGRect frame = birthDate.frame;
                frame.origin.y = startingY;
                birthDate.frame = frame;
                startingY += (birthDate.frame.size.height + 8.0f);
                
                [formViews addObject:birthDate];
                
                addedBirth = YES;
            }
        }
        else if ([field.type isEqualToString:@"radio"])
        {
            NSMutableArray *contentArray = [NSMutableArray new];
            
            for (RIFieldDataSetComponent *component in field.dataSet) {
                [contentArray addObject:component.value];
            }
            
            JAGenderComponent *gender = [JAGenderComponent getNewJAGenderComponent];
            [gender initSegmentedControl:[contentArray copy]];
            
            gender.layer.cornerRadius = 4.0f;
            gender.labelText.text = field.label;
            gender.field = field;
            
            CGRect frame = gender.frame;
            frame.origin.y = startingY;
            gender.frame = frame;
            startingY += (gender.frame.size.height + 8.0f);
            
            [formViews addObject:gender];
        }
        else if ([field.type isEqualToString:@"checkbox"])
        {
            JACheckBoxComponent *check = [JACheckBoxComponent getNewJACheckBoxComponent];
            check.field = field;
            
            check.layer.cornerRadius = 4.0f;
            CGRect frame = check.frame;
            frame.origin.y = startingY;
            check.frame = frame;
            startingY += (check.frame.size.height + 8.0f);
            
            check.labelText.text = field.label;
            
            [formViews addObject:check];
        }
    }
    
    return formViews;
}

+(BOOL)hasErrors:(NSArray*)views
{
    BOOL hasErrors = NO;
    
    for (id obj in views)
    {
        if ([obj isKindOfClass:[JATextField class]])
        {
            if (![obj isValid])
            {
                hasErrors = YES;
                break;
            }
        }
    }
    
    return hasErrors;
}

+(NSDictionary*)getValues:(NSArray*)views form:(RIForm*)form
{
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    
    for (UIView *view in views)
    {
        if ([view isKindOfClass:[JABirthDateComponent class]])
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"dd-MM-yyyy"];
            NSString *dateString = [dateFormatter stringFromDate:((JABirthDateComponent *)view).datePicker.date];
            
            NSArray *components = [dateString componentsSeparatedByString:@"-"];
            
            if(VALID_NOTEMPTY(form, RIForm) && VALID_NOTEMPTY([form fields], NSArray))
            {
                for (RIField *field in [form fields])
                {
                    if ([field.type isEqualToString:@"integer"])
                    {
                        if ([field.key isEqualToString:@"day"])
                        {
                            NSDictionary *dicDay = @{field.name : components[0]};
                            [tempDic addEntriesFromDictionary:dicDay];
                        }
                        else if ([field.key isEqualToString:@"month"])
                        {
                            NSDictionary *dicMonth = @{field.name : components[1]};
                            [tempDic addEntriesFromDictionary:dicMonth];
                        }
                        else if ([field.key isEqualToString:@"year"])
                        {
                            NSDictionary *dicYear = @{field.name : components[2]};
                            [tempDic addEntriesFromDictionary:dicYear];
                        }
                    }
                }
            }
        }
        else if ([view isKindOfClass:[JAGenderComponent class]])
        {
            NSInteger index = ((JAGenderComponent *)view).segmentedControl.selectedSegmentIndex;
            NSString *selectedGender = [((JAGenderComponent *)view).segmentedControl titleForSegmentAtIndex:index];
            
            NSDictionary *temp = @{((JAGenderComponent *)view).field.name : selectedGender};
            [tempDic addEntriesFromDictionary:temp];
        }
        else if ([view isKindOfClass:[JACheckBoxComponent class]])
        {
            if (((JACheckBoxComponent *)view).switchComponent.on)
            {
                NSDictionary *temp = @{((JACheckBoxComponent *)view).field.name : @"YES"};
                [tempDic addEntriesFromDictionary:temp];
            }
            else
            {
                NSDictionary *temp = @{((JACheckBoxComponent *)view).field.name : @"NO"};
                [tempDic addEntriesFromDictionary:temp];
            }
        }
        else if ([view isKindOfClass:[JATextField class]])
        {
            NSDictionary *temp = @{((JATextField *)view).field.name : ((JATextField *)view).textField.text};
            [tempDic addEntriesFromDictionary:temp];
        }
    }
    
    return [tempDic copy];
}

@end
