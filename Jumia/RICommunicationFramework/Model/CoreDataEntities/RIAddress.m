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
@dynamic customerAddressPostcodeId;
@dynamic isDefaultBilling;
@dynamic isDefaultShipping;
@dynamic isValid;
@dynamic hidden;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic createdBy;
@dynamic updatedBy;
@dynamic customerAddressRegion;
@dynamic locale;
@dynamic customer;


+ (NSString*)setDefaultAddress:(RIAddress*)address
                     isBilling:(BOOL)isBilling
                  successBlock:(void (^)(RIApiResponse apiResponse, NSArray *successMessage))successBlock
               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    NSString* type = isBilling?@"billing":@"shipping";
    NSDictionary *parameters = @{@"id": address.uid, @"type" : type};
    
    NSString* urlPart = RI_API_GET_CUSTOMER_SELECT_DEFAULT;
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, urlPart]]
                                                            parameters:parameters httpMethod:HttpResponsePut
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              if (VALID_NOTEMPTY([jsonObject objectForKey:@"messages"], NSDictionary)) {
                                                                  NSDictionary *messages = [jsonObject objectForKey:@"messages"];
                                                                  if (VALID_NOTEMPTY([messages objectForKey:@"success"], NSArray)) {
                                                                      NSArray *success = [messages objectForKey:@"success"];
                                                                      if (VALID_NOTEMPTY([success valueForKey:@"message"], NSArray)) {
                                                                          NSArray *successMessage = [success valueForKey:@"message"];
                                                                          successBlock(apiResponse, successMessage);
                                                                          return;
                                                                      }
                                                                  }
                                                              }
                                                              successBlock(apiResponse, nil);
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

+ (NSString*)getCustomerAddressListWithSuccessBlock:(void (^)(id adressList))successBlock
                                    andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_CUSTOMER_ADDRESS_LIST]]
                                                            parameters:nil httpMethod:HttpResponsePost
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary)) {
                                                                  successBlock([RIAddress parseAddressList:metadata]);
                                                              } else if ([jsonObject objectForKey:@"success"] && ![jsonObject objectForKey:@"metadata"]) {
                                                                  successBlock(metadata);
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
    
    NSArray* otherAddressJSONArray = [addressListJSON objectForKey:@"other"];
    if (VALID_NOTEMPTY(otherAddressJSONArray, NSArray)) {
        for (NSDictionary* otherAddressJSON in otherAddressJSONArray) {
            if (VALID_NOTEMPTY(otherAddressJSON, NSDictionary)) {
                [otherAddressesArray addObject:[RIAddress parseAddress:otherAddressJSON]];
            }
        }
    }
    
    if (VALID_NOTEMPTY(otherAddressesArray, NSMutableArray)) {
        [newAddressList setObject:[otherAddressesArray copy] forKey:@"other"];
    }
    
    return [newAddressList copy];
}

+ (RIAddress*)parseAddress:(NSDictionary*)addressJSON
{
    //$$$ REVIEW THIS SHIT
    RIAddress* newAddress = (RIAddress *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RIAddress class])];
    
    if ([addressJSON objectForKey:@"id"]) {
        id addressID = [addressJSON objectForKey:@"id"];
        if ([addressID isKindOfClass:[NSString class]]) {
            newAddress.uid = addressID;
        } else if ([addressID isKindOfClass:[NSNumber class]]) {
            newAddress.uid = [(NSNumber*)addressID stringValue];
        }
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
    if ([addressJSON objectForKey:@"region"]) {
        newAddress.customerAddressRegionId = [addressJSON objectForKey:@"region"];
    }
    if ([addressJSON objectForKey:@"city"]) {
        newAddress.customerAddressCityId = [addressJSON objectForKey:@"city"];
    }
    if ([addressJSON objectForKey:@"postcode"]) {
        newAddress.customerAddressPostcodeId = [addressJSON objectForKey:@"postcode"];
    }
    if ([addressJSON objectForKey:@"is_default_billing"]) {
        newAddress.isDefaultBilling = [NSString stringWithFormat:@"%@", [addressJSON objectForKey:@"is_default_billing"]];
    }
    if ([addressJSON objectForKey:@"is_default_shipping"]) {
        newAddress.isDefaultShipping = [NSString stringWithFormat:@"%@", [addressJSON objectForKey:@"is_default_shipping"]];
    }
    if ([addressJSON objectForKey:@"is_valid"]) {
        newAddress.isValid = [NSString stringWithFormat:@"%@", [addressJSON objectForKey:@"is_valid"]];
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

+ (NSDictionary*)toJSON:(RIAddress*)address{
    NSMutableDictionary * addressJSON = [[NSMutableDictionary alloc] init];
    
    [addressJSON setValue:address.uid forKey:@"id_customer_address"];
    
    [addressJSON setValue:address.uid forKey:@"customer_address_id"];
    
    [addressJSON setValue:address.firstName forKey:@"first_name"];
    
    [addressJSON setValue:address.lastName forKey:@"last_name"];
    
    [addressJSON setValue:address.address forKey:@"address1"];
    
    [addressJSON setValue:address.address2 forKey:@"address2"];
    
    [addressJSON setValue:address.city forKey:@"city"];
    
    [addressJSON setValue:address.postcode forKey:@"postcode"];
    
    [addressJSON setValue:address.phone forKey:@"phone"];
    
    [addressJSON setValue:address.customerId forKey:@"fk_customer"];
    
    [addressJSON setValue:address.countryId forKey:@"fk_country"];
    
    [addressJSON setValue:address.customerAddressRegionId forKey:@"fk_customer_address_region"];
    
    [addressJSON setValue:address.customerAddressCityId forKey:@"fk_customer_address_city"];
    
    [addressJSON setValue:address.isDefaultBilling forKey:@"is_default_billing"];
    
    [addressJSON setValue:address.isDefaultShipping forKey:@"is_default_shipping"];
    
    [addressJSON setValue:address.hidden forKey:@"hidden"];
    
    [addressJSON setValue:address.createdAt forKey:@"created_at"];
    
    [addressJSON setValue:address.updatedAt forKey:@"updated_at"];
    
    [addressJSON setValue:address.createdBy forKey:@"created_by"];
    
    [addressJSON setValue:address.customerAddressRegion forKey:@"customer_address_region"];
    
    [addressJSON setValue:address.locale forKey:@"_locale"];
    
    return addressJSON;
}

+ (void)saveAddress:(RIAddress *)address andContext:(BOOL)save
{
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:address];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

@end
