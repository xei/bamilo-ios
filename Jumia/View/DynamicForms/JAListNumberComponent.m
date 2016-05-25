//
//  JAListNumberComponent.m
//  Jumia
//
//  Created by telmopinto on 11/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAListNumberComponent.h"
#import "RILocale.h"
#import "RIFieldDataSetComponent.h"
#import "RIFieldOption.h"

@interface JAListNumberComponent()

@property (strong, nonatomic) id storedValue;
@property (strong, nonatomic) UIView *underLineView;
@property (strong, nonatomic) UILabel* descriptionLabel;

@end

@implementation JAListNumberComponent

- (UITextField *)textField
{
    if (!VALID_NOTEMPTY(_textField, UITextField)) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, self.height - 28, self.width, 20)];
        [_textField setFont:JAListFont];
        [_textField setTextColor:JABlackColor];
        [_textField setValue:JATextFieldColor forKeyPath:@"_placeholderLabel.textColor"];
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

- (UIImageView *)dropdownImageView
{
    if (!VALID(_dropdownImageView, UIImageView)) {
        UIImage *image = [UIImage imageNamed:@"ic_dropdown"];
        _dropdownImageView = [[UIImageView alloc] initWithImage:image];
        [_dropdownImageView setXLeftOf:self.requiredSymbol at:3];
        [_dropdownImageView setY:self.textField.y];
        [self addSubview:_dropdownImageView];
    }
    return _dropdownImageView;
}

- (UILabel*)descriptionLabel
{
    if (!VALID(_descriptionLabel, UILabel)) {
        _descriptionLabel = [UILabel new];
        _descriptionLabel.font = JACaptionFont;
        _descriptionLabel.textColor = JABlackColor;
        [self addSubview:_descriptionLabel];
    }
    return _descriptionLabel;
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
    [self.underLineView setFrame:CGRectMake(76, self.height-5, 20, 1.f)];
    [self.textField setFrame:CGRectMake(76, self.height - 28, 20, 20)];
    [self.dropdownImageView setX:CGRectGetMaxX(self.textField.frame) - 5.0f];
    [self.dropdownImageView setY:self.textField.y + (self.textField.height - self.dropdownImageView.height)/2];
    [self.requiredSymbol setFrame:CGRectMake(CGRectGetMaxX(self.dropdownImageView.frame), self.height - 28, 10, 20)];
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    [self.descriptionLabel setFrame:CGRectMake(CGRectGetMaxX(self.requiredSymbol.frame), self.textField.frame.origin.y, width - CGRectGetMaxX(self.requiredSymbol.frame), self.textField.frame.size.height)];
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
        [self.descriptionLabel flipViewPositionInsideSuperview];
        [self.descriptionLabel flipViewAlignment];
    }
}

-(void)setupWithField:(RIField*)field
{
    self.storedValue = @"";
    self.hasError = NO;
    self.field = field;
    self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
    [self.descriptionLabel setText:field.label];
    
    if(VALID_NOTEMPTY(field.value, NSString))
    {
        self.storedValue = field.value;
        [self.textField setText:field.value];
    }
    
    UIImage *iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"ic_%@_form", field.key]];
    if (iconImage) {
        self.iconImageView = [[UIImageView alloc] initWithImage:iconImage];
        [self.iconImageView setFrame:CGRectMake(0, self.y + (self.height - self.iconImageView.height)/2, iconImage.size.width, iconImage.size.height)];
    }
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

-(NSDictionary*)getValues
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if([self.field.required boolValue] || NOT_NIL(self.storedValue))
    {
        [parameters setValue:self.storedValue forKey:self.field.name];
    }
    return parameters;
}

- (NSDictionary *)getLabels
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
    [self.textField setTextColor:JARed1Color];
    [self.textField setValue:JARed1Color forKeyPath:@"_placeholderLabel.textColor"];
    
    if(ISEMPTY(self.textField.text))
    {
        self.hasError = YES;
        [self.textField setText:error];
    }
}

-(void)cleanError
{
    self.textField.font = [UIFont fontWithName:kFontRegularName size:self.textField.font.pointSize];
    [self.textField setTextColor:JABlackColor];
    [self.textField setValue:JATextFieldColor forKeyPath:@"_placeholderLabel.textColor"];
    if (NO == self.textField.enabled) {
        [self.textField setTextColor:JABlack700Color];
    }
    
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
        [self.textField setTextColor:JARed1Color];
        [self.textField setValue:JARed1Color forKeyPath:@"_placeholderLabel.textColor"];
        self.currentErrorMessage = self.field.requiredMessage;
        
        return NO;
    }
    
    self.currentErrorMessage = nil;
    [self.textField setTextColor:JABlackColor];
    if (NO == self.textField.enabled) {
        [self.textField setTextColor:JABlack700Color];
    }
    [self.textField setValue:JATextFieldColor forKeyPath:@"_placeholderLabel.textColor"];
    
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


@end
