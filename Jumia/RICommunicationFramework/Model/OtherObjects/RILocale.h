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

+ (NSString *)getLocalesForUrl:(NSString*)url
                    parameters:(NSDictionary*)parameters
                  successBlock:(void (^)(NSArray *locales))successBlock
               andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

@end
