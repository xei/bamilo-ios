////  AddressDataManager.m
////  Bamilo
////
////  Created by Narbeh Mirzaei on 4/9/17.
////  Copyright © 2017 Rocket Internet. All rights reserved.
////
//
//#import "AddressDataManager.h"
//
//@implementation AddressDataManager
//
//#pragma mark - Overrides
//static AddressDataManager *instance;
//
//+ (instancetype)sharedInstance {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [AddressDataManager new];
//    });
//    
//    return instance;
//}
//
//- (void)getUserAddressList:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
//    [self.requestManager asyncPOST:target path:RI_API_GET_CUSTOMER_ADDRESS_LIST params:nil type:REQUEST_EXEC_IN_FOREGROUND completion:^(int statusCode, Data *data, NSArray *errorMessages) {
//        [self processResponse:statusCode ofClass:[AddressList class] forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
//- (void)setDefaultAddress:(id<DataServiceProtocol>)target address:(Address *)address isBilling:(BOOL)isBilling completion:(DataCompletion)completion {
//    NSDictionary *params = @{ @"id": address.uid, @"type": isBilling ? @"billing" : @"shipping" };
//    
//    [self.requestManager asyncPUT:target path:RI_API_GET_CUSTOMER_SELECT_DEFAULT params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(int statusCode, Data *data, NSArray *errorMessages) {
//        [self processResponse:statusCode ofClass:[AddressList class] forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
//-(void)deleteAddress:(id<DataServiceProtocol>)target address:(Address *)address completion:(DataCompletion)completion {
//    NSDictionary *params = @{ @"id": address.uid };
//    
//    [self.requestManager asyncDELETE:target path:RI_API_DELETE_ADDRESS_REMOVE params:params type:REQUEST_EXEC_AS_CONTAINER completion:^(int statusCode, Data *data, NSArray *errorMessages) {
//        [self processResponse:statusCode ofClass:nil forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
//@end
