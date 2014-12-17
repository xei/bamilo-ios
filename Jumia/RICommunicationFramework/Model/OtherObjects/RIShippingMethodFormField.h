//
//  RIShippingMethodFormField.h
//  Jumia
//
//  Created by Pedro Lopes on 28/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIShippingMethodFormField : NSObject

@property (nonatomic, strong) NSString * uid;
@property (nonatomic, strong) NSString * key;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * value;
@property (nonatomic, strong) NSString * label;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * scenario;
@property (nonatomic, assign) BOOL required;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong) NSArray *pickupStations;

/**
 * Method to parse a shipping method form field
 * 
 * @param the json object with the shipping method form field
 * @return a initialized shipping method form field
 */
+ (RIShippingMethodFormField *)parseField:(NSDictionary *)fieldJSON;

@end
