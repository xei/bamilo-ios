//
//  RIVariation.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RIImage;

@interface RIVariation : NSObject

@property (nonatomic, retain) NSString *brand;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *price;
@property (nonatomic, retain) NSNumber *specialPrice;
@property (nonatomic, retain) NSString *sku;
@property (nonatomic, retain) RIImage *image;

/**
 *  Method to parse an RIVariation given a JSON object
 *
 *  @return the parsed RIVariation
 */
+ (RIVariation *)parseVariation:(NSDictionary *)variation;


@end
