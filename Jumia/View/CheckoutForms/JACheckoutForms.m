//
//  JACheckoutForms.m
//  Jumia
//
//  Created by Pedro Lopes on 11/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACheckoutForms.h"
#import "JADynamicForm.h"
#import "RIPaymentMethodFormOption.h"

@implementation JACheckoutForms

+(UIView*)createPaymentMethodOptionView:(RIPaymentMethodFormOption*)paymentMethod
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];

    if(VALID_NOTEMPTY(paymentMethod, RIPaymentMethodFormOption))
    {
        CGFloat totalHeight = 0.0f;
        
        if(VALID_NOTEMPTY(paymentMethod.form, RIForm))
        {
            JADynamicForm *dynamicForm = [[JADynamicForm alloc] initWithForm:paymentMethod.form delegate:nil startingPosition:0.0f];
            
            for (UIView *dynamicFormView in dynamicForm.formViews)
            {
                [view addSubview:dynamicFormView];
                totalHeight = CGRectGetMaxY(dynamicFormView.frame);
            }
        }
        
        totalHeight += 2.0f;
        
        if(VALID_NOTEMPTY(paymentMethod.text, NSString))
        {
            UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0f,
                                                                                  totalHeight,
                                                                                  264.0f,
                                                                                  1000.0f)];
            [descriptionLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f]];
            [descriptionLabel setNumberOfLines:0];
            [descriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
            [descriptionLabel setTextColor:UIColorFromRGB(0x666666)];
            [descriptionLabel setText:paymentMethod.text];
            [descriptionLabel sizeToFit];
            [view addSubview:descriptionLabel];
            totalHeight += descriptionLabel.frame.size.height + 13.0f;
        }
        
        [view setFrame:CGRectMake(0.0f,
                                  0.0f,
                                  308.0f,
                                  totalHeight)];
    }
    return view;
}

+(CGFloat)getPaymentMethodOptionViewHeight:(RIPaymentMethodFormOption*)paymentMethod
{
    UIView *view = [JACheckoutForms createPaymentMethodOptionView:paymentMethod];
    return view.frame.size.height;
}

@end
