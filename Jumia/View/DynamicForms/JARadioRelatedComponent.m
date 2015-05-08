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

+ (JARadioRelatedComponent *)getNewJARadioRelatedComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JARadioRelatedComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JARadioRelatedComponent class]]) {
            return (JARadioRelatedComponent *)obj;
        }
    }
    
    return nil;
}

-(void)setup
{
    self.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.labelText.font = [UIFont fontWithName:kFontRegularName size:self.labelText.font.pointSize];
    [self.labelText setTextColor:UIColorFromRGB(0x666666)];
    self.labelText.adjustsFontSizeToFitWidth = YES;
    
    self.storedValue = @"";
}

-(void)setupWithField:(RIField*)field
{
    [self setup];
    
    self.field = field;
    
    RIFieldDataSetComponent* alternativeComponent = [field.dataSet lastObject];
    
    NSString* text = alternativeComponent.label;
    
    [self.switchComponent addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
    [self.switchComponent setAccessibilityLabel:text];
    self.labelText.text = text;
    
    [self resetValue];
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
    if(state)
    {
        self.storedValue = @"1";
    }
    else
    {
        self.storedValue = @"";
    }
}

-(void)resetValue
{
    self.storedValue = @"";
    [self.switchComponent setOn:NO animated:NO];
}

-(NSDictionary*)getValues
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(self.storedValue, NSString) || [[self.field required] boolValue])
    {
        RIFieldDataSetComponent* selectedComponent;
        if (VALID_NOTEMPTY(self.storedValue, NSString)) {
            selectedComponent = [self.field.dataSet lastObject];
        } else {
            selectedComponent = [self.field.dataSet firstObject];
        }
        [parameters setValue:selectedComponent.value forKey:self.field.name];
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


@end
