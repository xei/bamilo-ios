//
//  JARadioExpandableComponent.m
//  Jumia
//
//  Created by telmopinto on 13/05/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JARadioExpandableComponent.h"
#import "JAClickableView.h"
#import "RIFieldOption.h"
#import "RIForm.h"

@interface JARadioExpandableComponent()

@property (nonatomic, strong) NSMutableArray* checkboxViewsArray;
@property (nonatomic, strong) NSMutableArray* optionLabelsArray;
@property (nonatomic, strong) NSMutableArray* contentViewsArray;
@property (nonatomic, assign) CGRect labelBaseRect;
@property (nonatomic, assign) CGRect checkboxBaseRect;
@property (nonatomic, assign) CGSize contentBaseSize;

@property (nonatomic, strong) NSNumber *selectedIndex;

@property (nonatomic, strong) UILabel *selectedLabel;
@property (nonatomic, strong) UILabel *selectedSublabel;
@property (nonatomic, strong) UIView *selectedSublabelBackground;

@property (nonatomic, strong) NSArray* subFormTextFieldsArray;
@property (nonatomic, strong) NSArray* subFormSeparatorsArray;

@end

@implementation JARadioExpandableComponent

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(0.f, 0, 320.f, 48.f)];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.contentBaseSize = CGSizeMake(self.width,
                                      48.0f);
    
    CGFloat xOffset = 0.0f;
    CGFloat checkboxMargins = 10.0f;
    UIImage* checkboxImage = [UIImage imageNamed:@"round_checkbox_selected"];
    self.checkboxBaseRect = CGRectMake(xOffset,
                                       (self.contentBaseSize.height - checkboxImage.size.height) / 2,
                                       checkboxImage.size.width,
                                       checkboxImage.size.height);
    
    CGFloat labelHeight = 40.0f;
    self.labelBaseRect = CGRectMake(CGRectGetMaxX(self.checkboxBaseRect) + checkboxMargins,
                                    (self.contentBaseSize.height - labelHeight) / 2,
                                    self.contentBaseSize.width - self.checkboxBaseRect.size.width - checkboxMargins*2 - xOffset,
                                    labelHeight);
    
    self.selectedLabel.x = CGRectGetMaxX(self.checkboxBaseRect) + checkboxMargins;
    self.selectedLabel.width = self.labelBaseRect.size.width;
    self.selectedSublabelBackground.width = frame.size.width - 13.0f*2;
    self.selectedSublabel.width = self.selectedSublabelBackground.frame.size.width;
    
    for (int i = 0; i<self.subFormTextFieldsArray.count; i++) {
        UITextField* textField = [self.subFormTextFieldsArray objectAtIndex:i];
        UIView* separator = [self.subFormSeparatorsArray objectAtIndex:i];
        
        if (RI_IS_RTL) {
            textField.textAlignment = NSTextAlignmentRight;
        } else {
            textField.textAlignment = NSTextAlignmentLeft;
        }
        textField.x = xOffset;
        textField.width = self.contentBaseSize.width - xOffset*2;
        separator.x = xOffset;
        separator.width = self.contentBaseSize.width - xOffset*2;
    }
    
    [self flipIfIsRTL];
    
    for (UIView* contentView in self.contentViewsArray) {
        contentView.width = self.contentBaseSize.width;
    }
    
    for (UIView* checkbox in self.checkboxViewsArray) {
        [checkbox setFrame:self.checkboxBaseRect];
    }
    
    for (UIView* optionLabel in self.optionLabelsArray) {
        [optionLabel setFrame:self.labelBaseRect];
    }
}

- (void)flipIfIsRTL
{
    if (RI_IS_RTL) {
        self.checkboxBaseRect = CGRectMake(self.frame.size.width - self.checkboxBaseRect.origin.x - self.checkboxBaseRect.size.width,
                                           self.checkboxBaseRect.origin.y,
                                           self.checkboxBaseRect.size.width,
                                           self.checkboxBaseRect.size.height);
        self.labelBaseRect = CGRectMake(self.frame.size.width - self.labelBaseRect.origin.x - self.labelBaseRect.size.width,
                                        self.labelBaseRect.origin.y,
                                        self.labelBaseRect.size.width,
                                        self.labelBaseRect.size.height);
        self.selectedLabel.x = self.labelBaseRect.origin.x;
        self.selectedLabel.textAlignment = NSTextAlignmentRight;
    }
}

