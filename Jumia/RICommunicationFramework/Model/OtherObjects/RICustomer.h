//
//  RICustomer.h
//  Comunication Project
//
//  Created by Miguel Chaves on 17/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RICustomer : NSObject

@property (strong, nonatomic) NSString *idCustomer;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *birthday;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *createdAt;
@property (strong, nonatomic) NSArray *addresses;

/**
 * Method to login user via facebook
 *
 * @param the needed parameters to use with facebook login
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)loginCustomerByFacebookWithParameters:(NSDictionary *)parameters
                                       successBlock:(void (^)(id customer))successBlock
                                    andFailureBlock:(void (^)(NSArray *errorObject))failureBlock;

/**
 * Method to login user
 *
 * @param the user parameters
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)loginCustomerWithParameters:(NSDictionary *)parameters
                             successBlock:(void (^)(RICustomer *customer))successBlock
                          andFailureBlock:(void (^)(NSArray *errorObject))failureBlock;

/**
 * Method to get current customer information
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getCustomerWithSuccessBlock:(void (^)(id customer))successBlock
                          andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;


/**
 * Method to logout the current user
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)logoutCustomerWithSuccessBlock:(void (^)())successBlock
                             andFailureBlock:(void (^)(NSArray *errorObject))failureBlock;

/** Method to cancel the request
 *
 * @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

@end
