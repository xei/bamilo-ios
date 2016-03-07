//
//  RIPaymentMethodFormOption.h
//  Jumia
//
//  Created by Pedro Lopes on 29/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIForm.h"

@interface RIPaymentMethodFormOption : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSString *tooltipText;
@property (nonatomic, strong) NSString *cvcText;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) RIForm *form;

/**
 * Method to parse a payment method form option
 *
 * @param the json object with the payment method form option
 * @return a initialized payment method form option
 */
+ (RIPaymentMethodFormOption *)parseField:(NSDictionary *)fieldJSON;

@end
