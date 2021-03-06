//
//  JATextField.m
//  Jumia
//
//  Created by Jose Mota on 30/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JATextFieldComponent.h"
#import "JARadioRelatedComponent.h"
#import "IntUtility.h"

@interface JATextFieldComponent ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) NSString *storedValue;
@property (strong, nonatomic) UIView *underLineView;

@end

@implementation JATextFieldComponent

- (UILabel *)titleLabel
{
    if (!VALID_NOTEMPTY(_titleLabel, UILabel)) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 20)];
        [_titleLabel setTextColor:JABlack700Color];
        [_titleLabel setFont:JACaptionFont];
    }
    return _titleLabel;
}

- (UITextField *)textField
{
    if (!VALID_NOTEMPTY(_textField, UITextField)) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.height - 28, self.width, 20)];
        [_textField setFont:JAListFont];
        [_textField setTextColor:JABlackColor];
        [_textField setValue:JATextFieldColor forKeyPath:@"_placeholderLabel.textColor"];
        [_textField setIsAccessibilityElement:YES];
        [self addSubview:_textField];
    }
    return _textField;
}

- (UILabel *)requiredSymbol
{
    if (!VALID_NOTEMPTY(_requiredSymbol, UILabel)) {
        _requiredSymbol = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 20, self.height - 28, 10, 20)];
        [_requiredSymbol setTextAlignment:NSTextAlignmentCenter];
        [_requiredSymbol setText:@"*"];
        [_requiredSymbol setTextColor:JAOrange1Color];
        [_requiredSymbol setHidden:YES];
        [self addSubview:_requiredSymbol];
    }
    return _requiredSymbol;
}

- (UIView *)underLineView
{
    if (!VALID_NOTEMPTY(_underLineView, UIView)) {
        _underLineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-5, self.width, 1.f)];
        [_underLineView setBackgroundColor:JABlack700Color];
        [self addSubview:_underLineView];
    }
    return _underLineView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(8.f, 0, 288.f, 48.f)];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGFloat xOffset = 0;
    if (self.fixedX)
    {
        xOffset = self.fixedX;
    }
    [self.underLineView setFrame:CGRectMake(xOffset, self.height-5, self.width - xOffset, 1.f)];
    [self.requiredSymbol setFrame:CGRectMake(self.width, self.height - 28, 10, 20)];
    [self.textField setFrame:CGRectMake(xOffset, self.height - 28, self.width - xOffset - 10, 20)];
    [self.titleLabel setFrame:CGRectMake(xOffset, 0, self.width - xOffset - 28 , 20)];
    if (self.iconImageView) {
        [self.iconImageView setY:self.y + self.textField.y + (self.textField.height - self.iconImageView.height)/2];
    }
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.textField setTextAlignment:NSTextAlignmentLeft];
    
    [self flipIfIsRTL];
}

- (void)flipIfIsRTL
{
    if (RI_IS_RTL) {
        [self.titleLabel flipViewAlignment];
        [self.underLineView flipViewPositionInsideSuperview];
//        [self.requiredSymbol flipViewPositionInsideSuperview];
        [self.textField flipViewPositionInsideSuperview];
        [self.textField flipViewAlignment];
    }
}

- (void)setupWithField:(RIField*)field
{
    self.field = field;
    self.storedValue = @"";
    self.hasError = NO;
    self.field = field;
    [self.textField setPlaceholder:field.label];
    
    //PATCH By Tessa
    if([[field valueForKey:@"label"] isEqualToString:@"Current Password"]){
        self.textField.placeholder = CURRENT_PASSWORD;
    }
    else if ([[field valueForKey:@"label"] isEqualToString:@"رمز عبور"]){
        self.textField.placeholder = STRING_NEW_PASSWORD;
    }
    if([field.required boolValue])
    {
        [self.requiredSymbol setHidden:NO];
    }
    
    if(VALID_NOTEMPTY(field.value, NSString))
    {
        self.storedValue = field.value;
        [self.textField setText:field.value];
    }
    [self.underLineView setHidden:NO];
    
    UIImage *iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"ic_%@_form", field.key]];
    if (iconImage) {
        self.iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        [self.iconImageView setFrame:CGRectMake(0, self.y + (self.height - self.iconImageView.height)/2, iconImage.size.width, iconImage.size.height)];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(assignFirstResponder)];
    [self addGestureRecognizer:tap];
}

-(void)setupWithTitle:(NSString *)title label:(NSString*)label value:(NSString*)value mandatory:(BOOL)mandatory {
    [self addSubview:self.titleLabel];
    [self.titleLabel setText:title];
    [self setupWithLabel:label value:value mandatory:mandatory];
}

-(void)setupWithLabel:(NSString*)label value:(NSString*)value mandatory:(BOOL)mandatory
{
    // this triggers the constraints error output
    
    self.storedValue = @"";
    self.hasError = NO;
    
    [self.textField setPlaceholder:label];
    
    if(mandatory)
    {
        [self.requiredSymbol setHidden:NO];
        [self.requiredSymbol setTextColor:JAOrange1Color];
    }
    
    if(VALID_NOTEMPTY(value, NSString))
    {
        self.storedValue = value;
        [self.textField setText:value];
    }
    [self.underLineView setHidden:NO];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(assignFirstResponder)];
    [self addGestureRecognizer:tap];
}

-(NSString*)getFieldName
{
    return self.field.name;
}

-(void)setValue:(NSString*)value
{
    [super setValue:value];
    self.storedValue = value;
    [self.textField setText:value];
}

