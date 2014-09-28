//
//  RICustomer.h
//  Jumia
//
//  Created by Miguel Chaves on 14/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIAddress;

@interface RICustomer : NSManagedObject

@property (nonatomic, retain) NSString * idCustomer;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * plainPassword;
@property (nonatomic, retain) NSString * createdAt;
@property (nonatomic, retain) NSString * loginMethod;
@property (nonatomic, retain) NSOrderedSet *addresses;

+ (NSString*)autoLogin:(void (^)(BOOL success, RICustomer *customer))returnBlock;

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

/**
 * Method to get the current user id
 *
 * @return a string with the customer id
 */
+ (NSString *)getCustomerId;

/**
 * Method to get the current user gender
 *
 * @return a string with the customer gender
 */
+ (NSString *)getCustomerGender;

/**
 * Method to check id the user dir a signup or not
 *
 * @return YES if the user did a signup
 */
+ (BOOL)wasSignup;

/**
 * Method to parse user json object
 *
 * @return an initialized RICustomer object
 */
+ (RICustomer *)parseCustomerWithJson:(NSDictionary *)json;

+ (RICustomer *)parseCustomerWithJson:(NSDictionary *)json plainPassword:(NSString*)plainPassword loginMethod:(NSString*)loginMethod;

/** Method to cancel the request
 *
 * @param the operationID
 */
+ (void)cancelRequest:(NSString *)operationID;

/**
 * Method to check if the user is stored (logged)
 *
 * @return success case user is stored
 *
 */
+ (BOOL)checkIfUserIsLogged;

/**
 * Method to check if the user has any addresses stored
 *
 * @return success case user has addresses
 *
 */
+ (BOOL)checkIfUserHasAddresses;

/**
 * Method to request a password reset
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)requestPasswordReset:(void (^)())successBlock
                   andFailureBlock:(void (^)(NSArray *errorObject))failureBlock;

+ (void)updateCustomerNewsletterWithJson:(NSDictionary *)json;

@end

@interface RICustomer (CoreDataGeneratedAccessors)

- (void)insertObject:(RIAddress *)value inAddressesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAddressesAtIndex:(NSUInteger)idx;
- (void)insertAddresses:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAddressesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAddressesAtIndex:(NSUInteger)idx withObject:(RIAddress *)value;
- (void)replaceAddressesAtIndexes:(NSIndexSet *)indexes withAddresses:(NSArray *)values;
- (void)addAddressesObject:(RIAddress *)value;
- (void)removeAddressesObject:(RIAddress *)value;
- (void)addAddresses:(NSOrderedSet *)values;
- (void)removeAddresses:(NSOrderedSet *)values;

@end
