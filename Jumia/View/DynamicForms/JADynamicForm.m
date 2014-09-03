//
//  JADynamicForm.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JADynamicForm.h"
#import "RIForm.h"
#import "RIFieldDataSetComponent.h"
#import "RIFieldOption.h"

@interface JADynamicForm ()
<UITextFieldDelegate>

@property (nonatomic, strong) UITextField* currentTextField;

@end

@implementation JADynamicForm

-(id)initWithForm:(RIForm*)form startingPosition:(CGFloat)startingY;
{
    self = [super init];
    if(self)
    {
        self.form = form;
        [self generateForm:[[[form fields] array] copy] startingY:startingY];
    }
    return self;
}

- (void)generateForm:(NSArray*)fields startingY:(CGFloat)startingY
{
    RIField *dayField = nil;
    RIField *monthField = nil;
    RIField *yearField = nil;
    NSInteger birthdayFieldPosition = -1;
    JABirthDateComponent *birthDateComponent = [JABirthDateComponent getNewJABirthDateComponent];
    
    NSInteger lastTextFieldIndex = 0;
    self.formViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < [fields count]; i++)
    {
        RIField *field = [fields objectAtIndex:i];
        
        if ([@"string" isEqualToString:field.type] || [@"email" isEqualToString:field.type])
        {
            if(!([@"address-form" isEqualToString:[self.form uid]] && [@"city" isEqualToString:field.key]))
            {
                JATextFieldComponent *textField = [JATextFieldComponent getNewJATextFieldComponent];
                [textField setupWithField:field];
                [textField.textField setDelegate:self];
                [textField.textField setReturnKeyType:UIReturnKeyNext];
            
                if([@"email" isEqualToString:field.type])
                {
                    [textField.textField setKeyboardType:UIKeyboardTypeEmailAddress];
                }
                
                CGRect frame = textField.frame;
                frame.origin.y = startingY;
                textField.frame = frame;
                startingY += textField.frame.size.height;
                
                [textField.textField setTag:i];
                [textField setTag:i];
                
                lastTextFieldIndex = [self.formViews count];
                [self.formViews addObject:textField];
            }
        }
        else if ([@"password" isEqualToString:field.type] || [@"password2" isEqualToString:field.type])
        {
            JATextFieldComponent *textField = [JATextFieldComponent getNewJATextFieldComponent];
            [textField setupWithField:field];
            [textField.textField setDelegate:self];
            [textField.textField setReturnKeyType:UIReturnKeyNext];
            [textField.textField setSecureTextEntry:YES];
            
            CGRect frame = textField.frame;
            frame.origin.y = startingY;
            textField.frame = frame;
            startingY += textField.frame.size.height;
            
            [textField.textField setTag:i];
            [textField setTag:i];
            
            lastTextFieldIndex = [self.formViews count];
            [self.formViews addObject:textField];
        }
        else if ([field.type isEqualToString:@"integer"] || [field.type isEqualToString:@"number"])
        {
            if([@"day" isEqualToString:field.key] || [@"month" isEqualToString:field.key] || [@"year" isEqualToString:field.key])
            {
                if([@"day" isEqualToString:field.key])
                {
                    dayField = field;
                }
                else if([@"month" isEqualToString:field.key])
                {
                    monthField = field;
                }
                else if([@"year" isEqualToString:field.key])
                {
                    yearField = field;
                }
                if(-1 == birthdayFieldPosition)
                {
                    birthdayFieldPosition = i;
                    
                    CGRect frame = birthDateComponent.frame;
                    frame.origin.y = startingY;
                    birthDateComponent.frame = frame;
                    startingY += birthDateComponent.frame.size.height;
                    
                    [birthDateComponent.textField setTag:birthdayFieldPosition];
                    [birthDateComponent setTag:birthdayFieldPosition];
                }
            }
            else
            {
                JATextFieldComponent *textField = [JATextFieldComponent getNewJATextFieldComponent];
                [textField setupWithField:field];
                [textField.textField setDelegate:self];
                [textField.textField setReturnKeyType:UIReturnKeyNext];
                [textField.textField setKeyboardType:UIKeyboardTypeNumberPad];
                
                CGRect frame = textField.frame;
                frame.origin.y = startingY;
                textField.frame = frame;
                startingY += textField.frame.size.height;
                
                [textField.textField setTag:i];
                [textField setTag:i];
                
                lastTextFieldIndex = [self.formViews count];
                [self.formViews addObject:textField];
            }
        }
        else if ([@"radio" isEqualToString:field.type] || [@"list" isEqualToString:field.type])
        {
            if(!([@"address-form" isEqualToString:[self.form uid]] && [@"city" isEqualToString:field.key]))
            {
                JARadioComponent *gender = [JARadioComponent getNewJARadioComponent];
                [gender setupWithField:field];
                [gender.textField setDelegate:self];
                [gender.textField setReturnKeyType:UIReturnKeyNext];
                
                CGRect frame = gender.frame;
                frame.origin.y = startingY;
                gender.frame = frame;
                startingY += gender.frame.size.height;
                
                [gender.textField setTag:i];
                [gender setTag:i];
                
                lastTextFieldIndex = [self.formViews count];
                [self.formViews addObject:gender];
            }
        }
        else if ([@"checkbox" isEqualToString:field.type])
        {
            if([@"Alice_Module_Mobapi_Form_Ext1m4_Customer_RegistrationForm" isEqualToString:[self.form uid]] && [@"newsletter_categories_subscribed" isEqualToString:field.key])
            {
                JACheckBoxComponent *check = [JACheckBoxComponent getNewJACheckBoxComponent];
                [check setupWithField:field];
                
                CGRect frame = check.frame;
                frame.origin.y = startingY;
                check.frame = frame;
                startingY += check.frame.size.height;
                
                [check setTag:i];
                [self.formViews addObject:check];
            }
            else
            {
                if(VALID_NOTEMPTY(field.options, NSOrderedSet))
                {
                    JACheckBoxWithOptionsComponent *checkWithOptions = [JACheckBoxWithOptionsComponent getNewJACheckBoxWithOptionsComponent];
                    [checkWithOptions setupWithField:field];
                    
                    CGRect frame = checkWithOptions.frame;
                    frame.origin.y = startingY;
                    checkWithOptions.frame = frame;
                    startingY += checkWithOptions.frame.size.height;
                    
                    [checkWithOptions setTag:i];
                    [self.formViews addObject:checkWithOptions];
                }
                else
                {
                    JACheckBoxComponent *check = [JACheckBoxComponent getNewJACheckBoxComponent];
                    [check setupWithField:field];
                    
                    CGRect frame = check.frame;
                    frame.origin.y = startingY;
                    check.frame = frame;
                    startingY += check.frame.size.height;
                    
                    check.labelText.text = field.label;
                    
                    [check setTag:i];
                    [self.formViews addObject:check];
                }
            }
        }
        else if ([@"hidden" isEqualToString:field.type])
        {
        }
    }
    
    if(-1 != birthdayFieldPosition && VALID_NOTEMPTY(dayField, RIField) && VALID_NOTEMPTY(monthField, RIField) && VALID_NOTEMPTY(yearField, RIField))
    {
        [birthDateComponent setupWithLabel:@"Birthday" day:dayField month:monthField year:yearField];
        [birthDateComponent.textField setDelegate:self];
        [birthDateComponent.textField setReturnKeyType:UIReturnKeyNext];
        
        if(lastTextFieldIndex >= birthdayFieldPosition)
        {
            lastTextFieldIndex++;
        }
        
        [self.formViews insertObject:birthDateComponent atIndex:birthdayFieldPosition];
    }
    
    if(lastTextFieldIndex < [self.formViews count])
    {
        UIView *view = [self.formViews objectAtIndex:lastTextFieldIndex];
        if([view isKindOfClass:[JATextFieldComponent class]])
        {
            JATextFieldComponent *lastTextField = (JATextFieldComponent*) view;
            [lastTextField.textField setReturnKeyType:UIReturnKeyDone];
        }
        else if([view isKindOfClass:[JABirthDateComponent class]])
        {
            JABirthDateComponent *lastTextField = (JABirthDateComponent*) view;
            [lastTextField.textField setReturnKeyType:UIReturnKeyDone];
        }
    }
}

