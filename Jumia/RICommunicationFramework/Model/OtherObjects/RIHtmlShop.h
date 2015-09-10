//
//  RIHtmlShop.h
//  Jumia
//
//  Created by Telmo Pinto on 16/07/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIHtmlShop : NSObject

@property (nonatomic, strong) NSString* html;
@property (nonatomic, strong) NSArray* featuredBoxesArray;

+ (NSString*)getHtmlShopForUrlString:(NSString*)urlString
                        successBlock:(void (^)(RIHtmlShop *htmlShop))sucessBlock
                        failureBlock:(void (^)(RIApiResponse apiResponse, NSArray *errorMessages))failureBlock;

+ (RIHtmlShop*)parseHtmlShop:(NSDictionary*)json
                     country:(RICountryConfiguration*)country;

@end
