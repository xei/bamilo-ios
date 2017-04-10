//
//  DataManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDataManager.h"
#import "RICart.h"
#import "FormItemModel.h"

#define kDataMessages @"DataMessages"
#define kDataPayload @"DataPayload"

@interface DataManager : BaseDataManager

- (void)serialize:(id)data into:(Class)aClass response:(RIApiResponse)response errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion;
-(void) processResponse:(RIApiResponse)response class:(Class)aClass forData:(id)data errorMessages:(NSArray *)errorMessages completion:(DataCompletion)completion;
- (NSError *)getErrorFrom:(RIApiResponse)response errorMessages:(NSArray *)errorMessages;

- (void)getSubCategoriesFilter:(id<DataServiceProtocol>)target ofCategroyUrlKey:(NSString *)urlKey completion:(DataCompletion)completion;

//### AREA EDIT & CREATE ###
- (void)getRegions:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;
- (void)getCities:(id<DataServiceProtocol>)target forRegionId:(NSString *)uid completion:(DataCompletion)completion;
- (void)getVicinity:(id<DataServiceProtocol>)target forCityId:(NSString *)uid completion:(DataCompletion)completion;
- (void)addAddress:(id<DataServiceProtocol>)target params:(NSDictionary *)params completion:(DataCompletion)completion;
- (void)updateAddress:(id<DataServiceProtocol>)target params:(NSDictionary *)params withID:(NSString *)uid completion:(DataCompletion)completion;
- (void)getAddress:(id<DataServiceProtocol>)target byId:(NSString *)uid completion:(DataCompletion)completion;

//### ORDER TRACKING
- (void)getOrders:(id<DataServiceProtocol>)target forPageNumber:(int)page perPageCount:(int)perPageCount completion:(DataCompletion)completion;
- (void)getOrder:(id<DataServiceProtocol>)target forOrderId:(NSString *)orderId  completion:(DataCompletion)completion;

//### CART ###
- (void)getUserCart:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;

@end
