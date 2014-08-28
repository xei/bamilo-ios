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

@interface JADynamicForm ()
<UITextFieldDelegate>

@end

@implementation JADynamicForm

-(id)initWithForm:(RIForm*)form startingPosition:(CGFloat)startingY;
{
    self = [super init];
    if(self)
    {
        self.form = form;
        [self generateForm:[[form fields] array] startingY:startingY];
    }
    return self;
}

- (void)generateForm:(NSArray*)fields startingY:(CGFloat)startingY
{
    BOOL addedBirth = NO;
    NSInteger lastTextFieldIndex = 0;
    self.formViews = [[NSMutableArray alloc] init];
    for (int i = 0; i < [fields count]; i++)
    {
        RIField *field = [fields objectAtIndex:i];
        
        if ([field.type isEqualToString:@"string"] || [field.type isEqualToString:@"email"])
        {
            JATextField *textField = [JATextField getNewJATextField];
            [textField setupWithField:field];
            [textField.textField setDelegate:self];
            [textField.textField setReturnKeyType:UIReturnKeyNext];
            
            CGRect frame = textField.frame;
            frame.origin.y = startingY;
            textField.frame = frame;
            startingY += textField.frame.size.height;
            
            [textField.textField setTag:i];
            [textField setTag:i];
            
            lastTextFieldIndex = [self.formViews count];
            [self.formViews addObject:textField];
        }
        else if ([field.type isEqualToString:@"password"] || [field.type isEqualToString:@"password2"])
        {
            JATextField *textField = [JATextField getNewJATextField];
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
                
                [birthDate setTag:i];
                [self.formViews addObject:birthDate];
                
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
            
            [gender setTag:i];
            [self.formViews addObject:gender];
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
            
            [check setTag:i];
            [self.formViews addObject:check];
        }
        else if ([field.type isEqualToString:@"hidden"])
        {
        }
    }
    
    if(lastTextFieldIndex < [self.formViews count])
    {
        JATextField *lastTextField = [self.formViews objectAtIndex:lastTextFieldIndex];
        [lastTextField.textField setReturnKeyType:UIReturnKeyDone];
    }
}

-(BOOL)checkErrors
{
    BOOL hasErrors = NO;
    if(VALID_NOTEMPTY(self.formViews, NSMutableArray))
    {
        for (id obj in self.formViews)
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
    }
    return hasErrors;
}

-(NSDictionary*)getValues
{
    NSMutableDictionary *tempDic = [NSMutableDictionary new];
    if(VALID_NOTEMPTY(self.formViews, NSMutableArray))
    {
        for (UIView *view in self.formViews)
        {
            if ([view isKindOfClass:[JABirthDateComponent class]])
            {
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"dd-MM-yyyy"];
                NSString *dateString = [dateFormatter stringFromDate:((JABirthDateComponent *)view).datePicker.date];
                
                NSArray *components = [dateString componentsSeparatedByString:@"-"];
                
                if(VALID_NOTEMPTY(self.form, RIForm) && VALID_NOTEMPTY([self.form fields], NSArray))
                {
                    for (RIField *field in [self.form fields])
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
    }
    return [tempDic copy];
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
    JATextField *newResponder = (JATextField *) [self viewWithTag:textField.tag + 1];
    if (VALID(newResponder, JATextField)) {
        [newResponder.textField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(lostFocus)]) {
            [self.delegate performSelector:@selector(lostFocus) withObject:nil];
        }
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(changedFocus:)]) {
        [self.delegate performSelector:@selector(changedFocus:) withObject:[self viewWithTag:textField.tag]];
    }
    
    [textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    [textField setTextColor:UIColorFromRGB(0x666666)];
    
    return YES;
}

@end
