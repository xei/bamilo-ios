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
    NSString* xibName = @"JACheckBoxComponent";
    if (RI_IS_RTL) {
        xibName = [xibName stringByAppendingString:@"_RTL"];
    }
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:xibName
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
    
    if (VALID_NOTEMPTY(field.linkTargetString, NSString)) {
        [self.urlButton addTarget:self action:@selector(urlWasClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    NSMutableAttributedString* attributedText;
    NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                JABlackColor, NSForegroundColorAttributeName, nil];

    NSRange linkRange;
    if(VALID_NOTEMPTY(field.label, NSString))
    {
        if (VALID_NOTEMPTY(field.linkText, NSString)) {
            attributedText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@", field.label, field.linkText]
                                                                    attributes:attributes];
            NSDictionary* linkAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            UIColorFromRGB(0x55a1ff), NSForegroundColorAttributeName, nil];
            linkRange = NSMakeRange(field.label.length, field.linkText.length);
            [attributedText setAttributes:linkAttributes
                                      range:linkRange];
        } else {
            attributedText = [[NSMutableAttributedString alloc] initWithString:field.label
                                                                    attributes:attributes];
        }
    }
    self.labelText.attributedText = attributedText;

    [self.switchComponent addTarget:self action:@selector(changedState:) forControlEvents:UIControlEventValueChanged];
    [self.switchComponent setAccessibilityLabel:attributedText.string];
    
    if(VALID_NOTEMPTY([self.field value], NSString))
    {
        if ([[self.field value] isEqualToString:@"1"]) {
            self.storedValue = @"1";
            [self.switchComponent setOn:YES animated:NO];
        } else {
            self.storedValue = @"";
            [self.switchComponent setOn:NO animated:NO];
        }
    }
    
    if (VALID_NOTEMPTY(self.field.disabled, NSNumber) && YES == [self.field.disabled boolValue]) {
        [self.switchComponent setEnabled:NO];
    }
}

- (void)urlWasClicked
{
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    if (VALID_NOTEMPTY(self.field.linkText, NSString)) {
        [userInfo setObject:self.field.linkText forKey:@"title"];
    }
    
    NSString* notificationName = kDidSelectTeaserWithShopUrlNofication;
    
    if (VALID_NOTEMPTY(self.field.linkTargetString, NSString)) {
        [userInfo setObject:self.field.linkTargetString forKey:@"targetString"];
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName
                                                            object:nil
                                                          userInfo:userInfo];
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
