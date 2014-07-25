//
//  RIAddress.h
//  Jumia
//
//  Created by Telmo Pinto on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIAddress : NSObject

@property (nonatomic, strong)NSString* uid;
@property (nonatomic, strong)NSString* firstName;
@property (nonatomic, strong)NSString* lastName;
@property (nonatomic, strong)NSString* address;
@property (nonatomic, strong)NSString* city;
@property (nonatomic, strong)NSString* postcode;
@property (nonatomic, strong)NSString* phone;
@property (nonatomic, strong)NSString* customerId;
@property (nonatomic, strong)NSString* countryId;
@property (nonatomic, strong)NSString* customerAddressRegionId;
@property (nonatomic, strong)NSString* customerAddressCityId;
@property (nonatomic, strong)NSString* isDefaultBilling;
@property (nonatomic, strong)NSString* isDefaultShipping;
@property (nonatomic, strong)NSString* hidden;
@property (nonatomic, strong)NSString* createdAt;
@property (nonatomic, strong)NSString* updatedAt;
@property (nonatomic, strong)NSString* createdBy;
@property (nonatomic, strong)NSString* updatedBy;
@property (nonatomic, strong)NSString* customerAddressRegion;
@property (nonatomic, strong)NSString* locale;

+ (NSString*)getBillingAddressWithSuccessBlock:(void (^)(id billingAddress))successBlock
                               andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;
+ (NSString*)getCustomerAddressListWithSuccessBlock:(void (^)(id adressList))successBlock
                                    andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;
+ (NSDictionary*)parseAddressList:(NSDictionary*)addressListJSON;
+ (RIAddress*)parseAddress:(NSDictionary*)addressJSON;

@end
