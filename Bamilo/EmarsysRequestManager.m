//
//  EmarsysRequestManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 3/28/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "EmarsysRequestManager.h"
#import "AFHTTPRequestOperationManager.h"
#import "LoadingManager.h"

#define kApplicationCode @"Application_CODE"
#define kApplicationPassword @"Application_PASSWORD"

@implementation EmarsysRequestManager

#pragma mark - Overrides
-(void)asyncRequest:(HttpVerb)method path:(NSString *)path params:(NSDictionary *)params type:(RequestExecutionType)type target:(id<DataServiceProtocol>)target completion:(RequestCompletion)completion {
    
    switch (type) {
        case REQUEST_EXEC_IN_FOREGROUND:
            [[LoadingManager sharedInstance] showLoading];
            break;
            
        default:
            break;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[self getAuthorizationHeaderValue] forHTTPHeaderField:@"Authorization"];
    
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", self.baseUrl, path];
    
    switch (method) {
        case HttpVerbPOST: {
            [manager POST:requestUrl parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [self handleEmarsysMobileEngageResponse:operation responseObject:responseObject error:nil completion:completion];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [self handleEmarsysMobileEngageResponse:operation responseObject:nil error:error completion:completion];
            }];
        }
        break;
            
        default:
            break;
    }
}

#pragma mark - Private Methods
-(void) handleEmarsysMobileEngageResponse:(AFHTTPRequestOperation *)operation responseObject:(id)responseObject error:(NSError *)error completion:(RequestCompletion)completion {
    int statusCode = (int)[operation.response statusCode];
    
    if(responseObject) {
        switch (statusCode) {
            case SUCCESSFUL:
            case CREATED: {
                completion(statusCode, responseObject, nil);
            }
            break;
                
            case WRONG_INPUT_OR_MISSING_PARAM:
            case UNAUTHORIZED:
            case INTERNAL_SERVER_ERROR: {
                completion(statusCode, nil, [self extractErrors:responseObject]);
            }
            break;
        }
    } else {
        NSLog(@"Emarsys Request Manager Failed: %@", error.localizedDescription);
        completion(statusCode, nil, @[ error.localizedDescription ]);
    }
    
    [[LoadingManager sharedInstance] hideLoading];
}

-(NSArray *)extractErrors:(id)responseObject {
    NSMutableArray *errorMessages = [NSMutableArray new];
    
    NSArray *errors = [responseObject objectForKey:@"errors"];
    for(NSDictionary *error in errors) {
        [errorMessages addObject:[error objectForKey:@"message"]];
    }
    
    return errorMessages;
}

-(NSString *) getAuthorizationHeaderValue {
    NSDictionary *emarsysConfigs = [[[NSBundle mainBundle] objectForInfoDictionaryKey:kConfigs] objectForKey:@"Emarsys"];
    
    NSString *emarsysApplicationCode = [emarsysConfigs objectForKey:kApplicationCode];
    NSString *emarsysApplicationPassword = [emarsysConfigs objectForKey:kApplicationPassword];
    
    return [NSString stringWithFormat:@"Basic %@", [[NSString stringWithFormat:@"%@:%@", emarsysApplicationCode, emarsysApplicationPassword] toEncodeBase64]];
}

@end