-(void)validateFields:(NSDictionary*)errors
{
    NSArray *errorKeys = [errors allKeys];
    for (NSString *errorKey in errorKeys)
    {
        if(VALID_NOTEMPTY([errors objectForKey:errorKey], NSArray))
        {
            NSArray *errorArray = [errors objectForKey:errorKey];
            [self setError:[errorArray componentsJoinedByString:@","] inFieldKey:errorKey];
        }
        else if(VALID_NOTEMPTY([errors objectForKey:errorKey], NSDictionary))
        {
            NSDictionary *errorDictionary = [errors objectForKey:errorKey];
                        NSArray *errorDictionaryKeys = [errorDictionary allKeys];
            NSString *errorString = nil;
            for(NSString *errorDictionaryKey in errorDictionaryKeys)
            {
                if(VALID_NOTEMPTY(errorString, NSString))
                {
                    errorString = [NSString stringWithFormat:@"%@, %@", errorString, [errorDictionary objectForKey:errorDictionaryKey]];
                }
                else
                {
                    errorString =  [errorDictionary objectForKey:errorDictionaryKey];
                }
            }
            
            [self setError:[errors objectForKey:errorKey] inFieldKey:errorKey];
        }
        else if(VALID_NOTEMPTY([errors objectForKey:errorKey], NSString))
        {
            [self setError:[errors objectForKey:errorKey] inFieldKey:errorKey];
        }
    }
}

