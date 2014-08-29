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

@property (strong, nonatomic) RIField *dayField;
@property (strong, nonatomic) RIField *monthField;
@property (strong, nonatomic) RIField *yearField;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *requiredSymbol;

+(JABirthDateComponent *)getNewJABirthDateComponent;

-(void)setupWithLabel:(NSString*)label day:(RIField*)day month:(RIField*)month year:(RIField*)year;

-(void)setValue:(NSDate*)date;

-(NSDate*)getValue;

@end