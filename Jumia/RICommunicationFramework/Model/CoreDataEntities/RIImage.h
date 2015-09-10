//
//  RIImage.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIProduct, RIVariation;

@interface RIImage : NSManagedObject

@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * height;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * width;
@property (nonatomic, retain) RIProduct *product;
@property (nonatomic, retain) RIVariation *variation;

/**
 *  Method to parse an RIImage given a JSON object
 *
 *  @return the parsed RIImage
 */
+ (RIImage *)parseImage:(NSDictionary *)image;

/**
 *  Method to save an RIImage in coredata
 *
 *  @param the RIImage to be saved
 */
+ (void)saveImage:(RIImage*)image andContext:(BOOL)save;

@end