-(void)setError:(NSString*)error inFieldKey:(NSString*)key
{
    for (id view in self.formViews)
    {
        if ([view isKindOfClass:[JATextFieldComponent class]])
        {
            JATextFieldComponent *textFieldView = (JATextFieldComponent*)view;
            if([key isEqualToString:[[textFieldView field] key]])
            {
                [textFieldView setError:error];
                break;
            }
        }
        else if ([view isKindOfClass:[JABirthDateComponent class]])
        {
            JABirthDateComponent *birthDateComponent = (JABirthDateComponent*)view;
            if([key isEqualToString:[[birthDateComponent dayField] key]] ||
               [key isEqualToString:[[birthDateComponent monthField] key]] ||
               [key isEqualToString:[[birthDateComponent yearField] key]] )
            {
                [birthDateComponent setError:error];
                break;
            }
        }
        else if ([view isKindOfClass:[JARadioComponent class]])
        {
            JARadioComponent *radioComponent = (JARadioComponent*)view;
            if([key isEqualToString:[[radioComponent field] key]])
            {
                [radioComponent setError:error];
                break;
            }
        }
    }
}

-(BOOL)checkErrors
{
    BOOL hasErrors = NO;
    if(VALID_NOTEMPTY(self.formViews, NSMutableArray))
    {
        for (id obj in self.formViews)
        {
            if ([obj isKindOfClass:[JATextFieldComponent class]] || [obj isKindOfClass:[JABirthDateComponent class]] || [obj isKindOfClass:[JARadioComponent class]])
            {
                if (![obj isValid])
                {
                    hasErrors = YES;
                }
            }
        }
    }
    return hasErrors;
}

