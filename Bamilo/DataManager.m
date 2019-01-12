 //
//  DataManager.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"
#import "RICart.h"
#import "RIForm.h"
#import "RICategory.h"
#import "OrderList.h"

@implementation DataManager

static DataManager *instance;

- (instancetype)init {
    if (self = [super init]) {
        self.requestManager = [[RequestManager alloc] initWithBaseUrl:[NSString stringWithFormat:@"%@%@", [RIApi getCountryUrlInUse], RI_API_VERSION]];
    }
    
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [DataManager new];
    });
    
    return instance;
}

#pragma mark - Public Methods
- (void) processResponse:(RIApiResponse)response ofClass:(Class)aClass forData:(ResponseData *)data errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion {
    if(completion) {
        if(response == RIApiResponseSuccess && data) {
            NSMutableDictionary *payload = [NSMutableDictionary dictionary];
            
            DataMessageList *dataMessages = data.messages;
            if(dataMessages) {
                [payload setObject:dataMessages forKey:kDataMessages];
            }

            if([aClass conformsToProtocol:@protocol(JSONVerboseModel)]) {
                [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                    [payload setObject:[aClass parseToDataModelWithObjects:@[ ((ResponseData *)data).metadata, configuration ]] forKey:kDataContent];
                    [self handlePayload:payload completion:completion];
                } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                    completion(nil, [self getErrorFrom:apiResponse errorMessages:errorMessages]);
                }];
            } else {
                id metadata = data.metadata;
                if(metadata && aClass) {
                    NSError *error;
                    id dataModel = [[aClass alloc] init];
                    [dataModel mergeFromDictionary:data.metadata useKeyMapping:YES error:&error];
                    
                    if(error == nil) {
                        [payload setObject:dataModel forKey:kDataContent];
                    }
                }
                
                [self handlePayload:payload completion:completion];
            }
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }
}

- (NSError *)getErrorFrom:(RIApiResponse)response errorMessages:(NSArray *)errorMessages {
    return [NSError errorWithDomain:@"com.bamilo.app.ios" code:response userInfo:(errorMessages ? @{ kErrorMessages: errorMessages } : nil)];
}

-(void) handlePayload:(NSMutableDictionary *)payload completion:(DataCompletion)completion {
    if(payload.allKeys.count > 1) {
        completion(payload, nil);
    } else if([payload objectForKey:kDataContent]) {
        completion([payload objectForKey:kDataContent], nil);
    } else {
        completion([payload objectForKey:kDataMessages], nil);
    }
}

@end
