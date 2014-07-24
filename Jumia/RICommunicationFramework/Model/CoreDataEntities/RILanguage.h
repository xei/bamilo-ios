//
//  RILanguage.h
//  Comunication Project
//
//  Created by Miguel Chaves on 24/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RICountryConfiguration;

@interface RILanguage : NSManagedObject

@property (nonatomic, retain) NSString * langCode;
@property (nonatomic, retain) NSNumber * langDefault;
@property (nonatomic, retain) NSString * langName;
@property (nonatomic, retain) RICountryConfiguration *countryConfig;

/**
 *  Method to parse an RILanguage given a JSON object
 *
 *  @return the parsed RILanguage
 */
+ (RILanguage *)parseRILanguage:(NSDictionary *)json;

/**
 *  Save in the core data a given RILanguage
 *
 *  @param the RILanguage to save
 */
+ (void)saveLanguage:(RILanguage *)language;

@end