-(NSDictionary*)getValues
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    JARadioComponent *genderComponent = nil;
    JACheckBoxComponent *categoriesNewsletterComponent = nil;
    
    if(VALID_NOTEMPTY(self.formViews, NSMutableArray))
    {
        for (UIView *view in self.formViews)
        {
            if ([view isKindOfClass:[JABirthDateComponent class]])
            {
                JABirthDateComponent *birthdateComponent = (JABirthDateComponent*) view;
                
                if([birthdateComponent.dayField.required boolValue]|| VALID_NOTEMPTY(birthdateComponent.dayField.value, NSString))
                {
                    [parameters setValue:birthdateComponent.dayField.value forKey:birthdateComponent.dayField.name];
                }
                
                if([birthdateComponent.monthField.required boolValue] || VALID_NOTEMPTY(birthdateComponent.monthField.value, NSString))
                {
                    [parameters setValue:birthdateComponent.monthField.value forKey:birthdateComponent.monthField.name];
                }
                
                if([birthdateComponent.yearField.required boolValue] || VALID_NOTEMPTY(birthdateComponent.yearField.value, NSString))
                {
                    [parameters setValue:birthdateComponent.yearField.value forKey:birthdateComponent.yearField.name];
                }
            }
            else if ([view isKindOfClass:[JARadioComponent class]])
            {
                JARadioComponent *radioComponent = (JARadioComponent*) view;
                
                if([@"Alice_Module_Mobapi_Form_Ext1m4_Customer_RegistrationForm" isEqualToString:[self.form uid]] && [@"gender" isEqualToString:radioComponent.field.key])
                {
                    genderComponent = radioComponent;
                }
                
                if([@"address-form" isEqualToString:[self.form uid]] && [@"fk_customer_address_city" isEqualToString:radioComponent.field.key])
                {
                    [parameters setValue:radioComponent.textField.text forKey:@"Alice_Module_Customer_Model_AddressForm[city]"];
                }
                
                if([radioComponent.field.required boolValue] || VALID_NOTEMPTY(radioComponent.field.value, NSString))
                {
                    [parameters setValue:radioComponent.field.value forKey:radioComponent.field.name];
                }
            }
            else if ([view isKindOfClass:[JACheckBoxComponent class]])
            {
                JACheckBoxComponent *checkBoxComponent = (JACheckBoxComponent*) view;
                
                if([@"Alice_Module_Mobapi_Form_Ext1m4_Customer_RegistrationForm" isEqualToString:[self.form uid]] && [@"newsletter_categories_subscribed" isEqualToString:checkBoxComponent.field.key])
                {
                    categoriesNewsletterComponent = checkBoxComponent;
                }
                
                if (checkBoxComponent.switchComponent.on)
                {
                    [parameters setValue:@"1" forKey:checkBoxComponent.field.name];
                }
                else if([checkBoxComponent.field.required boolValue])
                {
                    [parameters setValue:@"0" forKey:checkBoxComponent.field.name];
                }
            }
            else if ([view isKindOfClass:[JACheckBoxWithOptionsComponent class]])
            {
                JACheckBoxWithOptionsComponent *checkBoxWithOptionsComponent = (JACheckBoxWithOptionsComponent*) view;
                if(VALID_NOTEMPTY(checkBoxWithOptionsComponent.values, NSMutableDictionary))
                {
                    [parameters addEntriesFromDictionary:checkBoxWithOptionsComponent.values];
                }
            }
            else if ([view isKindOfClass:[JATextFieldComponent class]])
            {
                JATextFieldComponent *textFieldComponent = (JATextFieldComponent*) view;
                if([textFieldComponent.field.required boolValue] || VALID_NOTEMPTY(textFieldComponent.field.value, NSString))
                {
                    [parameters setValue:textFieldComponent.textField.text forKey:textFieldComponent.field.name];
                }
                
                if([@"address-form" isEqualToString:[self.form uid]] && [@"fk_customer_address_city" isEqualToString:textFieldComponent.field.key])
                {
                    [parameters setValue:textFieldComponent.textField.text forKey:@"Alice_Module_Customer_Model_AddressForm[city]"];
                }
            }
        }
    }
    
    if(VALID_NOTEMPTY(genderComponent, JARadioComponent) && VALID_NOTEMPTY(categoriesNewsletterComponent, JACheckBoxComponent))
    {
        NSString *selectedGenderValue = [genderComponent.field value];
        NSString *selectedCategoriesNewsletterValue = [categoriesNewsletterComponent.field value];
        if(VALID_NOTEMPTY(selectedGenderValue, NSString) && VALID_NOTEMPTY(selectedCategoriesNewsletterValue, NSString))
        {
            NSArray *categoriesNewsletterOptions = [[[categoriesNewsletterComponent.field options] array] copy];
            for(RIFieldOption *categoriesNewsletterOption in categoriesNewsletterOptions)
            {
                if(NSNotFound != [[[categoriesNewsletterOption label] lowercaseString] rangeOfString:[selectedGenderValue lowercaseString]].location)
                {
                    [parameters setValue:categoriesNewsletterOption.value forKey:categoriesNewsletterComponent.field.name];
                    break;
                }
            }
        }
    }
    
    return [parameters copy];
}

