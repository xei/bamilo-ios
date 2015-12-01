//
//  RISuccess.h
//  Jumia
//
//  Created by Claudio Sobrinho on 26/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RISuccess : NSObject

/**
 * Method to get an array with all the success messages
 *
 * @param the json object with success message.
 * @returns the success messages in "message".
 */
+ (NSArray *)getSuccessMessages:(NSDictionary *)successJsonObject;

/**
 * Method to get a dictionary with success.
 * This is usally used on dyanmaic forms
 *
 * @param the json object with success message.
 * @returns the success messages in "message".
 */
+ (NSDictionary *)getSuccessDictionary:(NSDictionary *)successJsonObject;

@end
