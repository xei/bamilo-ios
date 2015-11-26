//
//  RIBanner.h
//  Jumia
//
//  Created by epacheco on 10/04/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIBanner : NSObject

@property (nonatomic, strong) NSString *iPhoneImageUrl;
@property (nonatomic, strong) NSString *iPadImageUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *targetString;

/**
 *  Method to parse an RIBanner given a JSON object
 *
 *  @return the parsed RIBanner
 */
+(RIBanner*)parseBanner:(NSDictionary *)bannerJSON;

@end
