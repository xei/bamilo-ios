//
//  JACheckBoxComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACheckBoxComponent.h"

@interface JACheckBoxComponent ()

@property (strong, nonatomic) RIField *field;
@property (strong, nonatomic) NSString *storedValue;

@end

@implementation JACheckBoxComponent

+ (JACheckBoxComponent *)getNewJACheckBoxComponent
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JACheckBoxComponent"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JACheckBoxComponent class]]) {
            return (JACheckBoxComponent *)obj;
        }
    }
    
    return nil;
}

-(void)setup
{
    [self.labelText setTextColor:UIColorFromRGB(0x666666)];
    
    self.storedValue = @"";
}

-(void)setupWithField:(RIField*)field
{
    [self setup];
    
    self.field = field;
    
    if(VALID_NOTEMPTY(field.label, NSString))
    {
        [self.labelText setText:field.label];
    }
    
    [self.switchComponent addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
    
    if(VALID_NOTEMPTY([self.field value], NSString))
    {
        self.storedValue = @"1";
        [self.switchComponent setOn:YES animated:NO];
    }
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
    if(VALID_NOTEMPTY([self.field value], NSString))
    {
        self.storedValue = @"1";
        [self.switchComponent setOn:YES animated:NO];
    }
    else
    {
        self.storedValue = @"";
        [self.switchComponent setOn:NO animated:NO];
    }
}

-(NSDictionary*)getValues
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if(VALID_NOTEMPTY(self.storedValue, NSString) || [[self.field required] boolValue])
    {
        [parameters setValue:self.storedValue forKey:self.field.name];
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

-(NSArray*)getOptions
{
    return [[self.field options] array];
}

@end
