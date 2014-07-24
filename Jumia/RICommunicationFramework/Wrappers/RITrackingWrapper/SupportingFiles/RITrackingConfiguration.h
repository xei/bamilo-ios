//
//  RITrackingProperties.h
//  RITracking
//
//  Created by Martin Biermann on 14/03/14.
//  Copyright (c) 2014 Martin Biermann. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  RITrackingConfiguration has the configuration for RITracking
 */
@interface RITrackingConfiguration : NSObject

/**
 *  Lookup a configuration value, given it's key
 *
 *  @param key The key to search
 *
 *  @return Returns the value for the given key
 */
+ (id)valueForKey:(NSString *)key;

/**
 *  Loads a property list located in the given path to read the contained configuration settings
 *
 *  @param path The path where is the configuration file
 *
 *  @return True in case of sucess, false in case of error
 */
+ (BOOL)loadFromPropertyListAtPath:(NSString *)path;

@end
