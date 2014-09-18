//
//  JANewsletterComponent.m
//  Jumia
//
//  Created by Miguel Chaves on 18/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JANewsletterComponent.h"
#import "RIField.h"

@interface JANewsletterComponent ()

@property (strong, nonatomic) RIField *field;
@property (strong, nonatomic) NSString *storedValue;

@end

@implementation JANewsletterComponent

+ (JANewsletterComponent *)getNewJANewsletterComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JANewsletterComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JANewsletterComponent class]]) {
            return (JANewsletterComponent *)obj;
        }
    }
    
    return nil;
}

- (void)setup
{
    [self.textLabel setTextColor:UIColorFromRGB(0x666666)];
    self.lineImageView.backgroundColor = UIColorFromRGB(0xcccccc);
    
    self.storedValue = @"";
}

- (void)setupWithField:(RIField *)field
{
    [self setup];
    
    self.field = field;
    
    if(VALID_NOTEMPTY(field.label, NSString))
    {
        [self.textLabel setText:field.label];
    }
    
    [self.optionSwitch addTarget:self
                          action:@selector(changedState:)
                forControlEvents:UIControlEventValueChanged];
    
    if(VALID_NOTEMPTY([self.field value], NSString))
    {
        self.storedValue = @"1";
        [self.optionSwitch setOn:YES
                        animated:NO];
    }
}

- (BOOL)isComponentWithKey:(NSString *)key
{
    return ([key isEqualToString:self.field.key]);
}

- (void)changedState:(id)sender
{
    BOOL state = [sender isOn];
    
    [self setStateValue:state];
}

- (void)setStateValue:(BOOL)state
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

- (void)resetValue
{
    if(VALID_NOTEMPTY([self.field value], NSString))
    {
        self.storedValue = @"1";
        [self.optionSwitch setOn:YES
                        animated:NO];
    }
    else
    {
        self.storedValue = @"";
        [self.optionSwitch setOn:NO
                        animated:NO];
    }
}

- (NSDictionary *)getValues
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    if(VALID_NOTEMPTY(self.storedValue, NSString) || [[self.field required] boolValue])
    {
        [parameters setValue:self.storedValue forKey:self.field.name];
    }
    
    return parameters;
}

- (void)setValue:(NSString *)value
{
    self.storedValue = value;
}

- (BOOL)isCheckBoxOn
{
    return self.optionSwitch.on;
}

- (NSArray *)getOptions
{
    return [[self.field options] array];
}

@end
