//
//  RIShippingMethodForm.h
//  Jumia
//
//  Created by Pedro Lopes on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIShippingMethodFormField.h"

@interface RIShippingMethodForm : NSObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * method;
@property (nonatomic, retain) NSString * action;
@property (nonatomic, retain) NSArray *fields;

/**
 * Method to parse a shipping method form
 *
 * @param the json object with the shipping method form
 * @return a initialized shipping method form
 */
+ (RIShippingMethodForm *)parseForm:(NSDictionary *)formJSON;

/**
 * Method to get all the shipping methods present in a form
 *
 * @param the shipping method form
 * @return an array with all the shipping methods in the form
 */
+ (NSArray *) getShippingMethods:(RIShippingMethodForm *) form;

/**
 * Method to get all the fields that are specific to a scenario
 *
 * @param the scenario
 * @param the shipping method form
 * @return an array with the fields for a scenerio
 */
+ (NSArray *) getOptionsForScenario:(NSString *) key
                             inForm:(RIShippingMethodForm *) form;

/**
 * Method that returns a dictionary with all the key/values for the form fields
 *
 * @param the form that we want to know the parameters
 * @return a dictionary with the form key/value objects
 */
+ (NSDictionary *) getParametersForForm:(RIShippingMethodForm *)form;

@end
