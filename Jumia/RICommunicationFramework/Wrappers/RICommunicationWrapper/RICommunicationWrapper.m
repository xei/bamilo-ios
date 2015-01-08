//
//  RICommunicationWrapper.m
//  Comunication Project
//
//  Created by Miguel Chaves on 10/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "RICommunicationWrapper.h"
#import "RIConfiguration.h"

@interface RICommunicationWrapper()

@property (nonatomic, strong)NSMutableDictionary* operations;

@end

@implementation RICommunicationWrapper

@synthesize operations=_operations;
- (NSMutableDictionary*)operations
{
    if (nil == _operations) {
        _operations = [NSMutableDictionary new];
    }
    return _operations;
}

+(RICommunicationWrapper *)sharedInstance;
{
    static dispatch_once_t pred = 0;
    static RICommunicationWrapper *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[self alloc] init];
        
    });
    return instance;
}


#pragma mark - Requests public methods

- (NSString*)sendRequestWithUrl:(NSURL *)url
                     parameters:(NSDictionary *)parameters
                 httpMethodPost:(BOOL)post
                        timeOut:(NSInteger)timeOut
                    shouldRetry:(BOOL)shouldRetry
                numberOfRetries:(NSInteger)numberOfRetries
                      cacheType:(RIURLCacheType)cacheType
                      cacheTime:(RIURLCacheTime)cacheTime
                   successBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* jsonObject))successBlock
                   failureBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject))failureBlock
{
    RIOperation* operation = [[RIOperation alloc] init];
    NSString* operationID = [NSString stringWithFormat:@"%p",operation];
    [self.operations setObject:operation forKey:operationID];
    
    operation.successBlock = successBlock;
    operation.failureBlock = failureBlock;
    
    [operation setShouldRetry:shouldRetry];
    [operation setTotalRetriesNumber:numberOfRetries];
    
    [self RI_sendRequestForOperation:operation
                                 url:url
                          parameters:parameters
                      httpMethodPost:post
                             timeOut:timeOut
                           cacheType:cacheType
                           cacheTime:cacheTime];
    
    return operationID;
}

- (NSString*)sendRequestWithUrl:(NSURL *)url
                     parameters:(NSDictionary *)parameters
                 httpMethodPost:(BOOL)post
                    shouldRetry:(BOOL)shouldRetry
                numberOfRetries:(NSInteger)numberOfRetries
                      cacheType:(RIURLCacheType)cacheType
                      cacheTime:(RIURLCacheTime)cacheTime
                   successBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* jsonObject))successBlock
                   failureBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject))failureBlock
{
    RIOperation* operation = [[RIOperation alloc] init];
    NSString* operationID = [NSString stringWithFormat:@"%p",operation];
    [self.operations setObject:operation forKey:operationID];
    
    operation.successBlock = successBlock;
    operation.failureBlock = failureBlock;
    
    [operation setShouldRetry:shouldRetry];
    [operation setTotalRetriesNumber:numberOfRetries];
    
    [self RI_sendRequestForOperation:operation
                                 url:url
                          parameters:parameters
                      httpMethodPost:post
                             timeOut:RI_HTTP_REQUEST_TIMEOUT
                           cacheType:cacheType
                           cacheTime:cacheTime];
    
    return operationID;
}

- (NSString*)sendRequestWithUrl:(NSURL *)url
                     parameters:(NSDictionary *)parameters
                 httpMethodPost:(BOOL)post
                        timeOut:(NSInteger)timeOut
                      cacheType:(RIURLCacheType)cacheType
                      cacheTime:(RIURLCacheTime)cacheTime
                   successBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* jsonObject))successBlock
                   failureBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject))failureBlock
{
    RIOperation* operation = [[RIOperation alloc] init];
    NSString* operationID = [NSString stringWithFormat:@"%p",operation];
    [self.operations setObject:operation forKey:operationID];
    
    operation.successBlock = successBlock;
    operation.failureBlock = failureBlock;
    
    [self RI_sendRequestForOperation:operation
                                 url:url
                          parameters:parameters
                      httpMethodPost:post
                             timeOut:timeOut
                           cacheType:cacheType
                           cacheTime:cacheTime];
    
    return operationID;
}

