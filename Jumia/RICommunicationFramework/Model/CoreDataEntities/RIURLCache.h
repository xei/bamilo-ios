//
//  RIURLCache.h
//  Comunication Project
//
//  Created by Pedro Lopes on 21/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface RIURLCache : NSManagedObject

@property (nonatomic, retain) NSData * responseData;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * duration;

/**
 * Method to save a response in core data
 *
 * @param the response to cache
 * @param the url of the reponse that we want to cache
 * @param the time that the cache has to be saved
 */
+ (void)cacheResponse:(NSCachedURLResponse *)cachedResponse forUrl:(NSString *)url
         withDuration:(NSInteger)duration;

/**
 * Get a response from the core data
 *
 * @param the url of the reponse that we want
 * @return a RIURLCache object that is cached
 */
+ (RIURLCache *)loadCachedResponseForUrl:(NSString *)url;

/**
 * Get all responses saved in core data
 *
 * @return a NSArray with all the RIURLCache objects that are cached
 */
+ (NSArray *)loadAllCachedResponses;

/**
 * Method to delete a cached response from the core data
 *
 * @param the url of the reponse that we want to delete
 */
+ (void)deleteCachedResponseForUrl:(NSString *)url;

@end
