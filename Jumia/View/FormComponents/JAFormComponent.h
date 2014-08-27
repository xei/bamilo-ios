//
//  JAFormComponent.h
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JATextField.h"
#import "JABirthDateComponent.h"
#import "JACheckBoxComponent.h"
#import "JAGenderComponent.h"

@interface JAFormComponent : NSObject <UITextFieldDelegate>

+(NSArray*)generateForm:(NSArray*)fields startingY:(CGFloat)startingY delegate:(id<UITextFieldDelegate>)delegate;
+(BOOL)hasErrors:(NSArray*)views;
+(NSDictionary*)getValues:(NSArray*)views form:(RIForm*)form;

@end
