//
//  RICity.h
//  Jumia
//
//  Created by Pedro Lopes on 02/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RICity : NSObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * group;

+ (NSString *)getCitiesForUrl:(NSString*)url
                       region:(NSString*)regionId
                 successBlock:(void (^)(NSArray *regions))successBlock
              andFailureBlock:(void (^)(NSArray *error))failureBlock;

@end
