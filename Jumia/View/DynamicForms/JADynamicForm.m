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
#import "JAAddRatingView.h"
#import "JARadioRelatedComponent.h"

@interface JADynamicForm ()
<UITextFieldDelegate>

@property (nonatomic, strong) UITextField* currentTextField;

@property (nonatomic, strong) JARadioComponent *regionComponent;
@property (nonatomic, strong) JARadioComponent *cityComponent;
@property (nonatomic, strong) JARadioComponent *postcodeComponent;

@end

@implementation JADynamicForm

-(id)initWithForm:(RIForm*)form startingPosition:(CGFloat)startingY
{
    self = [super init];
    if(self)
    {
        self.hasFieldNavigation = YES;
        self.form = form;
        [self generateForm:[[[form fields] array] copy] values:nil startingY:startingY widthSize:1204.0f];
        
    }
    return self;
}

-(id)initWithForm:(RIForm*)form startingPosition:(CGFloat)startingY widthSize:(CGFloat)widthComponent hasFieldNavigation:(BOOL)hasFieldNavigation
{
    self = [super init];
    if(self)
    {
        self.hasFieldNavigation = YES;
        self.form = form;
        [self generateForm:[[[form fields] array] copy] values:nil startingY:startingY widthSize:widthComponent];
    }
    return self;
}

-(id)initWithForm:(RIForm*)form values:(NSDictionary*)values startingPosition:(CGFloat)startingY hasFieldNavigation:(BOOL)hasFieldNavigation
{
    self = [super init];
    if(self)
    {
        self.hasFieldNavigation = hasFieldNavigation;
        self.form = form;
        [self generateForm:[[[form fields] array] copy] values:values startingY:startingY widthSize:308.0f];
    }
    return self;
}

- (void)setDelegate:(id<JADynamicFormDelegate>)delegate
{
    _delegate = delegate;
    if (self.delegate && [self.delegate respondsToSelector:@selector(downloadLocalesForComponents:)]) {
        NSMutableDictionary* componentDictionary = [NSMutableDictionary new];
        if (VALID_NOTEMPTY(self.regionComponent, JARadioComponent)) {
            [componentDictionary setObject:self.regionComponent forKey:@"regionComponent"];
        }
        if (VALID_NOTEMPTY(self.cityComponent, JARadioComponent)) {
            [componentDictionary setObject:self.cityComponent forKey:@"cityComponent"];
        }
        if (VALID_NOTEMPTY(self.postcodeComponent, JARadioComponent)) {
            [componentDictionary setObject:self.postcodeComponent forKey:@"postcodeComponent"];
        }
        [self.delegate performSelector:@selector(downloadLocalesForComponents:) withObject:componentDictionary];
    }
}

