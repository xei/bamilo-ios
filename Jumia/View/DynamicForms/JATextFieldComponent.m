//
//  JATextFieldComponent.h
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JATextFieldComponent.h"

@interface JATextFieldComponent ()

@property (strong, nonatomic) RIField *field;
@property (strong, nonatomic) NSString *storedValue;

@end

@implementation JATextFieldComponent

+ (JATextFieldComponent *)getNewJATextFieldComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JATextFieldComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JATextFieldComponent class]]) {
            return (JATextFieldComponent *)obj;
        }
    }
    
    return nil;
}

- (void)setupWithField:(RIField*)field
{
    self.storedValue = @"";
    self.hasError = NO;
    self.field = field;
    [self.textField setPlaceholder:field.label];
    
    if(VALID_NOTEMPTY(field.requiredMessage, NSString))
    {
        [self.textField setTextColor:UIColorFromRGB(0x666666)];
        [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
        
        [self.requiredSymbol setHidden:NO];
        [self.requiredSymbol setTextColor:UIColorFromRGB(0xfaa41a)];
    }
    
    if(VALID_NOTEMPTY(field.value, NSString))
    {
        self.storedValue = field.value;
        [self.textField setText:field.value];
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

-(NSDictionary*)getValues
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if([self.field.required boolValue] || VALID_NOTEMPTY(self.storedValue, NSString))
    {
        if(!self.hasError)
        {
            self.storedValue = self.textField.text;
        }
        [parameters setValue:self.storedValue forKey:self.field.name];
    }
    return parameters;
}

-(void)setError:(NSString*)error
{
    [self.textField setTextColor:UIColorFromRGB(0xcc0000)];
    [self.textField setValue:UIColorFromRGB(0xcc0000) forKeyPath:@"_placeholderLabel.textColor"];
    
    if(ISEMPTY(self.textField.text))
    {
        self.hasError = YES;
        [self.textField setText:error];
        
        if([self.textField isSecureTextEntry])
        {
            [self.textField setSecureTextEntry:NO];
        }
    }
}

-(void)cleanError
{
    [self.textField setTextColor:UIColorFromRGB(0x666666)];
    [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    
    if(self.hasError)
    {
        self.hasError = NO;
        
        if([@"password" isEqualToString:self.field.key] ||
           [@"password2" isEqualToString:self.field.key] )
        {
            [self.textField setSecureTextEntry:YES];
        }
        
        [self.textField setText:@""];
    }
}

- (BOOL)isValid
{
    if ((self.field.requiredMessage.length > 0) && (self.textField.text.length == 0))
    {
        [self.textField setTextColor:UIColorFromRGB(0xcc0000)];
        [self.textField setValue:UIColorFromRGB(0xcc0000) forKeyPath:@"_placeholderLabel.textColor"];
        
        return NO;
    }
    else
    {
        if (self.field.regex.length > 0)
        {
            if (![self validateInputWithString:self.textField.text andRegularExpression:self.field.regex])
            {
                [self.textField setTextColor:UIColorFromRGB(0xcc0000)];
                [self.textField setValue:UIColorFromRGB(0xcc0000) forKeyPath:@"_placeholderLabel.textColor"];
                
                return NO;
            }
        }
    }
    
    [self.textField setTextColor:UIColorFromRGB(0x666666)];
    [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    
    return YES;
}

- (BOOL)validateInputWithString:(NSString *)aString
           andRegularExpression:(NSString *)regExp
{
    NSString * const regularExpression = regExp;
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regularExpression
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    if (error) {
        NSLog(@"error %@", error);
    }
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:aString
                                                        options:0
                                                          range:NSMakeRange(0, [aString length])];
    return numberOfMatches > 0;
}

-(void)resetValue
{
    [self cleanError];
    
    if(VALID_NOTEMPTY(self.field.value, NSString))
    {
        self.storedValue = self.field.value;
        [self.textField setText:self.field.value];
    }
}

@end
