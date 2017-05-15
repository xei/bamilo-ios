//
//  RequestManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataServiceProtocol.h"
#import "Data.h"

typedef NS_OPTIONS(NSUInteger, RequestExecutionType) {
    REQUEST_EXEC_IN_BACKGROUND = 0,
    REQUEST_EXEC_IN_FOREGROUND = 1,
    //A request that contains another one. This is to signal to not hide activity indicator when finished
    REQUEST_EXEC_AS_CONTAINER = 2
};

typedef void(^RequestCompletion)(int statusCode, Data *data, NSArray *errorMessages);

@interface RequestManager : NSObject

@property (copy, nonatomic, readonly) NSString *baseUrl;

-(instancetype) initWithBaseUrl:(NSString *)baseUrl;

-(void) asyncGET:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;
-(void) asyncPOST:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;
-(void) asyncPUT:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;
-(void) asyncDELETE:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;
-(void)asyncRequest:(HttpVerb)method path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type target:(id<DataServiceProtocol>)target completion:(RequestCompletion)completion;

@end
