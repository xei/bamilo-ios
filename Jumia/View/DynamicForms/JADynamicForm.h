//
//  JADynamicForm.h
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

@class RIForm;

@interface JADynamicForm : NSObject <UITextFieldDelegate>

@property (strong, nonatomic) RIForm *form;
@property (strong, nonatomic) NSMutableArray *formViews;

-(id)initWithForm:(RIForm*)form startingPosition:(CGFloat)startingY;

-(BOOL)checkErrors;

-(NSDictionary*)getValues;

@end
