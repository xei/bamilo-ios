//
//  RIPaymentMethodForm.h
//  Jumia
//
//  Created by Pedro Lopes on 29/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIPaymentMethodFormField.h"

@interface RIPaymentMethodForm : NSObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * method;
@property (nonatomic, retain) NSString * targetString;
@property (nonatomic, retain) NSArray *fields;

/**
 * Method to parse a payment method form
 *
 * @param the json object with the payment method form
 * @return a initialized payment method form
 */
+ (RIPaymentMethodForm *)parseForm:(NSDictionary *)formJSON;

/**
 * Method that returns a dictionary with all the key/values for the form fields
 *
 * @param the form that we want to know the parameters
 * @return a dictionary with the form key/value objects
 */
+ (NSDictionary *) getParametersForForm:(RIPaymentMethodForm *)form;

/**
 * Method that returns an array with all the payment methods
 *
 * @param the option that we want to know if has extra fields
 * @param the form that we want to know the extra fields
 * @return an array with the possible payment methods
 */
+ (NSArray *) getPaymentMethodsInForm:(RIPaymentMethodForm*)form;

/**
 * Method that returns the index of the default selected payment method
 *
 * @param the payment methods form
 * @return an index with the default payment method
 */
+ (NSInteger) getSelectedPaymentMethodsInForm:(RIPaymentMethodForm*)form;

/**
 * Method that returns an array with the extra fields needed for an option
 *
 * @param the option that we want to know if has extra fields
 * @param the form that we want to know the extra fields
 * @return an array with the extra fields needed
 */
+ (NSArray *) getExtraFieldsForOption:(NSString*)option
                               inForm:(RIPaymentMethodForm*)form;

@end
