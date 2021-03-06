//
//  RICustomer.m
//  Jumia
//
//  Created by Miguel Chaves on 14/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICustomer.h"
#import "RIForm.h"
#import "RIField.h"
#import "ViewControllerManager.h"
#import "Bamilo-Swift.h"
#import <Crashlytics/Crashlytics.h>

#define kUserIsGuestFlagKey [NSString stringWithFormat:@"%@_user_is_guest", [RIApi getCountryIsoInUse]]

@interface RICustomer ()

@property (strong, nonatomic) NSString* costumerRequestID;

@end

@implementation RICustomer

@dynamic customerId;
@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic birthday;
@dynamic gender;
@dynamic password;
@dynamic plainPassword;
@dynamic createdAt;
@dynamic loginMethod;
@dynamic addresses;
@dynamic newsletterSubscribed;
@synthesize costumerRequestID, wishlistProducts;
@synthesize addressList;
@synthesize phone;
@synthesize nationalID;
@synthesize bankCartNumber;

+ (NSString *)signUpAccount:(NSString *)email
               successBlock:(void (^)(id object))successBlock
            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorObject))failureBlock {
    NSString* urlEnding;
    if (VALID_NOTEMPTY(email, NSString)) {
        urlEnding = [NSString stringWithFormat:@"customer/createsignup/?email=%@", email];
    }
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, urlEnding]]
                                                            parameters:nil
                                                            httpMethod:HttpVerbGET
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              
                                                              if (VALID([jsonObject objectForKey:@"success"], NSNumber)) {
                                                                  
                                                                  NSNumber* success = [jsonObject objectForKey:@"success"];
                                                                  if (success) {
                                                                      NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                                      if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                                      {
                                                                          NSDictionary* entities = [RIForm parseEntities:metadata plainPassword:nil loginMethod:@"guest"];
                                                                          [RICustomer setCustomerAsGuest];
                                                                          successBlock(entities);
                                                                      }
                                                                  } else {
                                                                      failureBlock(apiResponse, [RIError getErrorMessages:jsonObject]);
                                                                  }
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject)) {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject)) {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

+ (NSString *)checkEmail:(NSString *)email
            successBlock:(void (^)(BOOL knownEmail, RICustomer *customerAlreadyLoggedIn))successBlock
         andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorObject))failureBlock {
    NSString* urlEnding;
    NSDictionary *parameters;
    if(VALID_NOTEMPTY(email, NSString)) {
        parameters = [NSDictionary dictionaryWithObject:email forKey:@"email"];
        urlEnding = [NSString stringWithFormat:@"customer/emailcheck/"];
    }
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, urlEnding]]
                                                            parameters:parameters
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              NSDictionary* messages = [jsonObject objectForKey:@"messages"];
                                                              NSDictionary *error = nil;
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  if (VALID_NOTEMPTY(messages, NSDictionary)) {
                                                                      if (VALID_NOTEMPTY([messages objectForKey:@"error"], NSArray)) {
                                                                          if (VALID_NOTEMPTY([[messages objectForKey:@"error"] firstObject], NSDictionary)) {
                                                                              error = [[messages objectForKey:@"error"] firstObject];
                                                                          }
                                                                      }
                                                                  }
                                                                  NSNumber* exists = [metadata objectForKey:@"exist"];
                                                                  if (VALID_NOTEMPTY(exists, NSNumber))
                                                                  {
                                                                      successBlock([exists boolValue], nil);
                                                                  } else if (VALID_NOTEMPTY(error, NSDictionary)) {
                                                                      if (VALID_NOTEMPTY([error objectForKey:@"code"], NSNumber) && [[error objectForKey:@"code"] isEqualToNumber:@232]) {
                                                                          RICustomer *customer = [RICustomer parseCustomerWithJson:[metadata objectForKey:@"customer_entity"]];
                                                                          successBlock(NO, customer);
                                                                      }
                                                                  } else
                                                                  {
                                                                      failureBlock(apiResponse, [RIError getErrorMessages:jsonObject]);
                                                                  }
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

