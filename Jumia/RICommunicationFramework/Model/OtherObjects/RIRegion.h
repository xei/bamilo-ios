//
//  RIRegion.h
//  Jumia
//
//  Created by Pedro Lopes on 02/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RIRegion : NSObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * fkCountry;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sort;
@property (nonatomic, retain) NSString * createdAt;
@property (nonatomic, retain) NSString * updatedAt;

+ (NSString *)getRegionsForUrl:(NSString*)url
                 successBlock:(void (^)(NSArray *regions))successBlock
              andFailureBlock:(void (^)(RIApiResponse apiResponse, NSArray *error))failureBlock;

@end
