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

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * method;
@property (nonatomic, retain) NSString * action;
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

@end