- (NSString*)sendRequestWithUrl:(NSURL *)url
                     parameters:(NSDictionary *)parameters
                 httpMethodPost:(BOOL)post
                      cacheType:(RIURLCacheType)cacheType
                      cacheTime:(RIURLCacheTime)cacheTime
                   successBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* jsonObject))successBlock
                   failureBlock:(void(^)(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject))failureBlock
{
    RIOperation* operation = [[RIOperation alloc] init];
    NSString* operationID = [NSString stringWithFormat:@"%p",operation];
    [self.operations setObject:operation forKey:operationID];
    
    operation.successBlock = successBlock;
    operation.failureBlock = failureBlock;
    
    [self RI_sendRequestForOperation:operation
                                 url:url
                          parameters:parameters
                      httpMethodPost:post
                             timeOut:RI_HTTP_REQUEST_TIMEOUT
                           cacheType:cacheType
                           cacheTime:cacheTime];
    
    return operationID;
}

- (void)RI_sendRequestForOperation:(RIOperation*)operation
                               url:(NSURL *)url
                        parameters:(NSDictionary *)parameters
                    httpMethodPost:(BOOL)post
                           timeOut:(NSInteger)timeOut
                         cacheType:(RIURLCacheType)cacheType
                         cacheTime:(RIURLCacheTime)cacheTime
{
    operation.cacheType = cacheType;
    operation.cacheTime = cacheTime;
    
    operation.request = [self RI_getURLRequestForOperation:operation url:url
                                            httpMethodPost:post
                                            withParameters:parameters];
    
    operation.request.timeoutInterval = timeOut;
    
    if (ISEMPTY(operation.request)) {
        operation.request = [NSMutableURLRequest requestWithURL:url];
    }
    
    NSCachedURLResponse *cacheRequest  = [[RIURLCacheWrapper sharedInstance] getRequestFromLocalCache:operation.request
                                                                                            cacheType:operation.cacheType];
    if(cacheRequest) {
        operation.mutableData = [[cacheRequest data] copy];
        
        NSError *error;
        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:operation.mutableData
                                                                     options:kNilOptions
                                                                       error:&error];
        if(ISEMPTY(error) && NOTEMPTY([responseJSON objectForKey:@"success"]) && [[responseJSON objectForKey:@"success"] boolValue]) {
            
            if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
            {
                operation.failureBlock(RIApiResponseNoInternetConnection, responseJSON, nil);
            }
            else
            {
                operation.successBlock(RIApiResponseSuccess, responseJSON);
            }
        } else {
            // This should not happen. If the request has an error it shouldn't be saved in cache
            if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
            {
                operation.failureBlock(RIApiResponseNoInternetConnection, responseJSON, nil);
            }
            else
            {
                operation.failureBlock(RIApiResponseAPIError, responseJSON, nil);
            }
        }
        [self operationEnded:operation];
    } else {
        [operation startRequest];
    }
}

