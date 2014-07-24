//
//  RICustomer.m
//  Comunication Project
//
//  Created by Miguel Chaves on 17/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICustomer.h"

@interface RICustomer ()

@property (strong, nonatomic) NSString* costumerRequestID;

@end

@implementation RICustomer

#pragma mark - Login Customer

+ (NSString*)loginCustomerWithSuccessBlock:(void (^)(id customer))successBlock
                           andFailureBlock:(void (^)(NSArray *errorObject))failureBlock
{
    NSDictionary *dic = @{@"Alice_Module_Customer_Model_LoginForm[email]": @"sofias@jumia.com",
                          @"Alice_Module_Customer_Model_LoginForm[password]": @"123456"};
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_LOGIN_CUSTOMER]]
                                                            parameters:dic
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
                                                                      successBlock([self parseCustomerWithJson:userObject]);
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

#pragma mark - Facebook Login
+ (NSString*)loginCustomerByFacebookWithParameters:(NSDictionary *)parameters
                                      successBlock:(void (^)(id customer))successBlock
                                   andFailureBlock:(void (^)(NSArray *errorObject))failureBlock
{
    NSDictionary *dic = @{@"Alice_Module_Customer_Model_LoginForm[email]": @"sofias@jumia.com",
                          @"Alice_Module_Customer_Model_LoginForm[password]": @"1234567"};
    
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_LOGIN_CUSTOMER]]
                                                            parameters:dic
                                                        httpMethodPost:YES
                                                             cacheType:RIURLCacheNoCache
                                                             cacheTime:RIURLCacheNoTime
                                                          successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
                                                              NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
                                                              if (metadata && [metadata isKindOfClass:[NSDictionary class]]) {
                                                                  NSDictionary* userObject = [metadata objectForKey:@"user"];
                                                                  if (userObject && [userObject isKindOfClass:[NSDictionary class]]) {
                                                                      successBlock([self parseCustomerWithJson:userObject]);
                                                                  }
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

+ (NSString*)getCustomerWithSuccessBlock:(void (^)(id customer))successBlock
                         andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock
{
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_GET_CUSTOMER]]
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
    return [[RICommunicationWrapper sharedInstance] sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", RI_BASE_URL, RI_API_VERSION, RI_API_LOGOUT_CUSTOMER]]
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

#pragma mark - Cancel requests

+ (void)cancelRequest:(NSString *)operationID
{
    if(VALID_NOTEMPTY(operationID, NSString))
        [[RICommunicationWrapper sharedInstance] cancelRequest:operationID];
}

#pragma mark - Parser

+ (RICustomer *)parseCustomerWithJson:(NSDictionary *)json
{
    RICustomer *customer = [[RICustomer alloc] init];
    
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
        if(VALID_NOTEMPTY(addressesObject, addressesObject)) {
            customer.addresses = [addressesObject allKeys];
        }
    }
    
    return customer;
}

@end
