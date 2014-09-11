//
//  JACheckoutForms.h
//  Jumia
//
//  Created by Pedro Lopes on 11/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RIPaymentMethodFormOption;

@interface JACheckoutForms : NSObject

+(UIView*)createPaymentMethodOptionView:(RIPaymentMethodFormOption*)paymentMethod;

+(CGFloat)getPaymentMethodOptionViewHeight:(RIPaymentMethodFormOption*)paymentMethod;

@end
