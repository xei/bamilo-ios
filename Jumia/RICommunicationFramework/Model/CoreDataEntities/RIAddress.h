//
//  RIAddress.h
//  Jumia
//
//  Created by Miguel Chaves on 14/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RICustomer;

@interface RIAddress : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * address2;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * postcode;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * customerId;
@property (nonatomic, retain) NSString * countryId;
@property (nonatomic, retain) NSString * customerAddressRegionId;
@property (nonatomic, retain) NSString * customerAddressCityId;
@property (nonatomic, retain) NSString * isDefaultBilling;
@property (nonatomic, retain) NSString * isDefaultShipping;
@property (nonatomic, retain) NSString * hidden;
@property (nonatomic, retain) NSString * createdAt;
@property (nonatomic, retain) NSString * updatedAt;
@property (nonatomic, retain) NSString * createdBy;
@property (nonatomic, retain) NSString * updatedBy;
@property (nonatomic, retain) NSString * customerAddressRegion;
@property (nonatomic, retain) NSString * locale;
@property (nonatomic, retain) RICustomer *customer;

+ (NSString*)getBillingAddressWithSuccessBlock:(void (^)(id billingAddress))successBlock
                               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

+ (NSString*)getCustomerAddressListWithSuccessBlock:(void (^)(id adressList))successBlock
                                    andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

+ (NSDictionary*)parseAddressList:(NSDictionary*)addressListJSON;

+ (RIAddress*)parseAddress:(NSDictionary*)addressJSON;

+ (RIAddress*)parseAddressFromCustomer:(NSString*)uid jsonObject:(NSDictionary*)addressJSON;

+ (void)saveAddress:(RIAddress *)address;

@end
