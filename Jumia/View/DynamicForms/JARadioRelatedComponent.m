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
    NSString* xibName = @"JARadioRelatedComponent";
    if (RI_IS_RTL) {
        xibName = [xibName stringByAppendingString:@"_RTL"];
    }
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:xibName
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
    
    RIField* lastRelatedField = [field.relatedFields lastObject];
    
    NSString* text = lastRelatedField.label;
    
    [self.switchComponent addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
    [self.switchComponent setAccessibilityLabel:text];
    self.labelText.text = text;
    
    self.switchComponent.on = [lastRelatedField.checked boolValue];
    
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
        RIField* selectedRelatedField;
        if (VALID_NOTEMPTY(self.storedValue, NSString)) {
            selectedRelatedField = [self.field.relatedFields lastObject];
        } else {
            selectedRelatedField = [self.field.relatedFields firstObject];
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


@end
