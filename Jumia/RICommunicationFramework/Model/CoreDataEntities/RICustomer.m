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

+ (NSString*)autoLogin:(void (^)())returnBlock
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
                                                 successBlock:^(id customer) {
                                                     
                                                     [[RITrackingWrapper sharedInstance] trackEvent:((RICustomer *)customer).idCustomer
                                                                                              value:nil
                                                                                             action:@"AutoLoginSuccess"
                                                                                           category:@"Account"
                                                                                               data:nil];
                                                     
                                                     returnBlock();
                                                 } andFailureBlock:^(NSArray *errorObject) {
                                                     
                                                     [[RITrackingWrapper sharedInstance] trackEvent:nil
                                                                                              value:nil
                                                                                             action:@"AutoLoginFailed"
                                                                                           category:@"Account"
                                                                                               data:nil];
                                                     
                                                     returnBlock();
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
                             [[RITrackingWrapper sharedInstance] trackEvent:[RICustomer getCustomerId]
                                                                      value:nil
                                                                     action:@"AutoLoginSuccess"
                                                                   category:@"Account"
                                                                       data:nil];
                             
                             returnBlock();
                         } andFailureBlock:^(id errorObject)
                         {
                             [[RITrackingWrapper sharedInstance] trackEvent:nil
                                                                      value:nil
                                                                     action:@"AutoLoginFailed"
                                                                   category:@"Account"
                                                                       data:nil];
                             
                             returnBlock();
                         }];
                    } failureBlock:^(NSArray *errorMessage)
                    {
                        returnBlock();
                    }];
        }
        else
        {
            returnBlock();
        }
    }
    else
    {
        returnBlock();
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

#pragma mark - Facebook Login

+ (NSString*)loginCustomerByFacebookWithParameters:(NSDictionary *)parameters
                                      successBlock:(void (^)(id customer))successBlock
                                   andFailureBlock:(void (^)(NSArray *errorObject))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_FACEBOOK_LOGIN_CUSTOMER]]
                                                            parameters:parameters
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (VALID_NOTEMPTY(metadata, NSDictionary))
                                                              {
                                                                  NSDictionary* userObject = [metadata objectForKey:@"user"];
                                                                  if (VALID_NOTEMPTY(userObject, NSDictionary))
                                                                  {
                                                                      successBlock([self parseCustomerWithJson:userObject plainPassword:nil loginMethod:@"facebook"]);
                                                                  } else
                                                                  {
                                                                      failureBlock(nil);
                                                                  }
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                              
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

#pragma mark - Get customer

+ (NSString *)getCustomerWithSuccessBlock:(void (^)(id customer))successBlock
                          andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
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
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (metadata && [metadata isKindOfClass:[NSDictionary class]]) {
                                                                  successBlock([self parseCustomerWithJson:metadata]);
                                                              }
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              } else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

+ (NSString*)logoutCustomerWithSuccessBlock:(void (^)())successBlock
                            andFailureBlock:(void (^)(NSArray *errorObject))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_LOGOUT_CUSTOMER]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              [[RIDataBaseWrapper sharedInstance] deleteAllEntriesOfType:NSStringFromClass([RICustomer class])];
                                                              [[RIDataBaseWrapper sharedInstance] saveContext];
                                                              successBlock();
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              }
                                                              else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
                                                              }
                                                          }];
}

+ (NSString *)requestPasswordReset:(void (^)())successBlock
                   andFailureBlock:(void (^)(NSArray *errorObject))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, RI_API_LOGOUT_CUSTOMER]]
                                                            parameters:nil
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheDefaultTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              successBlock();
                                                          } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
                                                              if(NOTEMPTY(errorJsonObject))
                                                              {
                                                                  failureBlock([RIError getErrorMessages:errorJsonObject]);
                                                              }
                                                              else if(NOTEMPTY(errorObject))
                                                              {
                                                                  NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
                                                                  failureBlock(errorArray);
                                                              } else
                                                              {
                                                                  failureBlock(nil);
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
}

@end
