//
//  Address.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Mantle/Mantle.h>

@class RICustomer;

@interface Address : MTLModel <MTLJSONSerializing>

@property (copy, nonatomic) NSString *uid;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (copy, nonatomic) NSString *address;
@property (copy, nonatomic) NSString *address1;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *postcode;
@property (copy, nonatomic) NSString *phone;
@property (assign, nonatomic) int isDefaultBilling;
@property (assign, nonatomic) int isDefaultShipping;
@property (assign, nonatomic) int isValid;

@end
