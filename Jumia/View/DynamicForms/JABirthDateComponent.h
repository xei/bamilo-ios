//
//  JABirthDateComponent.h
//  Jumia
//
//  Created by Pedro Lopes on 25/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIField.h"

@interface JABirthDateComponent : UIView

@property (assign, nonatomic) BOOL hasError;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *requiredSymbol;

+(JABirthDateComponent *)getNewJABirthDateComponent;

-(void)setupWithLabel:(NSString*)label day:(RIField*)day month:(RIField*)month year:(RIField*)year;

-(BOOL)isComponentWithKey:(NSString*)key;

-(void)setValue:(NSDate*)date;

-(NSDate*)getDate;

-(NSMutableDictionary*)getValues;

-(void)setError:(NSString*)error;

-(void)cleanError;

-(void)resetValue;

@end