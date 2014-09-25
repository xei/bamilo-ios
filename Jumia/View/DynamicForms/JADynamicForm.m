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
        [self generateForm:[[[form fields] array] copy] values:nil startingY:startingY];
    }
    return self;
}

-(id)initWithForm:(RIForm*)form delegate:(id<JADynamicFormDelegate>)delegate startingPosition:(CGFloat)startingY;
{
    self = [super init];
    if(self)
    {
        self.form = form;
        self.delegate = delegate;
        [self generateForm:[[[form fields] array] copy] values:nil startingY:startingY];
    }
    return self;
}

-(id)initWithForm:(RIForm*)form delegate:(id<JADynamicFormDelegate>)delegate values:(NSDictionary*)values startingPosition:(CGFloat)startingY;
{
    self = [super init];
    if(self)
    {
        self.form = form;
        self.delegate = delegate;
        [self generateForm:[[[form fields] array] copy] values:values startingY:startingY];
    }
    return self;
}

- (void)generateForm:(NSArray*)fields values:(NSDictionary*)values startingY:(CGFloat)startingY
{
    RIField *dayField = nil;
    RIField *monthField = nil;
    RIField *yearField = nil;
    NSInteger birthdayFieldPosition = -1;
    JABirthDateComponent *birthDateComponent = [JABirthDateComponent getNewJABirthDateComponent];
    JARadioComponent *regionsComponent = nil;
    JARadioComponent *citiesComponent = nil;
    
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
                JARadioComponent *radioComponent = [JARadioComponent getNewJARadioComponent];
                [radioComponent setupWithField:field];
                [radioComponent.textField setDelegate:self];
                [radioComponent.textField setReturnKeyType:UIReturnKeyNext];
                
                CGRect frame = radioComponent.frame;
                frame.origin.y = startingY;
                radioComponent.frame = frame;
                startingY += radioComponent.frame.size.height;
                
                [radioComponent.textField setTag:i];
                [radioComponent setTag:i];
                
                lastTextFieldIndex = [self.formViews count];
                [self.formViews addObject:radioComponent];
                
                if([radioComponent isComponentWithKey:@"fk_customer_address_region"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
                {
                    regionsComponent = radioComponent;
                }
                else if([radioComponent isComponentWithKey:@"fk_customer_address_city"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
                {
                    citiesComponent = radioComponent;
                }
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
    
    if(VALID_NOTEMPTY(values, NSDictionary))
    {
        [self setValues:values];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadRegions:cities:)]) {
        [self.delegate performSelector:@selector(downloadRegions:cities:) withObject:regionsComponent withObject:citiesComponent];
    }
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
            if([textFieldView isComponentWithKey:key])
            {
                [textFieldView setError:error];
                break;
            }
        }
        else if ([view isKindOfClass:[JABirthDateComponent class]])
        {
            JABirthDateComponent *birthDateComponent = (JABirthDateComponent*)view;
            if([birthDateComponent isComponentWithKey:key])
            {
                [birthDateComponent setError:error];
                break;
            }
        }
        else if ([view isKindOfClass:[JARadioComponent class]])
        {
            JARadioComponent *radioComponent = (JARadioComponent*)view;
            if([radioComponent isComponentWithKey:key])
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
                [parameters addEntriesFromDictionary:[birthdateComponent getValues]];
            }
            else if ([view isKindOfClass:[JARadioComponent class]])
            {
                JARadioComponent *radioComponent = (JARadioComponent*) view;
                
                if([@"Alice_Module_Mobapi_Form_Ext1m4_Customer_RegistrationForm" isEqualToString:[self.form uid]] && [radioComponent isComponentWithKey:@"gender"])
                {
                    genderComponent = radioComponent;
                }
                
                if([@"address-form" isEqualToString:[self.form uid]] && [radioComponent isComponentWithKey:@"fk_customer_address_city"])
                {
                    [parameters setValue:radioComponent.textField.text forKey:@"Alice_Module_Customer_Model_AddressForm[city]"];
                }
                
                if(VALID_NOTEMPTY([radioComponent getValues], NSDictionary))
                {
                    [parameters addEntriesFromDictionary:[radioComponent getValues]];
                }
            }
            else if ([view isKindOfClass:[JACheckBoxComponent class]])
            {
                JACheckBoxComponent *checkBoxComponent = (JACheckBoxComponent*) view;
                
                if([@"Alice_Module_Mobapi_Form_Ext1m4_Customer_RegistrationForm" isEqualToString:[self.form uid]] && [checkBoxComponent isComponentWithKey:@"newsletter_categories_subscribed"])
                {
                    categoriesNewsletterComponent = checkBoxComponent;
                }
                
                NSDictionary *checkBoxParameters = [checkBoxComponent getValues];
                if(VALID_NOTEMPTY(checkBoxParameters, NSDictionary))
                {
                    [parameters addEntriesFromDictionary:checkBoxParameters];
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
                
                if(VALID_NOTEMPTY([textFieldComponent getValues], NSDictionary))
                {
                    [parameters addEntriesFromDictionary:[textFieldComponent getValues]];
                }
                if([@"address-form" isEqualToString:[self.form uid]] && [textFieldComponent isComponentWithKey:@"fk_customer_address_city"])
                {
                    [parameters setValue:textFieldComponent.textField.text forKey:@"Alice_Module_Customer_Model_AddressForm[city]"];
                }
            }
        }
    }
    
    if(VALID_NOTEMPTY(genderComponent, JARadioComponent) && VALID_NOTEMPTY(categoriesNewsletterComponent, JACheckBoxComponent))
    {
        NSString *selectedGenderValue = [genderComponent getSelectedValue];
        BOOL isCategoriesNewsletterComponentOn = [categoriesNewsletterComponent isCheckBoxOn];
        
        if(VALID_NOTEMPTY(selectedGenderValue, NSString) && isCategoriesNewsletterComponentOn)
        {
            NSArray *categoriesNewsletterOptions = [[categoriesNewsletterComponent getOptions] copy];
            for(RIFieldOption *categoriesNewsletterOption in categoriesNewsletterOptions)
            {
                if(NSNotFound != [[[categoriesNewsletterOption label] lowercaseString] rangeOfString:[selectedGenderValue lowercaseString]].location)
                {
                    [categoriesNewsletterComponent setValue:categoriesNewsletterOption.value];
                    [parameters addEntriesFromDictionary:[categoriesNewsletterComponent getValues]];
                    break;
                }
            }
        }
    }
    
    return [parameters copy];
}