-(void)resetValues
{
    if(VALID_NOTEMPTY(self.formViews, NSMutableArray))
    {
        for (UIView *view in self.formViews)
        {
            if ([view isKindOfClass:[JABirthDateComponent class]])
            {
                JABirthDateComponent *birthdateComponent = (JABirthDateComponent*) view;
                
                [birthdateComponent.dayField setValue:@""];
                [birthdateComponent.monthField setValue:@""];
                [birthdateComponent.yearField setValue:@""];
            }
            else if ([view isKindOfClass:[JARadioComponent class]])
            {
                JARadioComponent *radioComponent = (JARadioComponent*) view;
                
                [radioComponent.field setValue:@""];
            }
            else if ([view isKindOfClass:[JACheckBoxComponent class]])
            {
                JACheckBoxComponent *checkBoxComponent = (JACheckBoxComponent*) view;
                
                [checkBoxComponent.field setValue:@""];
            }
            else if ([view isKindOfClass:[JATextFieldComponent class]])
            {
                JATextFieldComponent *textFieldComponent = (JATextFieldComponent*) view;
                
                [textFieldComponent.field setValue:@""];
            }
        }
    }
}

-(void)resignResponder
{
    if(VALID_NOTEMPTY(self.currentTextField, UITextField))
    {
        [self.currentTextField resignFirstResponder];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(lostFocus)]) {
        [self.delegate performSelector:@selector(lostFocus) withObject:nil];
    }
    
    self.currentTextField = nil;
}

-(UIView*)viewWithTag:(NSInteger) tag
{
    UIView *view = nil;
    for(UIView *formView in self.formViews)
    {
        if(tag == formView.tag)
        {
            view = formView;
            break;
        }
    }
    return view;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UIView *nextView = [self viewWithTag:textField.tag + 1];
    if([nextView isKindOfClass:[JATextFieldComponent class]])
    {
        JATextFieldComponent *textField = (JATextFieldComponent *) nextView;
        [textField.textField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(lostFocus)]) {
            [self.delegate performSelector:@selector(lostFocus) withObject:nil];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    BOOL textFieldShouldBeginEditing = YES;
    
    self.currentTextField = textField;

    UIView *view = [self viewWithTag:textField.tag];
    if([view respondsToSelector:@selector(cleanError)])
    {
        [view performSelector:@selector(cleanError) withObject:nil];
    }
    
    if([view isKindOfClass:[JATextFieldComponent class]])
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(changedFocus:)]) {
            [self.delegate performSelector:@selector(changedFocus:) withObject:[self viewWithTag:textField.tag]];
        }
    }
    else if([view isKindOfClass:[JABirthDateComponent class]])
    {
        textFieldShouldBeginEditing = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(openDatePicker:)]) {
            [self.delegate performSelector:@selector(openDatePicker:) withObject:[self viewWithTag:textField.tag]];
        }
    }
    else if([view isKindOfClass:[JARadioComponent class]])
    {
        textFieldShouldBeginEditing = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(openPicker:)]) {
            [self.delegate performSelector:@selector(openPicker:) withObject:[self viewWithTag:textField.tag]];
        }
    }
    
    return textFieldShouldBeginEditing;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    BOOL textFieldShouldEndEditing = NO;
    UIView *view = [self viewWithTag:textField.tag];
    if([view isKindOfClass:[JATextFieldComponent class]])
    {
        textFieldShouldEndEditing = YES;
        
        JATextFieldComponent *textFieldView = (JATextFieldComponent*)view;
        [textFieldView setValue:textField.text];
    }
    
    return textFieldShouldEndEditing;
}

@end
