//
//  JANewsletterComponent.h
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIField.h"
#import "JADynamicField.h"

@interface JANewsletterComponent : JADynamicField

@property (weak, nonatomic) IBOutlet UILabel *labelText;
@property (weak, nonatomic) IBOutlet UISwitch *switchComponent;
@property (weak, nonatomic) IBOutlet UIView *separator;

+ (JANewsletterComponent *)getNewJANewsletterComponent;

-(void)setup;

-(void)setupWithField:(RIField*)field;

-(void)resetValue;

-(BOOL)isCheckBoxOn;

-(NSArray*)getOptions;

@end