- (void)generateForm:(NSArray*)fields values:(NSDictionary*)values startingY:(CGFloat)startingY widthSize:(CGFloat)widthComponent
{
    UIReturnKeyType returnKeyType = UIReturnKeyNext;
    if(!self.hasFieldNavigation)
    {
        returnKeyType = UIReturnKeyDone;
    }
    
    NSInteger lastTextFieldIndex = 0;
    self.formViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < [fields count]; i++)
    {
        RIField *field = [fields objectAtIndex:i];
        NSInteger tag = [self.formViews count];
        
        if ([@"string" isEqualToString:field.type] || [@"text" isEqualToString:field.type] || [@"email" isEqualToString:field.type])
        {
            JATextFieldComponent *textField = [JATextFieldComponent getNewJATextFieldComponent];
            [textField setupWithField:field];
            [textField.textField setDelegate:self];
            [textField.textField setReturnKeyType:returnKeyType];
            
            if([@"email" isEqualToString:field.type])
            {
                [textField.textField setKeyboardType:UIKeyboardTypeEmailAddress];
            }else{
                textField.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
            }
            
            if([@"address" isEqualToString:[self.form type]] && [textField isComponentWithKey:@"city"] && VALID_NOTEMPTY([values objectForKey:@"city"], NSString))
            {
                [textField setValue:[values objectForKey:@"city"]];
            }
            
            CGRect frame = textField.frame;
            frame.origin.y = startingY;
            textField.frame = frame;
            startingY += textField.frame.size.height;
            
            [textField.textField setTag:tag];
            [textField setTag:tag];
            
            lastTextFieldIndex = [self.formViews count];
            [self.formViews addObject:textField];
        }
        else if ([@"password" isEqualToString:field.type] || [@"password2" isEqualToString:field.type])
        {
            JATextFieldComponent *textField = [JATextFieldComponent getNewJATextFieldComponent];
            [textField setupWithField:field];
            [textField.textField setDelegate:self];
            [textField.textField setReturnKeyType:returnKeyType];
            [textField.textField setSecureTextEntry:YES];
            
            CGRect frame = textField.frame;
            frame.origin.y = startingY;
            textField.frame = frame;
            startingY += textField.frame.size.height;
            
            [textField.textField setTag:tag];
            [textField setTag:tag];
            
            lastTextFieldIndex = [self.formViews count];
            [self.formViews addObject:textField];
        }
        else if ([field.type isEqualToString:@"integer"] || [field.type isEqualToString:@"number"])
        {
            JATextFieldComponent *textField = [JATextFieldComponent getNewJATextFieldComponent];
            [textField setupWithField:field];
            [textField.textField setDelegate:self];
            [textField.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
            
            if ([@"phone" isEqualToString:field.key]) {
                textField.textField.keyboardType = UIKeyboardTypePhonePad;
            }
            
            [textField.textField setReturnKeyType:returnKeyType];
            
            CGRect frame = textField.frame;
            frame.origin.y = startingY;
            textField.frame = frame;
            startingY += textField.frame.size.height;

            [textField.textField setTag:tag];
            [textField setTag:tag];
            
            lastTextFieldIndex = [self.formViews count];
            [self.formViews addObject:textField];
        }
        else if ([field.type isEqualToString:@"date"])
        {
            JABirthDateComponent *birthDateComponent = [JABirthDateComponent getNewJABirthDateComponent];
            [birthDateComponent setupWithField:field];
            [birthDateComponent.textField setDelegate:self];
            [birthDateComponent.textField setReturnKeyType:returnKeyType];
            
            CGRect frame = birthDateComponent.frame;
            frame.origin.y = startingY;
            birthDateComponent.frame = frame;
            startingY += birthDateComponent.frame.size.height;
            
            [birthDateComponent.textField setTag:tag];
            [birthDateComponent setTag:tag];
            lastTextFieldIndex = [self.formViews count];
            [self.formViews addObject:birthDateComponent];
        }
        else if ([@"radio" isEqualToString:field.type] || [@"list" isEqualToString:field.type])
        {
            JARadioComponent *radioComponent = [JARadioComponent getNewJARadioComponent];
            [radioComponent setupWithField:field];
            [radioComponent.textField setDelegate:self];
            [radioComponent.textField setReturnKeyType:returnKeyType];
            
            CGRect frame = radioComponent.frame;
            frame.origin.y = startingY;
            radioComponent.frame = frame;
            startingY += radioComponent.frame.size.height;
            
            
            [radioComponent.textField setTag:tag];
            [radioComponent setTag:tag];
            
            lastTextFieldIndex = [self.formViews count];
            [self.formViews addObject:radioComponent];
            
            if([radioComponent isComponentWithKey:@"region"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
            {
                self.regionComponent = radioComponent;
            }
            else if([radioComponent isComponentWithKey:@"city"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
            {
                self.cityComponent = radioComponent;
            }
            else if([radioComponent isComponentWithKey:@"postcode"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
            {
                self.postcodeComponent = radioComponent;
            }
        }
        else if ([@"related_number" isEqualToString:field.type])
        {
            //we only accept two options, no more, no less
            if (2 == field.relatedFields.count) {
                
                JATextFieldComponent *textField = [JATextFieldComponent getNewJATextFieldComponent];
                [textField setupWithField:field];
                [textField.textField setDelegate:self];
                [textField.textField setReturnKeyType:returnKeyType];
                
                CGRect frame = textField.frame;
                frame.origin.y = startingY;
                textField.frame = frame;
                startingY += textField.frame.size.height;
                
                [textField.textField setTag:tag];
                [textField setTag:tag];
                
                lastTextFieldIndex = [self.formViews count];
                [self.formViews addObject:textField];
                
                JARadioRelatedComponent* radioRelated = [JARadioRelatedComponent getNewJARadioRelatedComponent];
                [radioRelated setupWithField:field];
                
                frame = radioRelated.frame;
                frame.origin.y = startingY;
                radioRelated.frame = frame;
                startingY += radioRelated.frame.size.height;
                
                [self.formViews addObject:radioRelated];
                
                textField.relatedComponent = radioRelated;
            }
        }
        else if (0 != [field.type rangeOfString:@"checkbox"].length)
        {
            if([@"register" isEqualToString:self.form.type] && [@"newsletter_categories_subscribed" isEqualToString:field.key])
            {
                JACheckBoxComponent *check = [JACheckBoxComponent getNewJACheckBoxComponent];
                [check setupWithField:field];
                
                CGRect frame = check.frame;
                frame.origin.y = startingY;
                check.frame = frame;
                startingY += check.frame.size.height;
                
                [check setTag:tag];
                [self.formViews addObject:check];
            }
            else
            {
                if(VALID_NOTEMPTY(field.options, NSOrderedSet))
                {
                    
                    JACheckBoxWithOptionsComponent *checkWithOptions = [[JACheckBoxWithOptionsComponent alloc] initWithFrame:CGRectMake(0.0f, startingY, widthComponent, 0.0f)];
                    [checkWithOptions setupWithField:field];
                    
                    CGRect frame = checkWithOptions.frame;
                    frame.origin.y = startingY;
                    checkWithOptions.frame = frame;
                    startingY += checkWithOptions.frame.size.height;
                    
                    [checkWithOptions setTag:tag];
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

                    [check setTag:tag];
                    [self.formViews addObject:check];
                }
            }
        }
        else if ([@"hidden" isEqualToString:field.type])
        {
        }
        else if ([@"array" isEqualToString:field.type])
        {
            if ([@"ratings" isEqualToString:field.key] && VALID_NOTEMPTY(field.ratingStars, NSOrderedSet)) {
                
                for (RIFieldRatingStars *ratingStars in field.ratingStars)
                {
                    JAAddRatingView *stars = [JAAddRatingView getNewJAAddRatingView];
                    [stars setupWithFieldRatingStars:ratingStars];
                    
                    CGRect frame = stars.frame;
                    frame.origin.y = startingY;
                    frame.origin.x = 0.0;
                    frame.size.width = widthComponent;
                    [stars setFrame:frame];
                    
                    [self.formViews addObject:stars];
                    startingY += stars.frame.size.height;
                    
                }
            }
        }
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
    self.firstErrorInFields = nil;
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
                    if (ISEMPTY(self.firstErrorInFields)) {
                        if ([obj respondsToSelector:@selector(currentErrorMessage)]) {
                            self.firstErrorInFields = [obj currentErrorMessage];
                        }
                    }
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
                if(([@"register" isEqualToString:[self.form type]] || [@"address" isEqualToString:[self.form type]]) && [radioComponent isComponentWithKey:@"gender"])
                {
                    genderComponent = radioComponent;
                }
                
                if(VALID_NOTEMPTY([radioComponent getValues], NSDictionary))
                {
                    [parameters addEntriesFromDictionary:[radioComponent getValues]];
                }
            } else if([view isKindOfClass:[JARadioRelatedComponent class]])
            {
                JARadioRelatedComponent* radioRelatedComponent = (JARadioRelatedComponent*) view;
                
                [parameters addEntriesFromDictionary:[radioRelatedComponent getValues]];
            }
            else if ([view isKindOfClass:[JACheckBoxComponent class]])
            {
                JACheckBoxComponent *checkBoxComponent = (JACheckBoxComponent*) view;
                
                if([@"register" isEqualToString:[self.form type]] && [checkBoxComponent isComponentWithKey:@"newsletter_categories_subscribed"])
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
                if([@"address" isEqualToString:[self.form type]] && [textFieldComponent isComponentWithKey:@"city"])
                {
                    [parameters setValue:textFieldComponent.textField.text forKey:[self getFieldNameForKey:@"city"]];
                }
            }
            else if ([view isKindOfClass:[JAAddRatingView class]])
            {
                JAAddRatingView* addRatingView = (JAAddRatingView*) view;

                NSString *key = [NSString stringWithFormat:@"%@[%@]", addRatingView.fieldRatingStars.field.name, addRatingView.fieldRatingStars.type];
                NSString* rating = [NSString stringWithFormat:@"%ld",(long)addRatingView.rating];
                [parameters addEntriesFromDictionary:@{key: rating}];
                NSLog(@"%@",parameters);
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

-(void)setRegionValue:(RILocale*)region
{
    for(UIView *formView in self.formViews)
    {
        if([formView isKindOfClass:[JARadioComponent class]])
        {
            JARadioComponent *radioComponent = (JARadioComponent*) formView;
            if([radioComponent isComponentWithKey:@"region"])
            {
                [radioComponent setLocaleValue:region];
            }
            else if([radioComponent isComponentWithKey:@"city"])
            {
                [radioComponent setLocaleValue:nil];
            }
            else if ([radioComponent isComponentWithKey:@"postcode"])
            {
                [radioComponent setLocaleValue:nil];
            }
        }
    }
}

-(void)setCityValue:(RILocale*)city
{
    for(UIView *formView in self.formViews)
    {
        if([formView isKindOfClass:[JARadioComponent class]])
        {
            JARadioComponent *radioComponent = (JARadioComponent*) formView;
            if([radioComponent isComponentWithKey:@"city"])
            {
                [radioComponent setLocaleValue:city];
            }
            else if ([radioComponent isComponentWithKey:@"postcode"])
            {
                [radioComponent setLocaleValue:nil];
            }
        }
    }
}

-(void)setPostcodeValue:(RILocale*)postcode
{
    for(UIView *formView in self.formViews)
    {
        if([formView isKindOfClass:[JARadioComponent class]])
        {
            JARadioComponent *radioComponent = (JARadioComponent*) formView;
            if([radioComponent isComponentWithKey:@"postcode"])
            {
                [radioComponent setLocaleValue:postcode];
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
    if(self.hasFieldNavigation && [nextView isKindOfClass:[JATextFieldComponent class]])
    {
        JATextFieldComponent *textField = (JATextFieldComponent *) nextView;
        [textField.textField becomeFirstResponder];
    }
    else
    {
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
        [self resignResponder];
        
        textFieldShouldBeginEditing = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(openDatePicker:)]) {
            [self.delegate performSelector:@selector(openDatePicker:) withObject:[self viewWithTag:textField.tag]];
        }
    }
    else if([view isKindOfClass:[JARadioComponent class]])
    {
        [self resignResponder];
        
        textFieldShouldBeginEditing = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(openPicker:)]) {
            [self.delegate performSelector:@selector(openPicker:) withObject:[self viewWithTag:textField.tag]];
        }
    }
    
    self.currentTextField = textField;
    
    return textFieldShouldBeginEditing;
}

- (NSString*)getFieldNameForKey:(NSString*)key
{
    NSString *fieldId = @"";
    if(VALID_NOTEMPTY(self.form, RIForm) && VALID_NOTEMPTY([self.form fields], NSOrderedSet))
    {
        NSArray *fields = [[self.form fields] array];
        for (int i = 0; i < [fields count]; i++)
        {
            RIField *field = [fields objectAtIndex:i];
            if([key isEqualToString:[field key]])
            {
                fieldId = [field name];
                break;
            }
        }
    }
    return fieldId;
}


@end
