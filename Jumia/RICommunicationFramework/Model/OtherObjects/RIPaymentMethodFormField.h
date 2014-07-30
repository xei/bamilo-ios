//
//  RIPaymentMethodFormField.h
//  Jumia
//
//  Created by Pedro Lopes on 29/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIPaymentMethodFormField : NSObject

@property (nonatomic, strong) NSString * uid;
@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * value;
@property (nonatomic, strong) NSString * label;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * scenario;
@property (nonatomic, assign) BOOL required;
@property (nonatomic, strong) NSArray *options;

/**
 * Method to parse a payment method form field
 *
 * @param the json object with the payment method form field
 * @return a initialized payment method form field
 */
+ (RIPaymentMethodFormField *)parseField:(NSDictionary *)fieldJSON;


@end
