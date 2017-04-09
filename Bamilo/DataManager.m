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
#import "RICustomer.h"
#import "OrderList.h"
#import "SearchCategoryFilter.h"

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

- (void)getSubCategoriesFilter:(id<DataServiceProtocol>)target ofCategroyUrlKey:(NSString *)urlKey completion:(DataCompletion)completion {
    NSString *path = [NSString stringWithFormat:RI_API_GET_CATEGORIES_BY_URLKEY, urlKey];
    [self.requestManager asyncGET:target path:path params:nil type:REQUEST_EXEC_IN_BACKGROUND completion:^(int response, id data, NSArray *errorMessages) {
        if (((NSArray *)[data objectForKey:@"data"]).count) {
            //This must be refactored from server side :(
            NSArray *garbageArray = data[@"data"][0][@"children"];
            if (garbageArray.count) {
                [self serialize:garbageArray[0] into:[SearchCategoryFilter class] response:response errorMessages:errorMessages completion:completion];
            } else {
                completion(nil, [self getErrorFrom:response errorMessages:@[STRING_ERROR]]);
            }
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:@[STRING_ERROR]]);
        }
    }];
}

//### AREA_INFORMATION
- (void)getVicinity:(id<DataServiceProtocol>)target forCityId:(NSString *)uid completion:(DataCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"%@city_id/%@", RI_API_GET_CUSTOMER_POSTCODES, uid];
    [self getAreaZone:target type:REQUEST_EXEC_IN_BACKGROUND path:path completion:completion];
}

- (void)getCities:(id<DataServiceProtocol>)target forRegionId:(NSString *)uid completion:(DataCompletion)completion {
    NSString *path = [NSString stringWithFormat:@"%@region/%@", RI_API_GET_CUSTOMER_CITIES, uid];
    [self getAreaZone:target type:REQUEST_EXEC_IN_BACKGROUND path:path completion:completion];
}

- (void)getRegions:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [self getAreaZone:target type:REQUEST_EXEC_IN_BACKGROUND path:RI_API_GET_CUSTOMER_REGIONS completion:completion];
}


- (void)getAddress:(id<DataServiceProtocol>)target byId:(NSString *)uid completion:(DataCompletion)completion {
    [self.requestManager asyncGET:target
                        path:[NSString stringWithFormat:@"%@?id=%@", RI_API_GET_CUSTOMER_ADDDRESS, uid]
                      params:nil
                        type:REQUEST_EXEC_IN_FOREGROUND
                  completion:^(int response, id data, NSArray *errorMessages) {
                      [self serialize:data into:[Address class] response:response errorMessages:errorMessages completion:completion];
                  }];
}

-(void)addAddress:(id<DataServiceProtocol>)target params:(NSDictionary *)params completion:(DataCompletion)completion {
    [self.requestManager asyncPOST:target path:RI_API_POST_CUSTOMER_ADDDRESS_CREATE params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(int response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}

- (void)updateAddress:(id<DataServiceProtocol>)target params:(NSMutableDictionary *)params withID:(NSString *)uid completion:(DataCompletion)completion {
    [self.requestManager asyncPOST:target path:[NSString stringWithFormat:@"%@%@", RI_API_POST_CUSTOMER_ADDDRESS_EDIT, uid] params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(int response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}

//### ORDER ####
- (void)getOrders:(id<DataServiceProtocol>)target forPageNumber:(int)page perPageCount:(int)perPageCount completion:(DataCompletion)completion {
    NSDictionary *params = @{
         @"per_page": @(perPageCount),
         @"page"    : @(page)
    };
    
    [self.requestManager asyncPOST:target path:RI_API_GET_ORDERS params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(int response, id data, NSArray *errorMessages) {
        [self serialize:data into:[OrderList class] response:response errorMessages:errorMessages completion:completion];
    }];
}

- (void)getOrder:(id<DataServiceProtocol>)target forOrderId:(NSString *)orderId  completion:(DataCompletion)completion {
    NSString *path = [NSString stringWithFormat:RI_API_TRACK_ORDER, orderId];
    [self.requestManager asyncPOST:target path:path params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(int response, id data, NSArray *errorMessages) {
        [self serialize:data into:[Order class] response:response errorMessages:errorMessages completion:completion];
    }];
}

//### CART ###
- (void)getUserCart:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
    [self.requestManager asyncPOST:target path:RI_API_GET_CART_DATA params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(int response, id data, NSArray *errorMessages) {
        [self serialize:data into:[RICart class] response:response errorMessages:errorMessages completion:completion];
    }];
}

#pragma mark - Public Methods
- (void)serialize:(id)data into:(Class)aClass response:(RIApiResponse)response errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion {
    [self processResponse:response forData:data errorMessages:errorMessages completion:^(id data, NSError *error) {
        if(error == nil && data) {
            id dataModel;
            
            if([aClass conformsToProtocol:@protocol(JSONVerboseModel)]) {
                [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
                    completion([aClass parseToDataModelWithObjects:@[ data, configuration ]], nil);
                } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                    completion(nil, [self getErrorFrom:apiResponse errorMessages:errorMessages]);
                }];
            } else {
                NSError *error;
                dataModel = [[aClass alloc] init];
                [dataModel mergeFromDictionary:data useKeyMapping:YES error:&error];
                
                if(error == nil) {
                    completion(dataModel, nil);
                } else {
                    completion(nil, error);
                }
            }
        } else {
            completion(nil, error);
        }
    }];
}

-(void) processResponse:(RIApiResponse)response forData:(id)data errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion {
    if(completion) {
        if(response == RIApiResponseSuccess && data) {
            completion(data, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }
}

- (NSError *)getErrorFrom:(RIApiResponse)response errorMessages:(NSArray *)errorMessages {
    return [NSError errorWithDomain:@"com.bamilo.ios" code:response userInfo:(errorMessages ? @{ kErrorMessages: errorMessages } : nil)];
}

#pragma mark - Helpers
//Area Helper function
- (void)getAreaZone:(id<DataServiceProtocol>)target type:(RequestExecutionType)type path:(NSString *)path completion:(DataCompletion)completion {
    [self.requestManager asyncGET:target path:path params:nil type:type completion:^(int response, id data, NSArray *errorMessages) {
        if(response == RIApiResponseSuccess && data) {
            //Please skip this tof for now! @Narbeh
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
            for (NSDictionary *region in  data[@"data"]) {
                dictionary[region[@"label"]] = [NSString stringWithFormat:@"%@", region[@"value"]];
            }
            completion(dictionary, nil);
        } else {
            completion(nil, [self getErrorFrom:response errorMessages:errorMessages]);
        }
    }];
}

@end
