//
//  RequestManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataServiceProtocol.h"
#import "ResponseData.h"

typedef NS_ENUM(NSUInteger, RequestExecutionType) {
    RequestExecutionTypeBackground = 0,
    RequestExecutionTypeForeground = 1
};

typedef void(^RequestCompletion)(RIApiResponse statusCode, ResponseData *data, NSArray <NSString *>*errorMessages);

@interface RequestManager : NSObject

@property (copy, nonatomic, readonly) NSString *baseUrl;

-(instancetype) initWithBaseUrl:(NSString *)baseUrl;

-(void) asyncGET:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;
-(void) asyncPOST:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;
-(void) asyncPUT:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;
-(void) asyncDELETE:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;
-(void)asyncRequest:(HttpVerb)method path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type target:(id<DataServiceProtocol>)target completion:(RequestCompletion)completion;

@end
