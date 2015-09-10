//
//  RIVariation.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RIImage, RIProduct;

@interface RIVariation : NSManagedObject

@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * sku;
@property (nonatomic, retain) RIImage *image;
@property (nonatomic, retain) RIProduct *product;

/**
 *  Method to parse an RIVariation given a JSON object
 *
 *  @return the parsed RIVariation
 */
+ (RIVariation *)parseVariation:(NSDictionary *)variation;

/**
 *  Method to save an RIVariation in coredata
 *
 *  @param the RIVariation to be saved
 */
+ (void)saveVariation:(RIVariation*)variation andContext:(BOOL)save;


@end
