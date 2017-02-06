//
//  RequestManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^RequestCompletion)(RIApiResponse response, id data, NSArray* errorMessages);

@interface RequestManager : NSObject

+(void) asyncGET:(NSString *)path params:(NSDictionary *)params completion:(RequestCompletion)completion;
+(void) asyncPOST:(NSString *)path params:(NSDictionary *)params completion:(RequestCompletion)completion;
+(void) asyncPUT:(NSString *)path params:(NSDictionary *)params completion:(RequestCompletion)completion;
+(void) asyncDELETE:(NSString *)path params:(NSDictionary *)params completion:(RequestCompletion)completion;

@end
