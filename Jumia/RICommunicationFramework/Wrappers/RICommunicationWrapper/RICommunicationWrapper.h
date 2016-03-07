//
//  RICommunicationWrapper.h
//  Comunication Project
//
//  Created by Miguel Chaves on 10/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RIURLCacheWrapper.h"
#import "RIError.h"
#import "RIOperation.h"

#define kPHPSESSIDCookie @"PHPSESSIDCookieProperties"

/**
 *
 * Interface of RICommunicationWrapper
 */
@interface RICommunicationWrapper : NSObject

+(RICommunicationWrapper *)sharedInstance;

/**
 *  Start a WebService Request with the given parameters
 *
 * This method uses the default timeout and retry configurations defined in RIConfiguration:
 *      Default timeout is kURLConnectionTimeOut
 *      Default retry state is kShouldRetry and number of retries is kNumberOfRetries
 *
 *  @param endpoint of the web service
 *  @param parameters of the request (can have a "json" key with a JSON object to add to the request)
 *  @param http method: if true the method is POST, otherwise is GET
 *  @param the cache type
 *  @param the cache time
 *  @param the completion block that returns the api request finishes with success and the correspondent json object
 *  @param the completion block that returns the api request fails and the correspondent error object
 *
 *  @return operationID
 *
 */
- (NSString*)sendRequestWithUrl:(NSURL *)url
                     parameters:(NSDictionary *)parameters
                     httpMethod:(HttpResponse)method
                      cacheType:(RIURLCacheType)cacheType
                      cacheTime:(RIURLCacheTime)cacheTime
             userAgentInjection:(NSString*)userAgentInjection
                   successBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* jsonObject))successBlock
                   failureBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObjectt))failureBlock;

/**
 *  Start a WebService Request with the given parameters
 *
 * This method uses the default timeout and retry configurations defined in RIConfiguration:
 *      Default retry state is kShouldRetry and number of retries is kNumberOfRetries
 *
 *  @param endpoint of the web service
 *  @param parameters of the request (can have a "json" key with a JSON object to add to the request)
 *  @param http method: if true the method is POST, otherwise is GET
 *  @param the given timeout to the request
 *  @param the cache type
 *  @param the cache time
 *  @param the completion block that returns the api request finishes with success and the correspondent json object
 *  @param the completion block that returns the api request fails and the correspondent error object
 *
 *  @return operationID
 *
 */
- (NSString*)sendRequestWithUrl:(NSURL *)url
                     parameters:(NSDictionary *)parameters
                     httpMethod:(HttpResponse)method
                        timeOut:(NSInteger)timeOut
                      cacheType:(RIURLCacheType)cacheType
                      cacheTime:(RIURLCacheTime)cacheTime
             userAgentInjection:(NSString*)userAgentInjection
                   successBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* jsonObject))successBlock
                   failureBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject))failureBlock;

/**
 *  Start a WebService Request with the given parameters
 *
 * This method uses the default timeout and retry configurations defined in RIConfiguration:
 *      Default timeout is kURLConnectionTimeOut
 *
 *  @param endpoint of the web service
 *  @param parameters of the request (can have a "json" key with a JSON object to add to the request)
 *  @param http method: if true the method is POST, otherwise is GET
 *  @param true if retry is enable, false otherwise
 *  @param the number of times we have to retry the request if it fails
 *  @param the cache type
 *  @param the cache time
 *  @param the completion block that returns the api request finishes with success and the correspondent json object
 *  @param the completion block that returns the api request fails and the correspondent error object
 *
 *  @return operationID
 *
 */
- (NSString*)sendRequestWithUrl:(NSURL *)url
                     parameters:(NSDictionary *)parameters
                     httpMethod:(HttpResponse)method
                    shouldRetry:(BOOL)shouldRetry
                numberOfRetries:(NSInteger)numberOfRetries
                      cacheType:(RIURLCacheType)cacheType
                      cacheTime:(RIURLCacheTime)cacheTime
             userAgentInjection:(NSString*)userAgentInjection
                   successBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* jsonObject))successBlock
                   failureBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject))failureBlock;

/**
 *  Start a WebService Request with the given parameters
 *
 *  @param endpoint of the web service
 *  @param parameters of the request (can have a "json" key with a JSON object to add to the request)
 *  @param http method: if true the method is POST, otherwise is GET
 *  @param the given timeout to the request
 *  @param true if retry is enable, false otherwise
 *  @param the number of times we have to retry the request if it fails
 *  @param the cache type
 *  @param the cache time
 *  @param the completion block that returns the api request finishes with success and the correspondent json object
 *  @param the completion block that returns the api request fails and the correspondent error object
 *
 *  @return operationID
 *
 */
- (NSString*)sendRequestWithUrl:(NSURL *)url
                     parameters:(NSDictionary *)parameters
                     httpMethod:(HttpResponse)method
                        timeOut:(NSInteger)timeOut
                    shouldRetry:(BOOL)shouldRetry
                numberOfRetries:(NSInteger)numberOfRetries
                      cacheType:(RIURLCacheType)cacheType
                      cacheTime:(RIURLCacheTime)cacheTime
             userAgentInjection:(NSString*)userAgentInjection
                   successBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* jsonObject))successBlock
                   failureBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject))failureBlock;

/**
 * Method to delete session cookie
 */
+ (void)deleteSessionCookie;

/**
 * Method to set session cookie
 */
+ (BOOL)setSessionCookie;

/**
 *  Cancel the current request
 */
- (void)cancelRequest:(NSString*)requestID;

- (void)operationEnded:(RIOperation*)operation;

@end
