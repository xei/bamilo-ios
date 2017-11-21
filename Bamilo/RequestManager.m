//
//  RequestManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "RequestManager.h"
#import "Bamilo-Swift.h"

@implementation RequestManager {
@private
    int _pendingRequestsNumber;
}

-(instancetype)init {
    NSAssert(false, @"Call initWithBaseUrl instead");
    return nil;
}

-(instancetype)initWithBaseUrl:(NSString *)baseUrl {
    if(self = [super init]) {
        _baseUrl = baseUrl;
    }
    return self;
}

-(void) asyncGET:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion {
    [self asyncRequest:HttpVerbGET path:path params:params type:type target:target completion:completion];
}

-(void) asyncPOST:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion {
    [self asyncRequest:HttpVerbPOST path:path params:params type:type target:target completion:completion];
}

-(void) asyncPUT:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion {
    [self asyncRequest:HttpVerbPUT path:path params:params type:type target:target completion:completion];
}

-(void) asyncDELETE:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion {
    [self asyncRequest:HttpVerbDELETE path:path params:params type:type target:target completion:completion];
}

-(void)asyncRequest:(HttpVerb)method path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type target:(id<DataServiceProtocol>)target completion:(RequestCompletion)completion {
    
    switch (type) {
        case RequestExecutionTypeContainer:
        case RequestExecutionTypeForeground:
            
            [LoadingManager showLoadingOn:target];
        break;
            
        default: break;
    }
    
    NSURL *requestUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", self.baseUrl, path]];
    
    [[RICommunicationWrapper sharedInstance]
     sendRequestWithUrl:requestUrl
     parameters:params
     httpMethod:method
     cacheType:RIURLCacheNoCache
     cacheTime:RIURLCacheDefaultTime
     userAgentInjection:[RIApi getCountryUserAgentInjection] successBlock:^(RIApiResponse apiResponse, NSDictionary *jsonObject) {
         
         NSError *error;
         ResponseData *data = [ResponseData new];
         [data mergeFromDictionary:jsonObject useKeyMapping:NO error:&error];
         
         if (data.success) {
            completion(apiResponse, data, nil);
         } else {
            completion(apiResponse, nil, nil);
         }
         
         switch (type) {
             case RequestExecutionTypeContainer:
             case RequestExecutionTypeForeground:
                 
                 [LoadingManager hideLoading];
            break;
                 
            default: break;
         }
         
     } failureBlock:^(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject) {
        if(errorJsonObject && errorJsonObject.allKeys.count) {
            completion(apiResponse, nil, [RIError getPerfectErrorMessages:errorJsonObject]);
        } else if(errorObject) {
            NSArray *errorArray = [NSArray arrayWithObject:[errorObject localizedDescription]];
            completion(apiResponse, nil, errorArray);
        } else {
            completion(apiResponse, nil, nil);
        }
        
        [LoadingManager hideLoading];
    }];
}

@end