- (void)setupWithField:(RIField*)field
{
    self.field = field;
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.contentViewsArray = [NSMutableArray new];
    self.optionLabelsArray = [NSMutableArray new];
    self.checkboxViewsArray = [NSMutableArray new];
    
    UIImage* checkboxImage = [UIImage imageNamed:@"round_checkbox_selected"];
    UIImage* checkboxImageDeselected = [UIImage imageNamed:@"round_checkbox_deselected"];
    
    CGFloat currentY = 0.0f;
    for (int i = 0; i < field.options.count; i++) {
        RIFieldOption* option = [field.options objectAtIndex:i];
        
        JAClickableView* contentView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                         currentY,
                                                                                         self.contentBaseSize.width,
                                                                                         self.contentBaseSize.height)];
        contentView.tag = i;
        [contentView addTarget:self action:@selector(optionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:contentView];
        [self.contentViewsArray addObject:contentView];
        
        UILabel* optionLabel = [[UILabel alloc] initWithFrame:self.labelBaseRect];
        [optionLabel setNumberOfLines:2];
        [optionLabel setTextColor:JABlackColor];
        [optionLabel setFont:JATitleFont];
        optionLabel.textAlignment = NSTextAlignmentLeft;
        if (RI_IS_RTL) {
            optionLabel.textAlignment = NSTextAlignmentRight;
        }
        optionLabel.text = option.label;
        [contentView addSubview:optionLabel];
        [self.optionLabelsArray addObject:optionLabel];
        
        UIImageView* checkboxImageView = [[UIImageView alloc] initWithImage:checkboxImage];
        [checkboxImageView setFrame:self.checkboxBaseRect];
        [contentView addSubview:checkboxImageView];
        [self.checkboxViewsArray addObject:checkboxImageView];
        
        currentY += contentView.frame.size.height;
        
        NSInteger selectedIndex = -1;
        if (VALID_NOTEMPTY(self.selectedIndex, NSNumber)) {
            selectedIndex = [self.selectedIndex integerValue];
        } else {
            if ([field.value isEqualToString:option.value]) {
                selectedIndex = i;
                self.selectedIndex = [NSNumber numberWithInteger:selectedIndex];
            }
        }
        if (i == selectedIndex) {
            UIView* subContentView = [[UIView alloc] initWithFrame:CGRectMake(contentView.frame.origin.x,
                                                                              currentY,
                                                                              contentView.frame.size.width,
                                                                              0.0f)];
            [self addSubview:subContentView];
            
            [checkboxImageView setImage:checkboxImage];
            
            CGFloat subContentY = 0.0f;
            
            if (VALID_NOTEMPTY(option.text, NSString)) {
                
                self.selectedLabel = [[UILabel alloc] initWithFrame:CGRectMake(optionLabel.frame.origin.x,
                                                                               subContentY,
                                                                               optionLabel.frame.size.width,
                                                                               1.0f)];
                self.selectedLabel.textAlignment = NSTextAlignmentLeft;
                self.selectedLabel.textColor = JABlack800Color;
                self.selectedLabel.font = JAListFont;
                self.selectedLabel.text = [NSString stringWithFormat:@"%@ %@",option.linkLabel, option.text];
                [self.selectedLabel sizeToFit];
                [subContentView addSubview:self.selectedLabel];
                
                subContentY = CGRectGetMaxY(self.selectedLabel.frame) + 15.0f;
            }
            
            if (VALID_NOTEMPTY(option.subtext, NSString)) {
                self.selectedSublabelBackground = [[UIView alloc] initWithFrame:CGRectMake(13.0f,
                                                                                           subContentY,
                                                                                           subContentView.frame.size.width - 13.0f*2,
                                                                                           1.0f)];
                self.selectedSublabelBackground.layer.borderColor = [JAYellow1Color CGColor];
                self.selectedSublabelBackground.layer.borderWidth = 1.0f;
                [subContentView addSubview:self.selectedSublabelBackground];
                
                self.selectedSublabel = [[UILabel alloc] initWithFrame:CGRectMake(self.selectedSublabelBackground.frame.origin.x,
                                                                                  CGRectGetMaxY(self.selectedSublabelBackground.frame) + 5.0f,
                                                                                  self.selectedSublabelBackground.frame.size.width,
                                                                                  1.0f)];
                self.selectedSublabel.textAlignment = NSTextAlignmentCenter;
                self.selectedSublabel.textColor = JABlackColor;
                self.selectedSublabel.font = JAListFont;
                self.selectedSublabel.text = option.subtext;
                [self.selectedSublabel sizeToFit];
                [subContentView addSubview:self.selectedSublabel];
                
                self.selectedSublabel.width = self.selectedSublabelBackground.frame.size.width;
                self.selectedSublabelBackground.height = self.selectedSublabel.height + 10.0f;
                
                subContentY = CGRectGetMaxY(self.selectedSublabelBackground.frame) + 20.0f;
            }
            
            if (VALID_NOTEMPTY(option.subForm, RIForm)) {
                
                subContentY += 5.0f;
                
                NSMutableArray* textFieldMutablerray = [NSMutableArray new];
                NSMutableArray* separatorMutablerray = [NSMutableArray new];
                for (RIField* field in option.subForm.fields) {
                    
                    subContentY += 15.0f;
                    
                    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(0.0f,
                                                                                           subContentY,
                                                                                           subContentView.frame.size.width,
                                                                                           20.0f)];
                    textField.tag = self.tag;
                    textField.delegate = self.textFieldDelegate;
                    textField.textAlignment = NSTextAlignmentLeft;
                    [textField setFont:JAListFont];
                    [textField setTextColor:JABlackColor];
                    [textField setValue:JABlack800Color forKeyPath:@"_placeholderLabel.textColor"];
                    [textField setPlaceholder:field.label];
                    [subContentView addSubview:textField];
                    [textFieldMutablerray addObject:textField];
                    
                    subContentY += textField.frame.size.height + 10.0f;
                    
                    UIView* separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                                     subContentY,
                                                                                     subContentView.frame.size.width,
                                                                                     1.0f)];
                    separatorView.backgroundColor = JABlack400Color;
                    [subContentView addSubview:separatorView];
                    [separatorMutablerray addObject:separatorView];
                    
                    subContentY += separatorView.frame.size.height;
                }
                self.subFormTextFieldsArray = [textFieldMutablerray copy];
                self.subFormSeparatorsArray = [separatorMutablerray copy];
            }
            
            subContentView.height = subContentY;
            
            currentY += subContentView.height;
            
        } else {
            [checkboxImageView setImage:checkboxImageDeselected];
        }
    }
    
    CGFloat delta = self.frame.size.height - currentY;
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            currentY);
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(radioExpandableComponent:changedHeight:)]) {
            [self.delegate radioExpandableComponent:self changedHeight:delta];
        }
    }
}