//TODO: !!! we should really decide about this
+ (NSString*)autoLogin:(void (^)(BOOL success))returnBlock {
    NSString *operationID = nil;
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    if (customers.count > 0) {
        __block RICustomer *customerObject = [customers lastObject];
        if (customerObject && customerObject.email.length && customerObject.plainPassword.length) {
//            [DataAggregator loginUser:nil username:customerObject.email password:customerObject.plainPassword completion:^(id _Nullable data, NSError * _Nullable error) {
//                if (error == nil) {
//                    if (returnBlock != nil) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            returnBlock(YES);
//                        });
//                    }
//                } else {
//                    [Utility resetUserBehaviours];
//                    if (returnBlock != nil) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            returnBlock(NO);
//                        });
//                    }
//                }
//            }];
            
            //Set auto logged in customer
//            [EmarsysPredictManager setCustomer:customerObject];
//            [PushWooshTracker setUserID:[customerObject.customerId stringValue]];
            [[Crashlytics sharedInstance] setUserEmail:customerObject.email];
            [[Crashlytics sharedInstance] setUserIdentifier: [NSString stringWithFormat:@"%ld", (long)customerObject.customerId.integerValue]];
            
        } else {
            [Utility resetUserBehaviours];
            if (returnBlock != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    returnBlock(NO);
                });
            }
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            returnBlock(NO);
        });
    }
    
    return operationID;
}

+ (RICustomer *)getCurrentCustomer {
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    if (customers.count) {
        RICustomer *customer = (RICustomer *)[customers lastObject];
        return customer;
    }
    return nil;
}

+ (NSString *)getCustomerId {
    RICustomer *customer = [RICustomer getCurrentCustomer];
    if (customer) {
        return [customer.customerId stringValue];
    } else {
        return @"0";
    }
}

+ (NSString *)getCustomerGender {
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    NSString *gender = nil;
    if (customers.count > 0) {
        RICustomer *customer = (RICustomer *)[customers lastObject];
        gender = customer.gender;
    }
    
    return gender;
}

+ (BOOL)wasSignup {
    BOOL wasSignup = NO;
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    if (customers.count > 0) {
        RICustomer *customer = (RICustomer *)[customers lastObject];
        wasSignup = [@"signup" isEqualToString:customer.loginMethod];
    }
    
    return wasSignup;
}

#pragma mark - Get customer
+ (NSString *)getCustomerWithSuccessBlock:(void (^)(id customer))successBlock andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock {
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    if (customers.count > 0) {
        successBlock([customers lastObject]);
        return nil;
    }
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_CUSTOMER]]
                                                            parameters:nil
                                                            httpMethod:HttpVerbPOST
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (metadata && [metadata isKindOfClass:[NSDictionary class]]) {
                                                                  if (VALID_NOTEMPTY([metadata objectForKey:@"customer_entity"], NSDictionary)) {
                                                                      successBlock([self parseCustomerWithJson:[metadata objectForKey:@"customer_entity"]]);
                                                                      return;
                                                                  }
                                                              }
                                                              failureBlock(apiResponse, nil);
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}


+ (void)cleanCustomerFromDB {
    [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RICustomer class])];
    [[RIDataBaseWrapper sharedInstance] saveContext];
    
    //Reset cartEntity of sharedInstance cart
    [RICart sharedInstance].cartEntity.cartItems = @[];
}

//+ (NSString *)requestPasswordReset:(void (^)(void))successBlock
//                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorObject))failureBlock {
//    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_LOGOUT_CUSTOMER]]
//                                                            parameters:nil
//                                                            httpMethod:HttpVerbPOST
//                                                             cacheType:RIURLCacheNoCache
//                                                             cacheTime:RIURLCacheDefaultTime
//                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
//                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
//                                                              successBlock();
//                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
//                                                              if(NOTEMPTY(errorJsonObject)) {
//                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
//                                                              } else if(NOTEMPTY(errorObject)) {
//                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
//                                                                  failureBlock(apiResponse, errorArray);
//                                                              } else {
//                                                                  failureBlock(apiResponse, nil);
//                                                              }
//                                                          }];
//}

+ (BOOL)checkIfUserIsLogged {
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    
    if (VALID_NOTEMPTY(customers, NSArray)) {
        return YES;
    } else {
        return NO;
    }
}

+ (void)setCustomerAsGuest {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserIsGuestFlagKey];
}

+ (void)resetCustomerAsGuest {
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kUserIsGuestFlagKey];
}

