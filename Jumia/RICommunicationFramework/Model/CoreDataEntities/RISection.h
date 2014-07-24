//
//  RISection.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIApi;

@interface RISection : NSManagedObject

@property (nonatomic, retain) NSString * md5;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) RIApi *api;

/**
 *  Method to parse an RISection given a JSON object
 *
 *  @return the parsed RISection
 */
+ (RISection *)parseSection:(NSDictionary *)section;

/**
 *  Save in the core data a given RISection
 *
 *  @param the RISection to save
 */
+ (void)saveSection:(RISection *)section;

@end
