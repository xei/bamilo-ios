//
//  RICustomer.m
//  Jumia
//
//  Created by Miguel Chaves on 14/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICustomer.h"
#import "RIAddress.h"
#import "RIForm.h"
#import "RIField.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface RICustomer ()

@property (strong, nonatomic) NSString* costumerRequestID;

@end

@implementation RICustomer

@dynamic idCustomer;
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
@synthesize costumerRequestID, wishlistProducts;

+ (NSString *)signUpAccount:(NSString *)email
               successBlock:(void (^)(id object))successBlock
            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorObject))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, @"customer/createsignup"]]
                                                            parameters:@{@"email": email}
                                                            httpMethod:HttpResponsePost
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
                                                                          NSDictionary* entities = [RIForm parseEntities:metadata plainPassword:nil];
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

+ (NSString *)checkEmailWithParameters:(NSDictionary *)parameters
                          successBlock:(void (^)(BOOL knownEmail, RICustomer *customerAlreadyLoggedIn))successBlock
                       andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorObject))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, @"customer/emailcheck/"]]
                                                            parameters:parameters
                                                            httpMethod:HttpResponsePost
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

+ (NSString*)autoLogin:(void (^)(BOOL success, NSDictionary *entities, NSString *loginMethod))returnBlock
{
    NSString *operationID = nil;
    
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    
    if (customers.count > 0) {
        __block RICustomer *customerObject = [customers objectAtIndex:0];
        
        
        if([@"facebook" isEqualToString:customerObject.loginMethod])
        {
            NSDictionary *parameters = @{ @"email": customerObject.email,
                                          @"first_name": customerObject.firstName,
                                          @"last_name": customerObject.lastName,
                                          @"birthday":customerObject.birthday,
                                          @"gender": customerObject.gender };
            
            [RICustomer loginCustomerByFacebookWithParameters:parameters
                                                 successBlock:^(NSDictionary *entities, NSString* nextStep) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         returnBlock(YES, entities, customerObject.loginMethod);
                                                     });
                                                 } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorObject) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         returnBlock(NO, nil, customerObject.loginMethod);
                                                     });
                                                 }];
        }
        else if([@"normal" isEqualToString:customerObject.loginMethod])
        {
            return [RIForm getForm:@"login" successBlock:^(RIForm *form)
                    {
                        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                        for (RIField *field in form.fields)
                        {
                            if ([field.key isEqualToString:@"email"]) {
                                [parameters setValue:customerObject.email forKey:field.name];
                            }else
                            if ([field.key isEqualToString:@"password"]) {
                                [parameters setValue:customerObject.plainPassword forKey:field.name];
                            }
                        }
                        [RIForm sendForm:form parameters:parameters
                            successBlock:^(id jsonObject)
                         {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 returnBlock(YES, jsonObject, customerObject.loginMethod);
                             });
                         } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
                         {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 returnBlock(NO, nil, customerObject.loginMethod);
                             });
                         }];
                    } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            returnBlock(NO, nil, customerObject.loginMethod);
                        });
                    }];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                returnBlock(NO, nil, customerObject.loginMethod);
            });
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            returnBlock(NO, nil, nil);
        });
    }
    
    return operationID;
}

+ (NSString *)getCustomerId
{
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    
    if (customers.count > 0)
    {
        RICustomer *customer = (RICustomer *)customers[0];
                                
        return [customer.idCustomer stringValue];
    }
    else
    {
        return @"0";
    }
}

+ (NSString *)getCustomerGender
{
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    
    NSString *gender = nil;
    if (customers.count > 0)
    {
        RICustomer *customer = (RICustomer *)customers[0];
        gender = customer.gender;
    }
    
    return gender;
}

+ (BOOL)wasSignup
{
    BOOL wasSignup = NO;
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    
    if (customers.count > 0)
    {
        RICustomer *customer = (RICustomer *)customers[0];
        wasSignup = [@"signup" isEqualToString:customer.loginMethod];
    }
    
    return wasSignup;
}


#pragma mark - Facebook Login

