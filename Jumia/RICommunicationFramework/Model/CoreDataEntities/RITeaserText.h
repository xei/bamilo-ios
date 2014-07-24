//
//  RITeaserText.h
//  Comunication Project
//
//  Created by Miguel Chaves on 22/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RITeaser;

@interface RITeaserText : NSManagedObject

@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) RITeaser *teaser;

/**
 *  Method to parse an RITeaserText given a JSON object
 *
 *  @return the parsed RITeaserText
 */
+ (RITeaserText *)parseTeaserText:(NSDictionary *)json;

/**
 *  Save in the core data a given RITeaserText
 *
 *  @param the RITeaserText to save
 */
+ (void)saveTeaserText:(RITeaserText *)text;

@end