- (NSMutableURLRequest *)RI_getURLRequestForOperation:(RIOperation*)operation
                                                  url:(NSURL *)url
                                       httpMethodPost:(BOOL)post
                                       withParameters:(NSDictionary *)parameters
{
    operation.request = [NSMutableURLRequest requestWithURL:url];
    
    if (post) {
        [operation.request setHTTPMethod:RI_HTTP_METHOD_POST];
    } else {
        [operation.request setHTTPMethod:RI_HTTP_METHOD_GET];
    }
    
    if(operation.cacheType == RIURLCacheNoCache) {
        operation.request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    } else  {
        operation.request.cachePolicy = NSURLRequestUseProtocolCachePolicy;
        
        NSString *maxAge = [NSString stringWithFormat:@"max-age=%d", [RIURLCacheWrapper getCacheTime:operation.cacheTime]];
        [operation.request setValue:maxAge forHTTPHeaderField:@"Cache-Control"];
    }
    
    if (NOTEMPTY(parameters)) {
        if (!post) {
            NSString *urlWithParameters = [NSString stringWithFormat:@"%@?%@", [url absoluteString], [self getParametersString:parameters]];
            [operation.request setURL:[NSURL URLWithString:urlWithParameters]];
        } else {
            NSError *error = nil;
            
            switch (operation.parameterEncoding) {
                case RICWFormURLParameterEncoding:
                    [operation.request setValue:RI_HTTP_CONTENT_TYPE_HEADER_FORM_DATA_VALUE forHTTPHeaderField:RI_HTTP_CONTENT_TYPE_HEADER_NAME];
                    [operation.request setHTTPBody:[[self getParametersString:parameters] dataUsingEncoding:NSUTF8StringEncoding]];
                    break;
                case RICWJSONParameterEncoding:
                    [operation.request setValue:RI_HTTP_CONTENT_TYPE_HEADER_JSON_VALUE forHTTPHeaderField:RI_HTTP_CONTENT_TYPE_HEADER_NAME];
                    [operation.request setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error]];
                    break;
                case RICWPropertyListParameterEncoding:
                    [operation.request setValue:RI_HTTP_CONTENT_TYPE_HEADER_PLIST_VALUE forHTTPHeaderField:RI_HTTP_CONTENT_TYPE_HEADER_NAME];
                    [operation.request setHTTPBody:[NSPropertyListSerialization dataWithPropertyList:parameters format:NSPropertyListXMLFormat_v1_0 options:0 error:&error]];
                    break;
            }
            
            if (error) {
                NSLog(@"%@ %@: %@", [self class], NSStringFromSelector(_cmd), error);
            }
        }
    }
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", RI_USERNAME, RI_PASSWORD];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithOptions:0]];
    [operation.request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    if(RI_MOBAPI_HEADERS_ENABLED) {
        [operation.request setValue:RI_MOBAPI_VERSION_HEADER_VERSION_VALUE forHTTPHeaderField:RI_MOBAPI_VERSION_HEADER_VERSION_NAME];
        [operation.request setValue:RI_MOBAPI_VERSION_HEADER_LANG_VALUE forHTTPHeaderField:RI_MOBAPI_VERSION_HEADER_LANG_NAME];
        [operation.request setValue:RI_MOBAPI_VERSION_HEADER_TOKEN_VALUE forHTTPHeaderField:RI_MOBAPI_VERSION_HEADER_TOKEN_NAME];
    }
    
    // Set the PHPSESSID cookie in user defaults so we can re-use it when installing the application.
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        if([[cookie name] rangeOfString:@"PHPSESSID"].location != NSNotFound)
        {
            [[NSUserDefaults standardUserDefaults] setObject:[cookie properties] forKey:kPHPSESSIDCookie];
            [[NSUserDefaults standardUserDefaults] synchronize];
            break;
        }
    }
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        [operation.request addValue:RI_HTTP_USER_AGENT_HEADER_IPAD_VALUE forHTTPHeaderField:RI_HTTP_USER_AGENT_HEADER_NAME];
    }
    else
    {    [operation.request addValue:RI_HTTP_USER_AGENT_HEADER_IPHONE_VALUE forHTTPHeaderField:RI_HTTP_USER_AGENT_HEADER_NAME];
    }
    
    return operation.request;
}


- (NSString *) getParametersString:(NSDictionary *)parameters {
    NSMutableArray *encodedParameters = [NSMutableArray array];
    
    NSArray *parametersKeys=[parameters allKeys];
    if(NOTEMPTY(parametersKeys)) {
        for(NSString *parameterKey in parametersKeys) {
            if(NOTEMPTY([parameters objectForKey:parameterKey])) {
                NSString *parameterValue = [parameters objectForKey:parameterKey];
                [encodedParameters addObject:[NSString stringWithFormat:@"%@=%@", parameterKey, [self encodeParameter:parameterValue]]];
            }
        }
    }
    
    return [encodedParameters componentsJoinedByString:@"&"];
}


- (NSString *) encodeParameter:(NSString *) string{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

+ (void)deleteSessionCookie
{
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies])
    {
        if([[cookie name] rangeOfString:@"PHPSESSID"].location != NSNotFound)
        {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            break;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPHPSESSIDCookie];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)setSessionCookie
{
    BOOL sessionCookieSetted = NO;
    NSDictionary *cookieProperties = [[NSUserDefaults standardUserDefaults] objectForKey:kPHPSESSIDCookie];
    if(VALID_NOTEMPTY(cookieProperties, NSDictionary))
    {
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        sessionCookieSetted = YES;
    }
    return sessionCookieSetted;
}

- (void)cancelRequest:(NSString*)requestID;
{
    RIOperation* operationToCancel = [self.operations objectForKey:requestID];
    [operationToCancel cancelRequest];
}

#pragma mark - RIOperationDelegate

- (void)operationEnded:(RIOperation*)operation;
{
    [self.operations removeObjectForKey:[NSString stringWithFormat:@"%p",operation]];
}

@end
