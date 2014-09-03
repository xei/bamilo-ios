//
//  JACheckBoxComponent.m
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACheckBoxComponent.h"

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
    
    if(VALID_NOTEMPTY([[self field] value], NSString))
    {
        [self.switchComponent setOn:YES animated:NO];
    }
}

- (void)changedState:(id)sender
{
    BOOL state = [sender isOn];
    
    [self setValue:state];
}

-(void)setValue:(BOOL)state
{
    if(state)
    {
        [[self field] setValue:@"1"];
    }
    else
    {
        [[self field] setValue:@""];
    }
}

@end