+ (NSString *)loginCustomerByFacebookWithParameters:(NSDictionary *)parameters
                                       successBlock:(void (^)(NSDictionary *entities, NSString* nextStep))successBlock
                                    andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorObject))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_FACEBOOK_LOGIN_CUSTOMER]]
                                                            parameters:parameters
                                                            httpMethod:HttpResponsePost
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  NSDictionary* userObject = [metadata objectForKey:@"customer_entity"];
                                                                  if (VALID_NOTEMPTY(userObject, NSDictionary))
                                                                  {
                                                                      NSString* nextStep = @"";
                                                                      NSDictionary* nextStepJSON = [metadata objectForKey:@"multistep_entity"];
                                                                      if (VALID_NOTEMPTY(nextStepJSON, NSDictionary)) {
                                                                          NSString* nextStepValue = [nextStepJSON objectForKey:@"next_step"];
                                                                          if (VALID_NOTEMPTY(nextStepValue, NSString)) {
                                                                              nextStep = nextStepValue;
                                                                          }
                                                                      }
                                                                      RICustomer* customer = [self parseCustomerWithJson:userObject plainPassword:nil loginMethod:@"facebook"];
                                                                      NSMutableDictionary* entities = [NSMutableDictionary new];
                                                                      [entities setValue:customer forKey:@"customer"];
                                                                      successBlock(entities, nextStep);
                                                                  } else
                                                                  {
                                                                      failureBlock(apiResponse, nil);
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

#pragma mark - Get customer

+ (NSString *)getCustomerWithSuccessBlock:(void (^)(id customer))successBlock
                          andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock
{
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    
    if (customers.count > 0) {
        successBlock(customers[0]);
        return nil;
    }
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_GET_CUSTOMER]]
                                                            parameters:nil
                                                            httpMethod:HttpResponsePost
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

+ (NSString*)logoutCustomerWithSuccessBlock:(void (^)())successBlock
                            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorObject))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_LOGOUT_CUSTOMER]]
                                                            parameters:nil
                                                            httpMethod:HttpResponsePost
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RICustomer class])];
                                                              [[RIDataBaseWrapper sharedInstance] saveContext];
                                                              successBlock();
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RICustomer class])];
                                                              [[RIDataBaseWrapper sharedInstance] saveContext];
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              }
                                                              else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

+ (NSString *)requestPasswordReset:(void (^)())successBlock
                   andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorObject))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_LOGOUT_CUSTOMER]]
                                                            parameters:nil
                                                            httpMethod:HttpResponsePost
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              successBlock();
                                                          } failureBlock:^(RIApiResponse apiResponse,  NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock(apiResponse, [RIError getErrorMessages:errorJsonObject]);
                                                              }
                                                              else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(apiResponse, errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(apiResponse, nil);
                                                              }
                                                          }];
}

+ (BOOL)checkIfUserIsLogged
{
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    
    if (VALID_NOTEMPTY(customers, NSArray))
    {
        return YES;
    }
    else
    {
        [[[FBSDKLoginManager alloc] init] logOut];
        return NO;
    }
}

+ (BOOL)checkIfUserIsLoggedByFacebook
{
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    
    if (VALID_NOTEMPTY(customers, NSArray))
    {
        RICustomer* customer = [customers firstObject];
        
        if ([customer.loginMethod isEqualToString:@"facebook"]) {
            return YES;
        } else
            return NO;
    }
    else
    {
        return NO;
    }
}

+ (BOOL)checkIfUserIsLoggedAsGuest
{
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    
    if (VALID_NOTEMPTY(customers, NSArray))
    {
        RICustomer* customer = [customers firstObject];
        
        if ([customer.loginMethod isEqualToString:@"guest"]) {
            return YES;
        } else
            return NO;
    }
    else
    {
        return NO;
    }
}