-(NSDictionary*)getValues
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if([self.field.required boolValue] || VALID_NOTEMPTY(self.textField.text, NSString))
    {
        if(!self.hasError)
        {
            self.storedValue = self.textField.text;
        }
        [parameters setValue:self.storedValue forKey:self.field.name];
    }
    return parameters;
}

- (NSDictionary *)getLabels
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if([self.field.required boolValue] || VALID_NOTEMPTY(self.textField.text, NSString))
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
    self.textField.font = [UIFont fontWithName:kFontRegularName size:self.textField.font.pointSize];
    [self.textField setTextColor:JARed1Color];
    [self.textField setValue:JARed1Color forKeyPath:@"_placeholderLabel.textColor"];
    
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
    self.textField.font = [UIFont fontWithName:kFontRegularName size:self.textField.font.pointSize];
    [self.textField setTextColor:JABlackColor];
    if (NO == self.textField.enabled) {
        [self.textField setTextColor:JABlack700Color];
    }
    [self.textField setValue:JATextFieldColor forKeyPath:@"_placeholderLabel.textColor"];
    
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
    self.textField.font = [UIFont fontWithName:kFontRegularName size:self.textField.font.pointSize];
    if ([self.field.required boolValue] && !VALID_NOTEMPTY(self.textField.text, NSString))
    {
        [self.textField setTextColor:JARed1Color];
        [self.textField setValue:JARed1Color forKeyPath:@"_placeholderLabel.textColor"];
        self.currentErrorMessage = self.field.requiredMessage;
        
        return NO;
    }
    else
    {
        __block NSString* pattern;
        __block NSString* errorMessage;
        
        NSDictionary* dict;
        if (VALID_NOTEMPTY(self.relatedComponent, JARadioComponent)) {
            JARadioComponent* radiocomp = (JARadioComponent*) self.relatedComponent;
            dict = [radiocomp getValues];
        } else if (VALID_NOTEMPTY(self.relatedComponent, JARadioRelatedComponent)) {
            JARadioRelatedComponent* radiocomp = (JARadioRelatedComponent*) self.relatedComponent;
            dict = [radiocomp getValues];
        }
        
        if (VALID_NOTEMPTY(dict, NSDictionary)) {
        
            [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                for (RIField* relatedField in self.field.relatedFields) {
                    if ([relatedField.value isEqualToString:obj] && VALID_NOTEMPTY(relatedField.pattern, NSString)) {
                        pattern = relatedField.pattern;
                        errorMessage = relatedField.patternMessage;
                        *stop = YES;
                        break;
                    }
                }
            }];
        }
        
        if (!VALID_NOTEMPTY(pattern, NSString) && !VALID_NOTEMPTY(errorMessage, NSString) && VALID_NOTEMPTY(self.field.pattern, NSString)) {
                pattern = self.field.pattern;
                errorMessage = self.field.patternMessage;
        }

        if (VALID_NOTEMPTY(pattern, NSString)) {
            if (![self validateInputWithString:self.textField.text andRegularExpression:pattern])
            {
                [self.textField setTextColor:JARed1Color];
                [self.textField setValue:JARed1Color forKeyPath:@"_placeholderLabel.textColor"];
                self.currentErrorMessage = errorMessage;
                
                return NO;
            }
        }
        
        if([self.field.required boolValue] || VALID_NOTEMPTY(self.textField.text, NSString))
        {
            if(VALID_NOTEMPTY(self.field.min, NSNumber) && [self.field.min intValue] > [self.textField.text length])
            {
                [self.textField setTextColor:JARed1Color];
                [self.textField setValue:JARed1Color forKeyPath:@"_placeholderLabel.textColor"];
                
                self.currentErrorMessage = self.field.patternMessage;
                if (!self.field.patternMessage && VALID_NOTEMPTY(self.field.requiredMessage, NSString)) {
                    self.currentErrorMessage = self.field.requiredMessage;
                }
                
                return NO;
            }
            
            if(VALID_NOTEMPTY(self.field.max, NSNumber) && 0 != [self.field.max integerValue] && [self.field.max intValue] < [self.textField.text length])
            {
                [self.textField setTextColor:JARed1Color];
                [self.textField setValue:JARed1Color forKeyPath:@"_placeholderLabel.textColor"];
                
                self.currentErrorMessage = self.field.patternMessage;
                if (!self.field.patternMessage && VALID_NOTEMPTY(self.field.requiredMessage, NSString)) {
                    self.currentErrorMessage = self.field.requiredMessage;
                }
                
                return NO;
            }
        }
    }
    
    self.currentErrorMessage = nil;
    [self.textField setTextColor:JABlackColor];
    if (NO == self.textField.enabled) {
        [self.textField setTextColor:JABlack700Color];
    }
    [self.textField setValue:JATextFieldColor forKeyPath:@"_placeholderLabel.textColor"];
    
    return YES;
}

- (BOOL)validateInputWithString:(NSString *)aString
           andRegularExpression:(NSString *)patternExp
{
    NSString * const regularExpression = patternExp;
    NSError *error = NULL;
    NSRegularExpression *pattern = [NSRegularExpression regularExpressionWithPattern:regularExpression
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:&error];
    if (error) {
        NSLog(@"error %@", error);
    }
    
    NSUInteger numberOfMatches = [pattern numberOfMatchesInString:aString
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

- (void)assignFirstResponder
{
    [self.textField becomeFirstResponder];
}

@end
