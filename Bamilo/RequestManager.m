//
//  RequestManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "RequestManager.h"

@implementation RequestManager

+ (void)asyncGET:(NSString *)path params:(NSDictionary *)params completion:(RequestCompletion)completion {
    [RequestManager asyncRequest:HttpVerbGET path:path params:params completion:completion];
}

+ (void)asyncPOST:(NSString *)path params:(NSDictionary *)params completion:(RequestCompletion)completion {
    [RequestManager asyncRequest:HttpVerbPOST path:path params:params completion:completion];
}

+ (void)asyncPUT:(NSString *)path params:(NSDictionary *)params completion:(RequestCompletion)completion {
    [RequestManager asyncRequest:HttpVerbPUT path:path params:params completion:completion];
}

+ (void)asyncDELETE:(NSString *)path params:(NSDictionary *)params completion:(RequestCompletion)completion {
    [RequestManager asyncRequest:HttpVerbDELETE path:path params:params completion:completion];
}

#pragma mark - Private Methods
+ (void)asyncRequest:(HttpVerb)method path:(NSString *)path params:(NSDictionary *)params completion:(RequestCompletion)completion {
    [[RICommunicationWrapper sharedInstance]
     sendRequestWithUrl:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION, path]]
     parameters:params
     httpMethod:method
     cacheType:RIURLCacheNoCache
     cacheTime:RIURLCacheDefaultTime
     userAgentInjection:[RIApi getCountryUserAgentInjection] successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
        NSDictionary* metadata = [jsonObject objectForKey:@"metadata"];
        if (metadata || [jsonObject objectForKey:@"success"]) {
            completion(apiResponse, metadata, nil);
        } else {
            completion(apiResponse, nil, nil);
        }
    } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
        if(errorJsonObject && errorJsonObject.allKeys.count) {
            completion(apiResponse, nil, [RIError getErrorMessages:errorJsonObject]);
        } else if(errorObject) {
            NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
            completion(apiResponse, nil, errorArray);
        } else {
            completion(apiResponse, nil, nil);
        }
    }];
}

@end
