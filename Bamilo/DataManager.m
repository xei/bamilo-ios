//
//  DataManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"
#import "Models.pch"
#import "RICart.h"
#import "RIForm.h"
#import "RICustomer.h"

@implementation DataManager

static DataManager *instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[DataManager alloc] init];
    });
    
    return instance;
}


//### AREA_INFORMATION
- (void)getVicinity:(id<DataServiceProtocol>)target forCityId:(NSString *)uid completion:(DataCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"%@city_id/%@", RI_API_GET_CUSTOMER_POSTCODES, uid];
    [self getAreaZone:target type:REQUEST_EXEC_IN_BACKGROUND path:path completion:completion];
}
- (void)getCities:(id<DataServiceProtocol>)target forRegionId:(NSString *)uid completion:(DataCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"%@region/%@", RI_API_GET_CUSTOMER_CITIES, uid];
    [self getAreaZone:target type:REQUEST_EXEC_IN_BACKGROUND path:path completion:completion];
}
- (void)getRegions:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [self getAreaZone:target type:REQUEST_EXEC_IN_BACKGROUND path:RI_API_GET_CUSTOMER_REGIONS completion:completion];
}
- (void)getAreaZone:(id<DataServiceProtocol>)target type:(RequestExecutionType)type path:(NSString *)path completion:(DataCompletion)completion {
    [RequestManager asyncGET:target path:path params:nil type:type completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            //Please skip this tof for now! @Narbeh
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            for (NSDictionary *region in  data[@"data"]) {
                dictionary[region[@"label"]] = [NSString stringWithFormat:@"%@", region[@"value"]];
            }
            completion(dictionary, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}
- (void)getAddress:(id<DataServiceProtocol>)target byId:(NSString *)uid completion:(DataCompletion)completion {
    [RequestManager asyncGET:target
                        path:[NSString stringWithFormat:@"%@?id=%@", RI_API_GET_CUSTOMER_ADDDRESS, uid]
                      params:nil
                        type:REQUEST_EXEC_IN_FOREGROUND
                  completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
                      [self serialize:data into:[Address class] response:response errorMessages:errorMessages completion:completion];
                  }];
}
- (void)updateAddress:(id<DataServiceProtocol>)target params:(NSMutableDictionary *)params withID:(NSString *)uid completion:(DataCompletion)completion {
    NSString *path = uid ? [NSString stringWithFormat:@"%@%@", RI_API_POST_CUSTOMER_ADDDRESS_EDIT, uid] : RI_API_POST_CUSTOMER_ADDDRESS_CREATE;
    
    [RequestManager asyncPOST:target path:path params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}


//### LOGIN ###
- (void)loginUser:(id<DataServiceProtocol>)target withUsername:(NSString *)username password:(NSString *)password completion:(DataCompletion)completion {
    NSDictionary *params = @{
         @"login[email]": username,
         @"login[password]": password
    };
    [RequestManager asyncPOST:target path:RI_API_LOGIN_CUSTOMER params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            [RICustomer parseCustomerWithJson:[data objectForKey:@"customer_entity"] plainPassword:password loginMethod:@"normal"];
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}

//### FORGET PASSWORD ###
- (void)forgetPassword:(id<DataServiceProtocol>)target withFields:(NSDictionary *)fields completion:(DataCompletion)completion {
    [RequestManager asyncPOST:target path:RI_API_FORGET_PASS_CUSTOMER params:fields type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}

//### SIGNUP ###
- (void)signupUser:(id<DataServiceProtocol>)target withFieldsDictionary:(NSMutableDictionary *)fields completion:(DataCompletion)completion {
    //must be remove from server side!
    fields[@"customer[phone_prefix]"] = @"100";
    [RequestManager asyncPOST:target path:RI_API_REGISTER_CUSTOMER params:fields type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            [RICustomer parseCustomerWithJson:[data objectForKey:@"customer_entity"] plainPassword:fields[@"customer[password]"] loginMethod:@"normal"];
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}

//### ADDRESS ###
- (void)getUserAddressList:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [RequestManager asyncPOST:target path:RI_API_GET_CUSTOMER_ADDRESS_LIST params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[AddressList class] response:response errorMessages:errorMessages completion:completion];
    }];
}

- (void)setDefaultAddress:(id<DataServiceProtocol>)target address:(Address *)address isBilling:(BOOL)isBilling completion:(DataCompletion)completion {
    NSDictionary *params = @{
         @"id": address.uid,
         @"type": isBilling ? @"billing" : @"shipping"
    };
    
    [RequestManager asyncPUT:target path:RI_API_GET_CUSTOMER_SELECT_DEFAULT params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[AddressList class] response:response errorMessages:errorMessages completion:completion];
    }];
}

-(void)deleteAddress:(id<DataServiceProtocol>)target address:(Address *)address completion:(DataCompletion)completion {
    NSDictionary *params = @{
        @"id": address.uid
    };
    
    [RequestManager asyncDELETE:target path:RI_API_DELETE_ADDRESS_REMOVE params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self processResponse:response forData:data errorMessages:errorMessages completion:completion];
    }];
}

//### CART ###
- (void)getUserCart:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [RequestManager asyncPOST:target path:RI_API_GET_CART_DATA params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[RICart class] response:response errorMessages:errorMessages completion:completion];
    }];
}

