//
//  RIURLCacheWrapper.h
//  Comunication Project
//
//  Created by Pedro Lopes on 15/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Type of the cache
 */
enum {
    RIURLCacheNoCache = 0,
    RIURLCacheMemCache = 1,
    RIURLCacheDBCache = 2
};
typedef NSUInteger RIURLCacheType;

/**
 * Time of the cache
 */
enum {
    RIURLCacheNoTime = 0,
    RIURLCacheMinTime = 1,
    RIURLCacheDefaultTime = 2,
    RIURLCacheMaxTime =3
};
typedef NSUInteger RIURLCacheTime;

@interface RIURLCacheWrapper : NSObject

+ (instancetype)sharedInstance;

/**
 * Method to add a request to local cache, to prevent unnecessary requests.
 * @param request the request for which we are going to cache the response.
 * @param cachedResponse the response to cache.
 * @param cacheType where we are going to cache the response (e.g. RIURLCacheMemCache for memory or RIURLCacheDBCache for database).
 * @param cacheTime the time that the response is going to stay in cache.
 */
- (void) addRequestToLocalCache:(NSURLRequest *)request
              willCacheResponse:(NSCachedURLResponse *)cachedResponse
                      cacheType:(RIURLCacheType)cacheType
                      cacheTime:(RIURLCacheTime)cacheTime;

/**
 * Method to get cached response.
 * @param request the request for which we want the response.
 * @param cacheType where we are going to fetch the cache (e.g. RIURLCacheMemCache for memory or RIURLCacheDBCache for database).
 * @result an NSCachedURLResponse with the cached response for the given request.
 */
- (NSCachedURLResponse *) getRequestFromLocalCache:(NSURLRequest *)request
                                         cacheType:(RIURLCacheType)cacheType;


/**
 * Method to remove a request from the local cache.
 * @param request the request for which we are going to remove the cached response.
 * @param cacheType where the response is saved (e.g. RIURLCacheMemCache for memory or RIURLCacheDBCache for database).
 */
- (void) removeRequestFromLocalCache:(NSURLRequest *)request
                           cacheType:(RIURLCacheType)cacheType;

/**
 * Method to get the cache duration.
 * @result an integer with the seconds that the response is going to stay in the cache
 */
+ (NSInteger) getCacheTime:(RIURLCacheTime) cacheTime;

@end
