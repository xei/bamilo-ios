//
//  RILocale.h
//  Jumia
//
//  Created by Telmo Pinto on 30/09/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RILocale : NSObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * label;

+ (NSString *)getPostcodesForUrl:(NSString*)url
                            city:(NSString*)cityId
                    successBlock:(void (^)(NSArray *postcodes))successBlock
                 andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

+ (NSString *)getCitiesForUrl:(NSString*)url
                       region:(NSString*)regionId
                 successBlock:(void (^)(NSArray *cities))successBlock
              andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

+ (NSString *)getRegionsForUrl:(NSString*)url
                  successBlock:(void (^)(NSArray *regions))successBlock
               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

@end
