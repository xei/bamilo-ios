//
//  RIAddress.m
//  Jumia
//
//  Created by Miguel Chaves on 14/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RIAddress.h"
#import "RICustomer.h"


@implementation RIAddress

@dynamic uid;
@dynamic firstName;
@dynamic lastName;
@dynamic address;
@dynamic address2;
@dynamic city;
@dynamic postcode;
@dynamic phone;
@dynamic customerId;
@dynamic countryId;
@dynamic customerAddressRegionId;
@dynamic customerAddressCityId;
@dynamic isDefaultBilling;
@dynamic isDefaultShipping;
@dynamic hidden;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic createdBy;
@dynamic updatedBy;
@dynamic customerAddressRegion;
@dynamic locale;
@dynamic customer;

+ (NSString*)getCustomerAddressListWithSuccessBlock:(void (^)(id adressList))successBlock
                                    andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_CUSTOMER_ADDRESS_LIST]]
                                                            parameters:nil httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  successBlock([RIAddress parseAddressList:metadata]);
                                                              } else {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject)) {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else {
                                                                  failureBlock(apiResponse, nil);
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
    RIAddress* newAddress = (RIAddress *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIAddress class])];
    
    if ([addressJSON objectForKey:@"id_customer_address"]) {
        newAddress.uid = [addressJSON objectForKey:@"id_customer_address"];
    }
    else if ([addressJSON objectForKey:@"customer_address_id"]) {
        newAddress.uid = [addressJSON objectForKey:@"customer_address_id"];
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
    if ([addressJSON objectForKey:@"address2"]) {
        newAddress.address2 = [addressJSON objectForKey:@"address2"];
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

+ (RIAddress*)parseAddressFromCustomer:(NSString*)uid jsonObject:(NSDictionary*)addressJSON
{
    RIAddress* newAddress = (RIAddress *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIAddress class])];
    
    newAddress.uid = uid;
    
    return newAddress;
}

+ (void)saveAddress:(RIAddress *)address
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:address];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

@end