- (void)optionSelected:(UIControl*)sender
{
    self.selectedIndex = [NSNumber numberWithInteger:sender.tag];
    
    [self setupWithField:self.field];
}

- (NSDictionary*)getValues;
{
    NSMutableDictionary* values = [NSMutableDictionary new];
    
    RIFieldOption* option = [self.field.options objectAtIndex:[self.selectedIndex integerValue]];
    [values setObject:option.value forKey:self.field.name];
    if (VALID_NOTEMPTY(option.subForm, RIForm) && VALID_NOTEMPTY_VALUE(option.subForm.fields, NSOrderedSet)) {
        for (int i = 0; i<self.subFormTextFieldsArray.count; i++) {
            UITextField* textField = [self.subFormTextFieldsArray objectAtIndex:i];
            NSString* value = textField.text;
            RIField* field = [option.subForm.fields objectAtIndex:i];
            
            [values setObject:value forKey:field.name];
        }
    }
    
    return [values copy];
}

-(BOOL)isValid
{
    BOOL valid = VALID_NOTEMPTY(self.selectedIndex, NSNumber);
    if (!valid) {
    
        //index wasn't even selected
        self.currentErrorMessage = self.field.requiredMessage;
    
    } else {
    
        //index was selected, let's check if there's a subForm inside
        RIFieldOption* option = [self.field.options objectAtIndex:[self.selectedIndex integerValue]];
        if (VALID_NOTEMPTY(option.subForm, RIForm) && VALID_NOTEMPTY_VALUE(option.subForm.fields, NSOrderedSet)) {
            
            //we know have to check each field for it's rules
            for (int i = 0; i<self.subFormTextFieldsArray.count; i++) {
                UITextField* textField = [self.subFormTextFieldsArray objectAtIndex:i];
                RIField* field = [option.subForm.fields objectAtIndex:i];
                
                //first let's check if there's a value there and if the field is required
                if ([field.required boolValue] && !VALID_NOTEMPTY(textField.text, NSString))
                {
                    [textField setTextColor:JARed1Color];
                    [textField setValue:JARed1Color forKeyPath:@"_placeholderLabel.textColor"];
                    self.currentErrorMessage = field.requiredMessage;
                    
                    return NO;
                }
                else
                {
                    NSString* pattern = field.pattern;
                    //now let's check if the value is according to the rules
                    if (VALID_NOTEMPTY(pattern, NSString)) {
                        if (![self validateInputWithString:textField.text andRegularExpression:pattern])
                        {
                            [textField setTextColor:JARed1Color];
                            [textField setValue:JARed1Color forKeyPath:@"_placeholderLabel.textColor"];
                            self.currentErrorMessage = field.patternMessage;
                            
                            return NO;
                        }
                    }
                }
            }
        }
    }
    
    return valid;
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

- (void)resetErrorFromTextField:(UITextField*)textField;
{
    [textField setTextColor:JABlackColor];
    [textField setValue:JABlack800Color forKeyPath:@"_placeholderLabel.textColor"];
}

-(NSString*)getFieldName
{
    return self.field.name;
}

- (NSDictionary *)getLabels
{
    NSMutableDictionary* labels = [NSMutableDictionary new];
    
    RIFieldOption* option = [self.field.options objectAtIndex:[self.selectedIndex integerValue]];
    [labels setObject:option.label forKey:self.field.name];
    
    return [labels copy];
}

-(void)setValue:(id)value
{
    int i = 0;
    for (RIFieldOption *option in self.field.options) {
        if ([option.value isEqual:value]) {
            self.selectedIndex = [NSNumber numberWithInt:i];
            [self setupWithField:self.field];
            return;
        }
        i++;
    }
}

@end
