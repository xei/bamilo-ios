//
//  RICountry.h
//  Comunication Project
//
//  Created by Pedro Lopes on 21/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RICountryConfiguration.h"

@interface RICountry : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) NSString *flag;
@property (strong, nonatomic) NSDictionary *mapImages;
@property (strong, nonatomic) NSString *countryIso;
@property (assign, nonatomic) BOOL forceHttps;
@property (assign, nonatomic) BOOL isLive;

/**
 * Method to request the countries of the application
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getCountriesWithSuccessBlock:(void (^)(id countries))successBlock
                           andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to load the configuration to a given country
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)loadCountryConfigurationWithSuccessBlock:(void (^)(RICountryConfiguration *configuration))successBlock
                                       andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to request the configuration to a given country
 *
 * @param the block where the success response can be processed
 * @param the block where the failure response can be processed
 * @return a string with the operationID that can be used to cancel the operation
 */
+ (NSString *)getCountryConfigurationWithSuccessBlock:(void (^)(RICountryConfiguration *configuration))successBlock
                                      andFailureBlock:(void (^)(NSArray *errorMessages))failureBlock;

/**
 * Method to cancel the request
 *
 * @param the operationID that was returned by the getCountriesWithSuccessBlock:andFailureBlock method
 */
+ (void)cancelRequest:(NSString *)operationID;

@end
