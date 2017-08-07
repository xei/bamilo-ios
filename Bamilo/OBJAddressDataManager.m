////  OBJAddressDataManager.m
////  Bamilo
////
////  Created by Narbeh Mirzaei on 4/9/17.
////  Copyright © 2017 Rocket Internet. All rights reserved.
////
//
//#import "OBJAddressDataManager.h"
//
//@implementation OBJAddressDataManager
//
//#pragma mark - Overrides
//static OBJAddressDataManager *instance;
//
//+ (instancetype)sharedInstance {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [OBJAddressDataManager new];
//    });
//    
//    return instance;
//}
//
//
//-(void)deleteAddress:(id<DataServiceProtocol>)target address:(Address *)address completion:(DataCompletion)completion {
//    NSDictionary *params = @{ @"id": address.uid };
//    
//    [self.requestManager asyncDELETE:target path:RI_API_DELETE_ADDRESS_REMOVE params:params type:RequestExecutionTypeContainer completion:^(RIApiResponse statusCode, ResponseData *data, NSArray<NSString *> *errorMessages) {
//       [self processResponse:statusCode ofClass:nil forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
//@end
