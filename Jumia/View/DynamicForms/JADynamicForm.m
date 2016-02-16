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
@property (nonatomic, strong) JARadioComponent *newsletterGenderComponent;
@property (nonatomic, strong) JARadioComponent *phonePrefixComponent;

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
        if (VALID_NOTEMPTY(self.phonePrefixComponent, JARadioComponent)) {
            [componentDictionary setObject:self.phonePrefixComponent forKey:@"phonePrefixComponent"];
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
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:STRING_DONE
                                                                   style:UIBarButtonItemStyleBordered target:self.delegate
                                                                  action:@selector(doneClicked:)];
    
    if (!RI_IS_RTL) {
        UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil action:nil];
        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:flexBarButton ,doneButton, nil]];
    } else {
        [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
    }
    
    NSInteger lastTextFieldIndex = 0;
    self.formViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < [fields count]; i++)
    {
        RIField *field = [fields objectAtIndex:i];
        NSInteger tag = [self.formViews count];
        
        if ([@"string" isEqualToString:field.type] || [@"text" isEqualToString:field.type] || [@"email" isEqualToString:field.type])
        {
            JATextFieldComponent *textField = [[JATextFieldComponent alloc] init];
            [textField setupWithField:field];
            [textField.textField setDelegate:self];
            [textField.textField setReturnKeyType:returnKeyType];
            
            if ([@"email" isEqualToString:field.type]) {
                if (VALID_NOTEMPTY([values objectForKey:@"email"], NSString)) {
                    [textField.textField setText:[values objectForKey:@"email"]];
                }
                
                if ([field.disabled boolValue]) {
                    textField.textField.enabled = NO;
                    [textField.textField setTextColor:JABlack700Color];
                }
                
                [textField.textField setKeyboardType:UIKeyboardTypeEmailAddress];
                textField.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            } else {
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
            JATextFieldComponent *textField = [[JATextFieldComponent alloc] init];
            [textField setupWithField:field];
            [textField.textField setDelegate:self];
            [textField.textField setReturnKeyType:returnKeyType];
            [textField.textField setSecureTextEntry:YES];
            
            CGRect frame = textField.frame;
            frame.origin.y = startingY;
            textField.frame = frame;
            
            UITapGestureRecognizer *eyeGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPassword:)];
            eyeGestureRecognizer.numberOfTapsRequired = 1;
            
            UIImageView *eyeView;
            UIImage *eyeImage = [UIImage imageNamed:@"btn_eye_closed"];
            eyeView = [[UIImageView alloc] initWithImage:eyeImage];
            [eyeView setFrame:CGRectMake(0, 0, eyeImage.size.width, eyeImage.size.height)];
            
            [eyeView setUserInteractionEnabled:YES];
            [eyeView addGestureRecognizer:eyeGestureRecognizer];
            
            if (RI_IS_RTL) {
                textField.textField.leftViewMode = UITextFieldViewModeAlways;
                textField.textField.leftView = eyeView;
            } else {
                textField.textField.rightViewMode = UITextFieldViewModeAlways;
                textField.textField.rightView = eyeView;
            }
            
            startingY += textField.frame.size.height;
            
            [textField.textField setTag:tag];
            [textField setTag:tag];
            
            lastTextFieldIndex = [self.formViews count];
            [self.formViews addObject:textField];
        }
        else if ([field.type isEqualToString:@"integer"] || [field.type isEqualToString:@"number"])
        {
            JATextFieldComponent *textField = [[JATextFieldComponent alloc] init];
            [textField setupWithField:field];
            [textField.textField setDelegate:self];
            [textField.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
            
            if ([@"phone" isEqualToString:field.key]) {
                textField.textField.keyboardType = UIKeyboardTypePhonePad;
                textField.textField.inputAccessoryView = keyboardDoneButtonView;
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
            JABirthDateComponent *birthDateComponent = [[JABirthDateComponent alloc] init];
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
            JARadioComponent *radioComponent = [[JARadioComponent alloc] init];
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
            else if([radioComponent isComponentWithKey:@"newsletter_categories_subscribed"] && VALID_NOTEMPTY([radioComponent getApiCallUrl], NSString))
            {
                self.newsletterGenderComponent = radioComponent;
            }
        }
        else if ([@"related_number" isEqualToString:field.type])
        {
            
            JATextFieldComponent *textField = [[JATextFieldComponent alloc] init];
            [textField setupWithField:field];
            [textField.textField setDelegate:self];
            [textField.textField setReturnKeyType:returnKeyType];
            
            [textField setY:startingY];
            startingY += textField.frame.size.height;
            
            [textField.textField setTag:tag];
            [textField setTag:tag];
            
            [textField.textField setKeyboardType:UIKeyboardTypeNumbersAndPunctuation];
            if ([@"phone" isEqualToString:field.key]) {
                textField.textField.keyboardType = UIKeyboardTypePhonePad;
                textField.textField.inputAccessoryView = keyboardDoneButtonView;
            }
            
            
            
            lastTextFieldIndex = [self.formViews count];
            [self.formViews addObject:textField];
            tag++;
            
            
            if (1 == field.relatedFields.count) {
                //must be list type
                
                CGFloat phoneOffset = 80.f;
                CGFloat prefixWidth = 70.f;
                
                [textField setFixedX:phoneOffset];
                
                JARadioComponent* radioRelated = [[JARadioComponent alloc] initWithFrame:CGRectMake(8.f, 0, prefixWidth, 48.f)];
                [radioRelated.textField setDelegate:self];
                RIField *relatedField = [field.relatedFields firstObject];
                [radioRelated setupWithField:relatedField];
                [radioRelated setFixedWidth:prefixWidth];
                [radioRelated.textField setTag:tag];
                [radioRelated setTag:tag];
                [radioRelated.textField setPlaceholder:@"+"];
                [radioRelated.textField setEnabled:NO];
                
                CGRect frame = radioRelated.frame;
                frame.origin.y = textField.frame.origin.y;
                radioRelated.frame = frame;
                
                [self.formViews addObject:radioRelated];
                
                self.phonePrefixComponent = radioRelated;
                
                textField.relatedComponent = radioRelated;
                
            } else if (2 == [field.relatedFields count]) {
                //must be radio type
                
                JARadioRelatedComponent* radioRelatedComp = [[JARadioRelatedComponent alloc]init];
                
                [radioRelatedComp setTag:tag];
                [radioRelatedComp.switchComponent setTag:tag];
                tag++;
                
                [radioRelatedComp setupWithField:field];

                
                [radioRelatedComp setY:startingY];
                startingY += radioRelatedComp.frame.size.height;
                
                [self.formViews addObject:radioRelatedComp];
                textField.relatedComponent = radioRelatedComp;                
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
                    JAAddRatingView *stars = [[JAAddRatingView alloc]initWithFrame:CGRectMake(0,
                                                                                             startingY,
                                                                                             widthComponent,
                                                                                             0)];
                    [stars setupWithFieldRatingStars:ratingStars];
                    
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

-(void)validateFieldsWithErrorArray:(NSArray*)errorsArray
                        finishBlock:(void (^)(NSString*))finishBlock;
{
    NSString* firstMessage = @""; //starts empty
    for (id error in errorsArray) {
        if (VALID_NOTEMPTY(error, NSDictionary)) {
            //do not pass the finish block. we take care of that at the end of this method
            [self validateFieldWithErrorDictionary:error finishBlock:nil];
            if (VALID_NOTEMPTY(firstMessage, NSString)) {
                //do nothing, we already have an error message
            } else {
                //we don't have an error message yet, so this is the one we should show
                if ([error objectForKey:@"message"]) {
                    firstMessage = [error objectForKey:@"message"];
                }
            }
        } else if (VALID_NOTEMPTY(error, NSString)) {
            firstMessage = error;
        }

    }
    if (VALID_NOTEMPTY(firstMessage, NSString)) {
        //we have a message, do nothing else
    } else {
        //we don't have a message, we have to use the generic one
        firstMessage = STRING_ERROR_INVALID_FIELDS;
    }
    if (finishBlock) {
        finishBlock(firstMessage);
    }
}

-(void)validateFieldWithErrorDictionary:(NSDictionary*)errorDictionary
                            finishBlock:(void (^)(NSString*))finishBlock;
{
    NSString* field = [errorDictionary objectForKey:@"field"];
    NSString* message = [errorDictionary objectForKey:@"message"];
    
    if (VALID_NOTEMPTY(field, NSString)) {
        for (id view in self.formViews)
        {
            if ([view isKindOfClass:[JATextFieldComponent class]])
            {
                JATextFieldComponent *textFieldView = (JATextFieldComponent*)view;
                if([textFieldView isComponentWithKey:field])
                {
                    [textFieldView setError:message];
                    break;
                }
            }
            else if ([view isKindOfClass:[JABirthDateComponent class]])
            {
                JABirthDateComponent *birthDateComponent = (JABirthDateComponent*)view;
                if([birthDateComponent isComponentWithKey:field])
                {
                    [birthDateComponent setError:message];
                    break;
                }
            }
            else if ([view isKindOfClass:[JARadioComponent class]])
            {
                JARadioComponent *radioComponent = (JARadioComponent*)view;
                if([radioComponent isComponentWithKey:field])
                {
                    [radioComponent setError:message];
                    break;
                }
            }
        }
    }
    
    if (VALID_NOTEMPTY(message, NSString)) {
        if (finishBlock) {
            finishBlock(message);
        }
    }
}

-(BOOL)checkErrors
{
    NSString* genderFieldName = [self getFieldNameForKey:@"gender"];
    self.firstErrorInFields = nil;
    BOOL hasErrors = NO;
    if(VALID_NOTEMPTY(self.formViews, NSMutableArray))
    {
        for (id obj in self.formViews)
        {
            if ([obj isKindOfClass:[JATextFieldComponent class]] ||
                [obj isKindOfClass:[JABirthDateComponent class]] ||
                [obj isKindOfClass:[JARadioComponent class]] ||
                [obj isKindOfClass:[JARadioRelatedComponent class]])
            {
                //ignore gender as an error, can't evaluate it here because the billing address form has it but it isn't shown on screen.
                if (NO == [[obj getFieldName] isEqualToString:genderFieldName]) {
                    if (![obj isValid]) //ignore gender
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
                if(([@"register" isEqualToString:[self.form type]]
                    || [@"address" isEqualToString:[self.form type]]
                    || [@"edit" isEqualToString:[self.form type]])
                   && [radioComponent isComponentWithKey:@"gender"]) {
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
                JATextFieldComponent *textFieldComponent = (JATextFieldComponent *) view;
                
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
            JATextFieldComponent *textFieldView = (JATextFieldComponent *)view;
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

/*
 showPassword()
 Toggles password's eye image
 Show/Hide password characters
 recieves UITapGestureRecognizer gestureRecognizer
 */
- (void)showPassword:(UITapGestureRecognizer *)gestureRecognizer
{
    UIImageView *imageViewClicked = (UIImageView*)gestureRecognizer.view;
    
    id superView = imageViewClicked.superview;
    if ([superView isKindOfClass:[UITextField class]]) {
        UITextField *passwordTextField = (UITextField *)superView;
        BOOL passwordHidden = passwordTextField.secureTextEntry;
        UIImage *image;
        
        if (passwordHidden) {
            image = [UIImage imageNamed:@"btn_eye"];
        } else {
            image = [UIImage imageNamed:@"btn_eye_closed"];
        }
        
        [imageViewClicked setImage:image];
        [passwordTextField setSecureTextEntry:!passwordHidden];
    }
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