//### ORDER ###
-(void)getMultistepAddressList:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [RequestManager asyncGET:target path:RI_API_MULTISTEP_GET_ADDRESSES params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[RICart class] response:response errorMessages:errorMessages completion:completion];
    }];
}

-(void)setMultistepAddress:(id<DataServiceProtocol>)target forShipping:(NSString *)shippingAddressId billing:(NSString *)billingAddressId completion:(DataCompletion)completion {
    NSDictionary *params = @{
        @"addresses[shipping_id]": shippingAddressId,
        @"addresses[billing_id]": billingAddressId
    };
    
    [RequestManager asyncPOST:target path:RI_API_MULTISTEP_SUBMIT_ADDRESSES params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[MultistepEntity class] response:response errorMessages:errorMessages completion:completion];
    }];
}

-(void)getMultistepConfirmation:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [RequestManager asyncGET:target path:RI_API_MULTISTEP_GET_FINISH params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[RICart class] response:response errorMessages:errorMessages completion:completion];
    }];
}

-(void) getMultistepShipping:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [RequestManager asyncGET:target path:RI_API_MULTISTEP_GET_SHIPPING params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[RICart class] response:response errorMessages:errorMessages completion:completion];
    }];
}

/*-(void) setMultistepShipping:(id<DataServiceProtocol>)target forShippingMethod:(NSString*)shippingMethod pickupStation:(NSString*)pickupStation region:(NSString*)region completion:(DataCompletion)completion {
    NSDictionary *params = @{
         @"shipping_method[shipping_method]": shippingMethod,
         @"shipping_method[pickup_station]": pickupStation,
         @"shipping_method[pickup_station_customer_address_region]": region
    };
    
    [RequestManager asyncPOST:target path:RI_API_MULTISTEP_SUBMIT_SHIPPING params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[RICart class] response:response errorMessages:errorMessages completion:completion];
    }];
}*/

- (void) getMultistepPayment:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [RequestManager asyncGET:target path:RI_API_MULTISTEP_GET_PAYMENT params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[RICart class] response:response errorMessages:errorMessages completion:completion];
    }];
}

-(void)setMultistepPayment:(id<DataServiceProtocol>)target params:(NSDictionary *)params completion:(DataCompletion)completion {
    [RequestManager asyncPOST:target path:RI_API_MULTISTEP_SUBMIT_PAYMENT params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[MultistepEntity class] response:response errorMessages:errorMessages completion:completion];
    }];
}

-(void) setMultistepConfirmation:(id<DataServiceProtocol>)target cart:(RICart *)cart completion:(DataCompletion)completion {
    NSDictionary *params = @{
        @"app": @"ios",
        @"customer_device": UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ? @"tablet" : @"mobile"
    };
    
    [RequestManager asyncPOST:target path:RI_API_MULTISTEP_SUBMIT_FINISH params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        if(completion != nil) {
            completion([RICart parseCheckoutFinish:data forCart:cart], nil);
        }
    }];
}

//### COUPON ###
-(void) applyVoucher:(id<DataServiceProtocol>)target voucherCode:(NSString *)voucherCode completion:(DataCompletion)completion {
    NSDictionary *params = @{
         @"couponcode": voucherCode
    };
    [RequestManager asyncPOST:target path:RI_API_ADD_VOUCHER_TO_CART params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[RICart class] response:response errorMessages:errorMessages completion:completion];
    }];
}

-(void) removeVoucher:(id<DataServiceProtocol>)target voucherCode:(NSString *)voucherCode completion:(DataCompletion)completion {
    NSDictionary *params = @{
        @"couponcode": voucherCode
    };
    [RequestManager asyncDELETE:target path:RI_API_REMOVE_VOUCHER_FROM_CART params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
        [self serialize:data into:[RICart class] response:response errorMessages:errorMessages completion:completion];
    }];
}

#pragma mark - Private Methods
- (void)serialize:(id)data into:(Class)aClass response:(RIApiResponse)response errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion {
    [self processResponse:response forData:data errorMessages:errorMessages completion:^(id data, NSError *error) {
        if(error == nil && data) {
            id dataModel;
            
            if([aClass conformsToProtocol:@protocol(JSONVerboseModel)]) {
                [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                    completion([aClass parseToDataModelWithObjects:@[ data, configuration ]], nil);
                } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                    completion(nil, [self getErrorFrom:apiResponse errorMessages:errorMessages]);
                }];
            } else {
                NSError *error;
                dataModel = [[aClass alloc] init];
                [dataModel mergeFromDictionary:data useKeyMapping:YES error:&error];
                
                if(error == nil) {
                    completion(dataModel, nil);
                } else {
                    completion(nil, error);
                }
            }
        } else {
            completion(nil, error);
        }
    }];
}

-(void) processResponse:(RIApiResponse)response forData:(id)data errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion {
    if(completion) {
        if(response == RIApiResponseSuccess && data) {
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }
}

#pragma mark - Helpers
- (NSError *)getErrorFrom:(RIApiResponse)response errorMessages:(NSArray *)errorMessages {
    return [NSError errorWithDomain:@"com.bamilo.ios" code:response userInfo:(errorMessages ? @{ kErrorMessages: errorMessages } : nil)];
}

@end
