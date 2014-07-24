//
//  RILocalizationWrapper.h
//  Comunication Project
//
//  Created by Pedro Lopes on 18/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RILocalizationWrapper : NSObject

#define RILocalizedString(key, comment) [RILocalizationWrapper localizedString:key]

/**
 * Method to localize a string
 *
 * @param the key of the string to be localized
 * @return A localized version of the string designated by key.
 * If the string is not present in the given language code is returned the string in english
 */
+ (NSString *)localizedString:(NSString *)key;

/**
 * Method to localize a error code
 *
 * @param the error code to be localized
 * @return A localized version of the error code.
 * If value is nil or an empty string, and a localized string is not found in the table, returns key. If key and value are both nil, returns the empty string.
 */
+ (NSString *)localizedErrorCode:(NSString *)errorCode;

@end