+ (BOOL)checkIfUserIsLoggedAsGuest {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserIsGuestFlagKey];
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID {
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

+ (void)saveCustomer:(RICustomer *)customer andContext:(BOOL)save {
//    for (RIAddress *address in customer.addresses) {
//        [RIAddress saveAddress:address andContext:NO];
//    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:customer];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

+ (NSDictionary *)toJSON:(RICustomer*)customer {
    NSMutableDictionary * json = [[NSMutableDictionary alloc] init];
    
    [json setValue:customer.customerId forKey:@"id"];
    
    [json setValue:customer.email forKey:@"email"];
    
    [json setValue:customer.firstName forKey:@"first_name"];
    
    [json setValue:customer.lastName forKey:@"last_name"];
    
    [json setValue:customer.birthday forKey:@"birthday"];
    
    [json setValue:customer.gender forKey:@"gender"];
    
    [json setValue:customer.loginMethod forKey:@"login_method"];
    
    [json setValue:customer.password forKey:@"password"];
    
    [json setValue:customer.plainPassword forKey:@"plain_password"];
    
    [json setValue:customer.createdAt forKey:@"created_at"];
    
//    NSMutableDictionary * addresses = [NSMutableDictionary new];
    
//    for ( RIAddress* addr in customer.addresses) {
//        [addresses setObject:[RIAddress toJSON:addr] forKey:addr.uid];
//    }
    
//    [json setValue:addresses forKey:@"address_list"];
    
    return json;
}

#pragma mark - Parser
+ (RICustomer *)parseCustomerWithJson:(NSDictionary *)json {
    return [RICustomer parseToDataModelWithObjects:@[ json ]];
}

+ (RICustomer *)parseCustomerWithJson:(NSDictionary *)json plainPassword:(NSString*)plainPassword loginMethod:(NSString*)loginMethod {
    RICustomer *customer = [RICustomer parseToDataModelWithObjects:@[ json ]];
    
    if(VALID_NOTEMPTY(loginMethod, NSString)) {
        customer.loginMethod = loginMethod;
    }
    
    if([@"normal" isEqualToString:loginMethod] && VALID_NOTEMPTY(plainPassword, NSString)) {
        customer.plainPassword = plainPassword;
    }
    
    [RICustomer saveCustomer:customer andContext:YES];
    
    return customer;
}

#pragma mark - JSONVerboseModel
+(instancetype)parseToDataModelWithObjects:(NSArray *)objects {
    NSDictionary *dict = objects[0];
    
    RICustomer *customer = (RICustomer *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RICustomer class])];
    
    if (VALID_NOTEMPTY([dict objectForKey:@"id"], NSString)) {
        customer.customerId = [dict objectForKey:@"id"];
    }
    if (VALID_NOTEMPTY([dict objectForKey:@"email"], NSString)) {
        customer.email = [dict objectForKey:@"email"];
        
        NSArray *customers = [[RIDataBaseWrapper sharedInstance] getEntryOfType:NSStringFromClass([RICustomer class]) withPropertyName:@"email" andPropertyValue:[dict objectForKey:@"email"]];
        
        if (customers.count > 0) {
            customer = [customers lastObject];
        } else {
            [RICustomer saveCustomer:customer andContext:YES];
        }
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"first_name"], NSString)) {
        customer.firstName = [dict objectForKey:@"first_name"];
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"last_name"], NSString)) {
        customer.lastName = [dict objectForKey:@"last_name"];
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"birthday"], NSString)) {
        customer.birthday = [dict objectForKey:@"birthday"];
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"gender"], NSString)) {
        customer.gender = [dict objectForKey:@"gender"];
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"password"], NSString)) {
        customer.password = [dict objectForKey:@"password"];
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"created_at"], NSString)) {
        customer.createdAt = [dict objectForKey:@"created_at"];
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"wishlist_products"], NSArray)) {
        NSMutableArray *wishlist = [NSMutableArray new];
        for (NSDictionary *dictionary in [dict objectForKey:@"wishlist_products"]) {
            if (VALID_NOTEMPTY([dictionary objectForKey:@"sku"], NSString)) {
                [wishlist addObject:[dictionary objectForKey:@"sku"]];
            }
        }
        customer.wishlistProducts = [wishlist copy];
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"national_id"], NSString)) {
        customer.nationalID = [dict objectForKey:@"national_id"];
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"card_number"], NSString)) {
        customer.bankCartNumber = [dict objectForKey:@"card_number"];
    }
    
    //#############################################################################################################
    
    NSDictionary *_addressListDict = [dict objectForKey:@"address_list"];
    if (_addressListDict) {
        customer.addressList = [[AddressList alloc] init];
        [customer.addressList mergeFromDictionary:_addressListDict useKeyMapping:YES error:nil];
    }
    
    NSString *_phone = [dict objectForKey:@"phone"];
    if(_phone) {
        customer.phone = _phone;
    }
    
    return customer;
}

@end
