//
//  JARadioRelatedComponent.h
//  Jumia
//
//  Created by Telmo Pinto on 08/05/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIField.h"
#import "JADynamicField.h"

@interface JARadioRelatedComponent : JADynamicField

@property (strong, nonatomic) UILabel *labelText;
@property (strong, nonatomic) UISwitch *switchComponent;

-(void)setup;

-(void)setupWithField:(RIField*)field;

-(BOOL)isComponentWithKey:(NSString*)key;

-(void)resetValue;

-(NSDictionary*)getValues;

-(void)setValue:(NSString*)value;

-(BOOL)isCheckBoxOn;

@end
