//
//  RIOperation.h
//  Comunication Project
//
//  Created by Telmo Pinto on 18/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    RICWFormURLParameterEncoding,
    RICWJSONParameterEncoding,
    RICWPropertyListParameterEncoding,
} RICommunicationWrapperParameterEncoding;

@interface RIOperation : NSObject <NSURLConnectionDataDelegate>

// Retry request related variables
@property (assign, nonatomic) BOOL shouldRetry;
@property (assign, nonatomic) NSInteger numberOfRetry;
@property (assign, nonatomic) NSInteger totalRetriesNumber;

@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *mutableData;
@property (strong, nonatomic) NSMutableURLRequest *request;
@property (assign, nonatomic) RICommunicationWrapperParameterEncoding parameterEncoding;
@property (assign, nonatomic) RIURLCacheType cacheType;
@property (assign, nonatomic) RIURLCacheTime cacheTime;
@property (strong, nonatomic) void (^successBlock)(RIApiResponse apiResponse, NSDictionary* jsonObject);
@property (strong, nonatomic) void (^failureBlock)(RIApiResponse apiResponse, NSDictionary* errorJsonObject, NSError *errorObject);

- (void)startRequest;

- (void)cancelRequest;

@end