+ (BOOL)checkIfUserHasAddresses
{
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    
    if (VALID_NOTEMPTY(customers, NSArray))
    {
        RICustomer *customer = [customers objectAtIndex:0];
        if(VALID_NOTEMPTY(customer.addresses, NSOrderedSet))
        {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    else
    {
        return NO;
    }
}

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

#pragma mark - Parser
+ (RICustomer *)parseCustomerWithJson:(NSDictionary *)json
{
    RICustomer *customer = (RICustomer *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RICustomer class])];
    
    if ([json objectForKey:@"id"]) {
        customer.idCustomer = [json objectForKey:@"id"];
    }
    
    if ([json objectForKey:@"email"]) {
        customer.email = [json objectForKey:@"email"];
    }
    
    if ([json objectForKey:@"first_name"]) {
        customer.firstName = [json objectForKey:@"first_name"];
    }
    
    if ([json objectForKey:@"last_name"]) {
        customer.lastName = [json objectForKey:@"last_name"];
    }
    
    if ([json objectForKey:@"birthday"]) {
        customer.birthday = [json objectForKey:@"birthday"];
    }
    
    if ([json objectForKey:@"gender"]) {
        customer.gender = [json objectForKey:@"gender"];
    }
    
    if ([json objectForKey:@"password"]) {
        customer.password = [json objectForKey:@"password"];
    }
    
    if ([json objectForKey:@"created_at"]) {
        customer.createdAt = [json objectForKey:@"created_at"];
    }
    
    if ([json objectForKey:@"address_list"]) {
        NSDictionary *addressesObject = [json objectForKey:@"address_list"];
        if(VALID_NOTEMPTY(addressesObject, addressesObject))
        {
            NSArray *addressesObjectKeys = [addressesObject allKeys];
            if(VALID_NOTEMPTY(addressesObjectKeys, NSArray))
            {
                for(NSString *addressObjectKey in addressesObjectKeys)
                {
                    RIAddress *address = [RIAddress parseAddressFromCustomer:addressObjectKey jsonObject:[addressesObject objectForKey:addressObjectKey]];
                    address.customer = customer;
                    [customer addAddressesObject:address];
                }
            }
        }
    }
    
    if (VALID_NOTEMPTY([json objectForKey:@"wishlist_products"], NSArray)) {
        NSMutableArray *wishlist = [NSMutableArray new];
        for (NSDictionary *dictionary in [json objectForKey:@"wishlist_products"]) {
            if (VALID_NOTEMPTY([dictionary objectForKey:@"sku"], NSString)) {
                [wishlist addObject:[dictionary objectForKey:@"sku"]];
            }
        }
        customer.wishlistProducts = [wishlist copy];
    }
    
    [RICustomer saveCustomer:customer andContext:YES];
    
    return customer;
}

+ (RICustomer *)parseCustomerWithJson:(NSDictionary *)json plainPassword:(NSString*)plainPassword loginMethod:(NSString*)loginMethod
{
    RICustomer *customer = [RICustomer parseCustomerWithJson:json];
    
    if(VALID_NOTEMPTY(loginMethod, NSString))
    {
        customer.loginMethod = loginMethod;
    }
    
    customer.plainPassword = nil;
    if([@"normal" isEqualToString:loginMethod] && VALID_NOTEMPTY(plainPassword, NSString))
    {
        customer.plainPassword = plainPassword;
    }
    
    [RICustomer saveCustomer:customer andContext:YES];
    
    return customer;
}

+ (void)saveCustomer:(RICustomer *)customer andContext:(BOOL)save
{
    for (RIAddress *address in customer.addresses) {
        [RIAddress saveAddress:address andContext:NO];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:customer];
    if (save) {
        [[RIDataBaseWrapper sharedInstance] saveContext];
    }
    
}

+ (NSDictionary *)toJSON:(RICustomer*)customer {
    NSMutableDictionary * json = [[NSMutableDictionary alloc] init];
    
    [json setValue:customer.idCustomer forKey:@"id"];
    
    [json setValue:customer.email forKey:@"email"];
    
    [json setValue:customer.firstName forKey:@"first_name"];
    
    [json setValue:customer.lastName forKey:@"last_name"];
    
    [json setValue:customer.birthday forKey:@"birthday"];
    
    [json setValue:customer.gender forKey:@"gender"];
    
    [json setValue:customer.loginMethod forKey:@"login_method"];
    
    [json setValue:customer.password forKey:@"password"];
    
    [json setValue:customer.plainPassword forKey:@"plain_password"];
    
    [json setValue:customer.createdAt forKey:@"created_at"];
    
    NSMutableDictionary * addresses = [NSMutableDictionary new];
    
    for ( RIAddress* addr in customer.addresses) {
        [addresses setObject:[RIAddress toJSON:addr] forKey:addr.uid];
    }
    
    [json setValue:addresses forKey:@"address_list"];
    
    return json;
}

@end
