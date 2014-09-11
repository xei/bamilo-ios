//
//  JACheckoutForms.h
//  Jumia
//
//  Created by Pedro Lopes on 11/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RIPaymentMethodForm;
@class RIPaymentMethodFormOption;

@interface JACheckoutForms : NSObject

@property (nonatomic, strong) NSMutableDictionary *paymentMethodFormViews;

-(id)initWithPaymentMethodForm:(RIPaymentMethodForm*)paymentMethodForm;

-(UIView*)getPaymentMethodView:(RIPaymentMethodFormOption*)paymentMethod;

-(CGFloat)getPaymentMethodViewHeight:(RIPaymentMethodFormOption*)paymentMethod;

-(NSDictionary*)getValuesForPaymentMethod:(RIPaymentMethodFormOption*)paymentMethod;

@end
