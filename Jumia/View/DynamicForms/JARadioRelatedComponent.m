//
//  JARadioRelatedComponent.m
//  Jumia
//
//  Created by Telmo Pinto on 08/05/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import "JARadioRelatedComponent.h"
#import "RIFieldDataSetComponent.h"

@interface JARadioRelatedComponent ()

@property (strong, nonatomic) RIField *field;
@property (strong, nonatomic) NSString *storedValue;

@end

@implementation JARadioRelatedComponent

- (UILabel *)labelText
{
    if (!VALID_NOTEMPTY(_labelText, UILabel)) {
        _labelText = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.switchComponent.frame) + 16.f, 0,
                                                              self.width, self.height)];
        [_labelText setFont:JABody3Font];
        [_labelText setTextColor:JABlack900Color];
        [_labelText setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_labelText];
    }
    return _labelText;
}

- (UISwitch *)switchComponent
{
    if (!VALID_NOTEMPTY(_switchComponent, UISwitch)) {
        _switchComponent = [UISwitch new];
        [_switchComponent setFrame:CGRectMake( 8.f, (self.height - _switchComponent.height) / 2,
                                              _switchComponent.width, _switchComponent.height)];
        [_switchComponent addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:_switchComponent];
    }
    return _switchComponent;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setFrame:CGRectMake(8.f, 0, 288.f, 48.f)];
    }
    return self;
}

-(void)setupWithField:(RIField*)field
{
    
    self.field = field;
    
    RIField* firstRelatedField = [field.relatedFields firstObject];
    
    [self.switchComponent setOn:[firstRelatedField.checked boolValue] animated:NO];

    [self changedState:self.switchComponent];
    
    [self flipIfIsRTL];
}

-(BOOL)isComponentWithKey:(NSString*)key
{
    return ([key isEqualToString:self.field.key]);
}

-(void)changedState:(id)sender
{
    BOOL state = [sender isOn];
    
    [self setStateValue:state];
}

-(void)setStateValue:(BOOL)state
{
    if(state) {
        self.storedValue = @"1";
        RIField* firstRelatedField = [self.field.relatedFields firstObject];
        self.labelText.text = firstRelatedField.label;
    }
    else {
        self.storedValue = @"0";
        RIField* lastRelatedField = [self.field.relatedFields lastObject];
        self.labelText.text = lastRelatedField.label;
    }
}

-(NSDictionary*)getValues
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(self.storedValue, NSString) || [[self.field required] boolValue])
    {
        RIField* selectedRelatedField = [self.field.relatedFields lastObject];;
        if (VALID_NOTEMPTY(self.storedValue, NSString)) {
            if ([self.storedValue isEqualToString:@"1"]) {
                selectedRelatedField = [self.field.relatedFields firstObject];
            }
        }
        [parameters setValue:selectedRelatedField.value forKey:selectedRelatedField.name];
    }
    return parameters;
}

-(void)setValue:(NSString*)value
{
    self.storedValue = value;
}

-(BOOL)isCheckBoxOn
{
    return self.switchComponent.on;
}

-(NSString*)getFieldName
{
    return self.field.name;
}

-(BOOL)isValid
{
    if (![self.storedValue isEqualToString:@"1"] && ![self.storedValue isEqualToString:@"0"]) {
        return NO;
    }
    return YES;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    
    [self.switchComponent setFrame:CGRectMake( 8.f, (self.height - self.switchComponent.height) / 2,
                                              self.switchComponent.width, self.switchComponent.height)];

    [self.labelText setFrame:CGRectMake(CGRectGetMaxX(self.switchComponent.frame) + 16.f, 0,
                                                               self.width, self.height)];
    [self.labelText setTextAlignment:NSTextAlignmentLeft];
    
    [self flipIfIsRTL];
}

- (void)flipIfIsRTL
{
    if (RI_IS_RTL) {
        [self.switchComponent flipViewPositionInsideSuperview];
        [self.labelText flipViewPositionInsideSuperview];
        [self.labelText flipViewAlignment];
    }
}

@end
