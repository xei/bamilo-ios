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
#import "RINewsletterCategory.h"
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
@synthesize costumerRequestID;

+ (NSString*)autoLogin:(void (^)(BOOL success, RICustomer *customer, NSString *loginMethod))returnBlock
{
    NSString *operationID = nil;
    
    NSArray *customers = [[RIDataBaseWrapper sharedInstance] allEntriesOfType:NSStringFromClass([RICustomer class])];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (customers.count > 0) {
        RICustomer *customerObject = [customers objectAtIndex:0];
        
        [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RICustomer class])];
        
        if([@"facebook" isEqualToString:customerObject.loginMethod])
        {
            NSDictionary *parameters = @{ @"email": customerObject.email,
                                          @"first_name": customerObject.firstName,
                                          @"last_name": customerObject.lastName,
                                          @"birthday":customerObject.birthday,
                                          @"gender": customerObject.gender };
            
            [RICustomer loginCustomerByFacebookWithParameters:parameters
                                                 successBlock:^(RICustomer* customer, NSString* nextStep) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         returnBlock(YES, customer, customerObject.loginMethod);
                                                     });
                                                 } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorObject) {
                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                         returnBlock(NO, nil, customerObject.loginMethod);
                                                     });
                                                 }];
        }
        else if([@"normal" isEqualToString:customerObject.loginMethod])
        {
            [parameters setValue:customerObject.email forKey:@"Alice_Module_Customer_Model_LoginForm[email]"];
            [parameters setValue:customerObject.plainPassword forKey:@"Alice_Module_Customer_Model_LoginForm[password]"];
            
            return [RIForm getForm:@"login" successBlock:^(id form)
                    {
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
                                
        return customer.idCustomer;
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
                                       successBlock:(void (^)(RICustomer* customer, NSString* nextStep))successBlock
                                    andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorObject))failureBlock;
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_FACEBOOK_LOGIN_CUSTOMER]]
                                                            parameters:parameters
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  NSDictionary* userObject = [metadata objectForKey:@"user"];
                                                                  if (VALID_NOTEMPTY(userObject, NSDictionary))
                                                                  {
                                                                      NSString* nextStep = @"";
                                                                      NSDictionary* nextStepJSON = [metadata objectForKey:@"native_checkout"];
                                                                      if (VALID_NOTEMPTY(nextStepJSON, NSDictionary)) {
                                                                          NSString* nextStepValue = [nextStepJSON objectForKey:@"next_step"];
                                                                          if (VALID_NOTEMPTY(nextStepValue, NSString)) {
                                                                              nextStep = nextStepValue;
                                                                          }
                                                                      }
                                                                      
                                                                      successBlock([self parseCustomerWithJson:userObject plainPassword:nil loginMethod:@"facebook"], nextStep);
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
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                    userAgentInjection:[RIApi getCountryUserAgentInjection]
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (metadata && [metadata isKindOfClass:[NSDictionary class]]) {
                                                                  successBlock([self parseCustomerWithJson:metadata]);
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

+ (NSString*)logoutCustomerWithSuccessBlock:(void (^)())successBlock
                            andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorObject))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_LOGOUT_CUSTOMER]]
                                                            parameters:nil
                                                        httpMethodPost:YES
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
                                                        httpMethodPost:YES
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
    
    if ([json objectForKey:@"id_customer"]) {
        customer.idCustomer = [json objectForKey:@"id_customer"];
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
    
    if ([json objectForKey:@"address_collection"]) {
        NSDictionary *addressesObject = [json objectForKey:@"address_collection"];
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
    
    [RICustomer saveCustomer:customer];
    
    return customer;
}

+ (RICustomer *)parseCustomerWithJson:(NSDictionary *)json plainPassword:(NSString*)plainPassword loginMethod:(NSString*)loginMethod
{
    RICustomer *customer = (RICustomer *)[[RIDataBaseWrapper sharedInstance] temporaryManagedObjectOfType:NSStringFromClass([RICustomer class])];
    
    if ([json objectForKey:@"id_customer"]) {
        customer.idCustomer = [json objectForKey:@"id_customer"];
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
    
    if(VALID_NOTEMPTY(loginMethod, NSString))
    {
        customer.loginMethod = loginMethod;
    }
    
    customer.plainPassword = nil;
    if([@"normal" isEqualToString:loginMethod] && VALID_NOTEMPTY(plainPassword, NSString))
    {
        customer.plainPassword = plainPassword;
    }
    
    if ([json objectForKey:@"created_at"]) {
        customer.createdAt = [json objectForKey:@"created_at"];
    }
    
    if ([json objectForKey:@"address_collection"]) {
        NSDictionary *addressesObject = [json objectForKey:@"address_collection"];
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
    
    [self updateCustomerNewsletterWithJson:json];
    
    [RICustomer saveCustomer:customer];
    
    return customer;
}

+ (void)saveCustomer:(RICustomer *)customer
{
    for (RIAddress *address in customer.addresses) {
        [RIAddress saveAddress:address];
    }
    
    [[RIDataBaseWrapper sharedInstance] insertManagedObject:customer];
    [[RIDataBaseWrapper sharedInstance] saveContext];
}

#pragma mark - Save newsletter preferences

+ (void)updateCustomerNewsletterWithJson:(NSDictionary *)json
{
    if ([json objectForKey:@"subscribed_categories"])
    {
        [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RINewsletterCategory class])];
        [[RIDataBaseWrapper sharedInstance] saveContext];
        
        NSArray *newsletterArray = [json objectForKey:@"subscribed_categories"];
        
        for (NSDictionary *dic in newsletterArray)
        {
            RINewsletterCategory *newsletter = [RINewsletterCategory parseNewsletterCategory:dic];
            [RINewsletterCategory saveNewsLetterCategory:newsletter];
        }
    }
    else if ([json objectForKey:@"newsletter_subscription"])
    {
        [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RINewsletterCategory class])];
        [[RIDataBaseWrapper sharedInstance] saveContext];
        
        NSArray *newsletterArray = [json objectForKey:@"newsletter_subscription"];
        
        for (NSDictionary *dic in newsletterArray)
        {
            RINewsletterCategory *newsletter = [RINewsletterCategory parseNewsletterCategory:dic];
            [RINewsletterCategory saveNewsLetterCategory:newsletter];
        }
    }
}

@end
