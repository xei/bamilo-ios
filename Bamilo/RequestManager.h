//
//  RequestManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataServiceProtocol.h"

typedef NS_OPTIONS(NSUInteger, RequestExecutionType) {
    REQUEST_EXEC_IN_BACKGROUND = 0,
    REQUEST_EXEC_IN_FOREGROUND = 1
};

typedef void(^RequestCompletion)(RIApiResponse response, id data, NSArray* errorMessages);

@interface RequestManager : NSObject

-(instancetype) initWithBaseUrl:(NSString *)baseUrl;

-(void) asyncGET:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;
-(void) asyncPOST:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;
-(void) asyncPUT:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;
-(void) asyncDELETE:(id<DataServiceProtocol>)target path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type completion:(RequestCompletion)completion;

@end
