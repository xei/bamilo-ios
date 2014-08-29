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
#import "JARadioComponent.h"

@class RIForm;

@protocol JADynamicFormDelegate <NSObject>

@optional

- (void)changedFocus:(UIView *)view;

- (void)lostFocus;

- (void)openDatePicker:(JABirthDateComponent *)birthdayComponent;

- (void)openPicker:(JARadioComponent *)radioComponent;

@end

@interface JADynamicForm : NSObject <UITextFieldDelegate>

@property (strong, nonatomic) RIForm *form;
@property (strong, nonatomic) NSMutableArray *formViews;
@property (strong, nonatomic) id<JADynamicFormDelegate> delegate;

-(id)initWithForm:(RIForm*)form startingPosition:(CGFloat)startingY;

-(BOOL)checkErrors;

-(NSDictionary*)getValues;

-(void)resetValues;

@end
