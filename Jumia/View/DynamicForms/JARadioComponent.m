//
//  JARadioComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARadioComponent.h"
#import "RIFieldOption.h"
#import "RIFieldDataSetComponent.h"
#import "RILocale.h"
#import "RITarget.h"

@interface JARadioComponent ()

@property (strong, nonatomic) id storedValue;
@property (strong, nonatomic) UIView *underLineView;
@property (strong, nonatomic) UIImageView *dropdownImageView;

@end

@implementation JARadioComponent

- (UITextField *)textField
{
    if (!VALID_NOTEMPTY(_textField, UITextField)) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.height - 28, self.width, 20)];
        [_textField setFont:JAList2Font];
        [_textField setTextColor:JABlackColor];
        [_textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
        [self addSubview:_textField];
    }
    return _textField;
}

- (UILabel *)requiredSymbol
{
    if (!VALID_NOTEMPTY(_requiredSymbol, UILabel)) {
        _requiredSymbol = [[UILabel alloc] initWithFrame:CGRectMake(self.width - 10, self.height - 28, 10, 20)];
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

- (UIImageView *)dropdownImageView
{
    if (!VALID(_dropdownImageView, UIImageView)) {
        UIImage *image = [UIImage imageNamed:@"ic_dropdown"];
        _dropdownImageView = [[UIImageView alloc] initWithImage:image];
        [_dropdownImageView setXLeftOf:self.requiredSymbol at:0];
        [_dropdownImageView setY:self.textField.y];
        [self addSubview:_dropdownImageView];
    }
    return _dropdownImageView;
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
    CGFloat width = frame.size.width;
    if (self.fixedWidth) {
        width = self.fixedWidth;
    }
    frame.size.width = width;
    [super setFrame:frame];
    [self.underLineView setFrame:CGRectMake(0, self.height-5, width, 1.f)];
    [self.requiredSymbol setFrame:CGRectMake(self.width - 10, self.height - 28, 10, 20)];
    [self.textField setFrame:CGRectMake(0, self.height - 28, width, 20)];
    [self.dropdownImageView setXLeftOf:self.requiredSymbol at:0];
    [self.dropdownImageView setY:self.textField.y + (self.textField.height - self.dropdownImageView.height)/2];
//    [self.titleLabel setFrame:CGRectMake(0, 0, self.width, 20)];
    if (self.iconImageView) {
        [self.iconImageView setY:self.y + self.textField.y + (self.textField.height - self.iconImageView.height)/2];
    }
    [self.textField setTextAlignment:NSTextAlignmentLeft];
    
    [self flipIfIsRTL];
}

- (void)flipIfIsRTL
{
    if (RI_IS_RTL) {
        [self.underLineView flipViewPositionInsideSuperview];
        [self.requiredSymbol flipViewPositionInsideSuperview];
        [self.textField flipViewPositionInsideSuperview];
        [self.textField flipViewAlignment];
        [self.dropdownImageView flipViewPositionInsideSuperview];
    }
}

-(void)setupWithField:(RIField*)field
{
    self.storedValue = @"";
    self.hasError = NO;
    self.field = field;
    [self.textField setPlaceholder:field.label];
    
    if([field.required boolValue])
    {
        [self.requiredSymbol setHidden:NO];
    }
    
    if(VALID_NOTEMPTY(field.value, NSString))
    {
        self.storedValue = field.value;
        if(![@"list" isEqualToString:field.type])
        {
            [self.textField setText:field.value];
        }
    }
    
    if(VALID_NOTEMPTY(field.dataSet, NSOrderedSet))
    {
        NSMutableArray *contentArray = [[NSMutableArray alloc] init];
        for (RIFieldDataSetComponent *component in field.dataSet) {
            [contentArray addObject:component.value];
        }
        self.dataset = [contentArray copy];
    }
    else if(VALID_NOTEMPTY(field.options, NSOrderedSet))
    {
        NSMutableArray *contentArray = [[NSMutableArray alloc] init];
        for (RIFieldOption *component in field.options) {
            [contentArray addObject:component.value];
        }
        self.options = [contentArray copy];
    }
    else if(VALID_NOTEMPTY(field.apiCallTarget, NSString))
    {
        self.apiCallTarget = field.apiCallTarget;
        if (VALID_NOTEMPTY(field.apiCallParameters, NSDictionary)) {
            self.apiCallParameters = field.apiCallParameters;
        }
    }
    
    UIImage *iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"ic_%@_form", field.key]];
    if (iconImage) {
        self.iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        [self.iconImageView setFrame:CGRectMake(0, self.y + (self.height - self.iconImageView.height)/2, iconImage.size.width, iconImage.size.height)];
    }
}

-(BOOL)isComponentWithKey:(NSString*)key
{
    return ([key isEqualToString:self.field.key]);
}

-(NSString*)getFieldName
{
    return self.field.name;
}

-(void)setValue:(id)value
{
    self.storedValue = value;
    if ([value isKindOfClass:[NSNumber class]]) {
        [self.textField setText:[value stringValue]];
    }else{
        [self.textField setText:value];
    }
}

-(void)setLocaleValue:(RILocale*)locale
{
    if(VALID_NOTEMPTY(locale, RILocale))
    {
        self.storedValue = locale.value;
        [self.textField setText:locale.label];
    }
    else
    {
        self.storedValue = @"";
        [self.textField setText:@""];
    }
}

-(NSDictionary*)getValues
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if([self.field.required boolValue] || NOT_NIL(self.storedValue))
    {
        [parameters setValue:self.storedValue forKey:self.field.name];
    }
    return parameters;
}

-(NSString*)getSelectedValue
{
    return self.storedValue;
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
    [self.textField setTextColor:UIColorFromRGB(0x000000)];
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
    if ([self.field.required  boolValue] && (self.textField.text.length == 0))
    {
        [self.textField setTextColor:UIColorFromRGB(0xcc0000)];
        [self.textField setValue:UIColorFromRGB(0xcc0000) forKeyPath:@"_placeholderLabel.textColor"];
        self.currentErrorMessage = self.field.requiredMessage;
        
        return NO;
    }
    
    self.currentErrorMessage = nil;
    [self.textField setTextColor:UIColorFromRGB(0x666666)];
    [self.textField setValue:UIColorFromRGB(0xcccccc) forKeyPath:@"_placeholderLabel.textColor"];
    
    return YES;
}

-(void)resetValue
{
    [self cleanError];
    
    if(VALID_NOTEMPTY(self.field.value, NSString))
    {
        self.storedValue = self.field.value;
        if(![@"list" isEqualToString:self.field.type])
        {
            [self.textField setText:self.field.value];
        }
    }
}

-(NSString*)getApiCallUrl
{
    NSString *apiCallUrl = nil;
    
    if(VALID_NOTEMPTY(self.field, RIField) && [@"list" isEqualToString:[self.field type]] && VALID_NOTEMPTY([self.field apiCallTarget], NSString))
    {
        apiCallUrl = [RITarget getURLStringforTargetString:self.field.apiCallTarget];
    }
    
    return apiCallUrl;
}

- (NSDictionary*)getApiCallParameters
{
    return self.field.apiCallParameters;
}


@end
