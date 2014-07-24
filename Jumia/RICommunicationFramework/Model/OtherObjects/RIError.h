//
//  RIError.h
//  Comunication Project
//
//  Created by Pedro Lopes on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIError : NSObject

/**
 * Method to get an array with all the error messages
 *
 * @param the json object with errors.
 * @returns the error messages in "validate", or the error codes if there are no error message.
 * Returning nil means that the error should be handled by the view controller with the default error message.
 */
+ (NSArray *)getErrorMessages:(NSDictionary *)errorJsonObject;

/**
 * Method to get a dictionary with errors.
 * This is usally used on dyanmaic forms, where we get errors in the following format: field_name: field_error_message
 *
 * @param the json object with errors.
 * @returns the error messages in "validate", or the error codes if there are no error message.
 */
+ (NSDictionary *)getErrorDictionary:(NSDictionary *)errorJsonObject;

@end
