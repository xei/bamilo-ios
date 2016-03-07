//
//  RIImage.h
//  Comunication Project
//
//  Created by Telmo Pinto on 17/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIImage : NSObject

@property (nonatomic, retain) NSString * format;
@property (nonatomic, retain) NSString * height;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * width;

/**
 *  Method to parse an RIImage given a JSON object
 *
 *  @return the parsed RIImage
 */
+ (RIImage *)parseImage:(NSDictionary *)image;

@end

