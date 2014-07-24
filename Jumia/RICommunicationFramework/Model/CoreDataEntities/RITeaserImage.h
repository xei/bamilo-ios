//
//  RITeaserImage.h
//  Comunication Project
//
//  Created by Miguel Chaves on 22/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RITeaser;

@interface RITeaserImage : NSManagedObject

@property (nonatomic, retain) NSString * deviceType;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * teaserDescription;
@property (nonatomic, retain) RITeaser *teaser;

/**
 *  Method to parse an RITeaserImage given a JSON object
 *
 *  @return the parsed RITeaserImage
 */
+ (RITeaserImage *)parseTeaserImage:(NSDictionary *)json;

/**
 *  Save in the core data a given RITeaserImage
 *
 *  @param the RITeaserImage to save
 */
+ (void)saveTeaserImage:(RITeaserImage *)image;

@end
