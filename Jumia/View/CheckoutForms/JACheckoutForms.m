//
//  JACheckoutForms.m
//  Jumia
//
//  Created by Pedro Lopes on 11/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACheckoutForms.h"
#import "JADynamicForm.h"
#import "RIPaymentMethodForm.h"
#import "RIPaymentMethodFormOption.h"

@interface JACheckoutForms ()

@property (strong, nonatomic) NSMutableDictionary *dynamicForms;

@end

@implementation JACheckoutForms

-(id)initWithPaymentMethodForm:(RIPaymentMethodForm*)paymentMethodForm width:(CGFloat)width
{
    self = [super init];
    if(self)
    {
        self.dynamicForms = [[NSMutableDictionary alloc] init];
        self.paymentMethodFormViews = [[NSMutableDictionary alloc] init];
        [self createPaymentMethodViews:paymentMethodForm width:width];
    }
    return self;
}

-(void)createPaymentMethodViews:(RIPaymentMethodForm*)paymentMethodForm width:(CGFloat)width
{
    NSArray *paymentMethods = [RIPaymentMethodForm getPaymentMethodsInForm:paymentMethodForm];
    
    if(VALID_NOTEMPTY(paymentMethods, NSArray))
    {
        for(RIPaymentMethodFormOption *paymentMethod in paymentMethods)
        {
            if(VALID_NOTEMPTY(paymentMethod, RIPaymentMethodFormOption))
            {
                UIView *paymentMethodView = [[UIView alloc] init];
                CGFloat totalHeight = 0.0f;
                
                if(VALID_NOTEMPTY(paymentMethod.form, RIForm))
                {
                    JADynamicForm *dynamicForm = [[JADynamicForm alloc] initWithForm:paymentMethod.form startingPosition:0.0f widthSize:width hasFieldNavigation:YES];
                    
                    [self.dynamicForms setObject:dynamicForm forKey:paymentMethod.uid];
                    
                    for (UIView *dynamicFormView in dynamicForm.formViews)
                    {
                        [dynamicFormView setFrame:CGRectMake(dynamicFormView.frame.origin.x,
                                                             dynamicFormView.frame.origin.y,
                                                             width,
                                                             dynamicFormView.frame.size.height)];
                        [paymentMethodView addSubview:dynamicFormView];
                        totalHeight = CGRectGetMaxY(dynamicFormView.frame);
                    }
                }
                
                totalHeight += 2.0f;
                
                if(VALID_NOTEMPTY(paymentMethod.text, NSString))
                {
                    UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0f,
                                                                                          totalHeight,
                                                                                          width - (27.0f * 2),
                                                                                          1000.0f)];
                    [descriptionLabel setFont:[UIFont fontWithName:kFontLightName size:13.0f]];
                    [descriptionLabel setNumberOfLines:0];
                    [descriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
                    [descriptionLabel setTextColor:UIColorFromRGB(0x666666)];
                    [descriptionLabel setText:paymentMethod.text];
                    [descriptionLabel setTextAlignment:NSTextAlignmentLeft];
                    [descriptionLabel sizeToFit];
                    [paymentMethodView addSubview:descriptionLabel];
                    totalHeight += descriptionLabel.frame.size.height + 13.0f;
                }
                
                [paymentMethodView setFrame:CGRectMake(0.0f,
                                                       0.0f,
                                                       width,
                                                       totalHeight)];
                if (RI_IS_RTL) {
                    [paymentMethodView flipAllSubviews];
                }
                [self.paymentMethodFormViews setValue:paymentMethodView forKey:paymentMethod.uid];
            }
        }
    } else {
        
        UIView *paymentMethodView = [[UIView alloc] init];
        CGFloat totalHeight = 0.0f;
        

            UILabel *descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(27.0f,
                                                                                  totalHeight,
                                                                                  width - (27.0f * 2),
                                                                                  1000.0f)];
        [descriptionLabel setFont:[UIFont fontWithName:kFontLightName size:descriptionLabel.font.pointSize]];
        [descriptionLabel setNumberOfLines:0];
        [descriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
        [descriptionLabel setTextColor:UIColorFromRGB(0x666666)];
        [descriptionLabel setText:((RIPaymentMethodFormField*)[paymentMethodForm.fields firstObject]).value];
        [descriptionLabel setTextAlignment:NSTextAlignmentCenter];
        [descriptionLabel sizeToFit];
        [descriptionLabel setWidth:width - (27.0f * 2)];
        [paymentMethodView addSubview:descriptionLabel];
        totalHeight += descriptionLabel.frame.size.height + 23.0f;
        
        [paymentMethodView setFrame:CGRectMake(0.0f,
                                               0.0f,
                                               width,
                                               totalHeight)];
        if (RI_IS_RTL) {
            [paymentMethodView flipAllSubviews];
        }
        [self.paymentMethodFormViews setValue:paymentMethodView forKey:@"0"];
    }
}

-(UIView*)getPaymentMethodView:(RIPaymentMethodFormOption*)paymentMethod
{
    UIView *paymentMethodView = [[UIView alloc] init];
    
    if (VALID_NOTEMPTY(paymentMethod, RIPaymentMethodFormOption)) {
        if(VALID_NOTEMPTY(self.paymentMethodFormViews, NSMutableDictionary))
        {
            paymentMethodView = [self.paymentMethodFormViews objectForKey:paymentMethod.uid];
        }
    } else {
        if (VALID_NOTEMPTY(self.paymentMethodFormViews, NSMutableDictionary)) {
            paymentMethodView = [self.paymentMethodFormViews objectForKey:@"0"];
        }
    }
    
    return paymentMethodView;
}

-(CGFloat)getPaymentMethodViewHeight:(RIPaymentMethodFormOption*)paymentMethod
{
    CGFloat paymentMethodViewHeight = 0.0f;
    
    if(VALID_NOTEMPTY(self.paymentMethodFormViews, NSMutableDictionary))
    {
        
        UIView *paymentMethodView;
        if (VALID_NOTEMPTY(paymentMethod, RIPaymentMethodFormOption)) {
            paymentMethodView = [self.paymentMethodFormViews objectForKey:paymentMethod.uid];
        } else {
            paymentMethodView = [self.paymentMethodFormViews objectForKey:@"0"];
        }
        paymentMethodViewHeight = paymentMethodView.frame.size.height;
    }
    
    return paymentMethodViewHeight;
}

-(NSDictionary*)getValuesForPaymentMethod:(RIPaymentMethodFormOption*)paymentMethod
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    JADynamicForm *dynamicForm = [self.dynamicForms objectForKey:paymentMethod.uid];
    [parameters addEntriesFromDictionary:[dynamicForm getValues]];
    
    return [parameters copy];
}

@end