- (void)setValues:(NSDictionary *)values
{
    NSArray *valuesKeys = [values allKeys];
    if(VALID_NOTEMPTY(self.formViews, NSMutableArray))
    {
        for(NSString *key in valuesKeys)
        {
            [self setValue:[values objectForKey:key] inFieldWithKey:key];
        }
    }
}

-(void)setValue:(NSString*)value inFieldWithKey:(NSString*)key
{
    for (id view in self.formViews)
    {
        if ([view isKindOfClass:[JATextFieldComponent class]])
        {
            JATextFieldComponent *textFieldView = (JATextFieldComponent*)view;
            if([textFieldView isComponentWithKey:key])
            {
                [textFieldView setValue:value];
                break;
            }
        }
        else if ([view isKindOfClass:[JARadioComponent class]])
        {
            JARadioComponent *radioComponent = (JARadioComponent*)view;
            if([radioComponent isComponentWithKey:key])
            {
                [radioComponent setValue:value];
                break;
            }
        }
    }
}

-(void)resetValues
{
    if(VALID_NOTEMPTY(self.formViews, NSMutableArray))
    {
        for (UIView *view in self.formViews)
        {
            if([view respondsToSelector:@selector(resetValue)])
            {
                [view performSelector:@selector(resetValue) withObject:nil];
            }
        }
    }
}

-(void)setRegionValue:(RIRegion*)region
{
    for(UIView *formView in self.formViews)
    {
        if([formView isKindOfClass:[JARadioComponent class]])
        {
            JARadioComponent *radioComponent = (JARadioComponent*) formView;
            if([radioComponent isComponentWithKey:@"fk_customer_address_region"])
            {
                [radioComponent setRegionValue:region];
            }
            else if([radioComponent isComponentWithKey:@"fk_customer_address_city"])
            {
                [radioComponent setCityValue:nil];
            }
        }
    }
}

-(void)setCityValue:(RICity*)city
{
    for(UIView *formView in self.formViews)
    {
        if([formView isKindOfClass:[JARadioComponent class]])
        {
            JARadioComponent *radioComponent = (JARadioComponent*) formView;
            if([radioComponent isComponentWithKey:@"fk_customer_address_city"])
            {
                [radioComponent setCityValue:city];
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