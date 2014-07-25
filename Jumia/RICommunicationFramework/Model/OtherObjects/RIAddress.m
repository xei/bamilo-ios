//
//  RIAddress.m
//  Jumia
//
//  Created by Telmo Pinto on 25/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIAddress.h"

@implementation RIAddress

+ (NSString*)getBillingAddressWithSuccessBlock:(void (^)(id billingAddress))successBlock
                               andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_GET_CUSTOMER_BILLING_ADDRESS]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  NSDictionary* data = [metadata objectForKey:@"data"];
                                                                  if (VALID_NOTEMPTY(data, NSDictionary)) {
                                                                      successBlock([RIAddress parseAddress:data]);
                                                                      return;
                                                                  }
                                                              } else {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject)) {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

+ (NSString*)getCustomerAddressListWithSuccessBlock:(void (^)(id adressList))successBlock
                                    andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_GET_CUSTOMER_ADDRESS_LIST]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                      successBlock([RIAddress parseAddressList:metadata]);
                                                              } else {
                                                                  failureBlock(nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject)) {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

+ (NSDictionary*)parseAddressList:(NSDictionary*)addressListJSON
{
    NSMutableDictionary* newAddressList = [NSMutableDictionary new];
    
    NSDictionary* shippingAddressJSON = [addressListJSON objectForKey:@"shipping"];
    if (VALID_NOTEMPTY(shippingAddressJSON, NSDictionary)) {
        [newAddressList setObject:[RIAddress parseAddress:shippingAddressJSON] forKey:@"shipping"];
    }
    
    NSDictionary* billingAddressJSON = [addressListJSON objectForKey:@"billing"];
    if (VALID_NOTEMPTY(billingAddressJSON, NSDictionary)) {
        [newAddressList setObject:[RIAddress parseAddress:billingAddressJSON] forKey:@"billing"];
    }
    
    NSMutableArray* otherAddressesArray = [NSMutableArray new];
    
    NSDictionary* otherAddressJSONArray = [addressListJSON objectForKey:@"other"];
    if (VALID_NOTEMPTY(otherAddressJSONArray, NSDictionary)) {
        [otherAddressJSONArray enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (VALID_NOTEMPTY(obj, NSDictionary)) {
                [otherAddressesArray addObject:[RIAddress parseAddress:obj]];
            }
        }];
    }
    
    if (VALID_NOTEMPTY(otherAddressesArray, NSMutableArray)) {
        [newAddressList setObject:[otherAddressesArray copy] forKey:@"other"];
    }
    
    return [newAddressList copy];
}

+ (RIAddress*)parseAddress:(NSDictionary*)addressJSON
{
    RIAddress* newAddress = [[RIAddress alloc] init];
    
    if ([addressJSON objectForKey:@"id_customer_address"]) {
        newAddress.uid = [addressJSON objectForKey:@"id_customer_address"];
    }
    if ([addressJSON objectForKey:@"first_name"]) {
        newAddress.firstName = [addressJSON objectForKey:@"first_name"];
    }
    if ([addressJSON objectForKey:@"last_name"]) {
        newAddress.lastName = [addressJSON objectForKey:@"last_name"];
    }
    if ([addressJSON objectForKey:@"address1"]) {
        newAddress.address = [addressJSON objectForKey:@"address1"];
    }
    if ([addressJSON objectForKey:@"city"]) {
        newAddress.city = [addressJSON objectForKey:@"city"];
    }
    if ([addressJSON objectForKey:@"postcode"]) {
        newAddress.postcode = [addressJSON objectForKey:@"postcode"];
    }
    if ([addressJSON objectForKey:@"phone"]) {
        newAddress.phone = [addressJSON objectForKey:@"phone"];
    }
    if ([addressJSON objectForKey:@"fk_customer"]) {
        newAddress.customerId = [addressJSON objectForKey:@"fk_customer"];
    }
    if ([addressJSON objectForKey:@"fk_country"]) {
        newAddress.countryId = [addressJSON objectForKey:@"fk_country"];
    }
    if ([addressJSON objectForKey:@"fk_customer_address_region"]) {
        newAddress.customerAddressRegionId = [addressJSON objectForKey:@"fk_customer_address_region"];
    }
    if ([addressJSON objectForKey:@"fk_customer_address_city"]) {
        newAddress.customerAddressCityId = [addressJSON objectForKey:@"fk_customer_address_city"];
    }
    if ([addressJSON objectForKey:@"is_default_billing"]) {
        newAddress.isDefaultBilling = [addressJSON objectForKey:@"is_default_billing"];
    }
    if ([addressJSON objectForKey:@"is_default_shipping"]) {
        newAddress.isDefaultShipping = [addressJSON objectForKey:@"is_default_shipping"];
    }
    if ([addressJSON objectForKey:@"hidden"]) {
        newAddress.hidden = [addressJSON objectForKey:@"hidden"];
    }
    if ([addressJSON objectForKey:@"created_at"]) {
        newAddress.createdAt = [addressJSON objectForKey:@"created_at"];
    }
    if ([addressJSON objectForKey:@"updated_at"]) {
        newAddress.updatedAt = [addressJSON objectForKey:@"updated_at"];
    }
    if ([addressJSON objectForKey:@"created_by"]) {
        newAddress.createdBy = [addressJSON objectForKey:@"created_by"];
    }
    if ([addressJSON objectForKey:@"customer_address_region"]) {
        newAddress.customerAddressRegion = [addressJSON objectForKey:@"customer_address_region"];
    }
    if ([addressJSON objectForKey:@"_locale"]) {
        newAddress.locale = [addressJSON objectForKey:@"_locale"];
    }
    
    return newAddress;
}

@end
