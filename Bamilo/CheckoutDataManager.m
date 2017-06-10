////
////  CheckoutDataManager.m
////  Bamilo
////
////  Created by Narbeh Mirzaei on 4/9/17.
////  Copyright © 2017 Rocket Internet. All rights reserved.
////
//
//#import "CheckoutDataManager.h"
//#import "Models.pch"
//
//@implementation CheckoutDataManager
//
//#pragma mark - Overrides
//static CheckoutDataManager *instance;
//
//+ (instancetype)sharedInstance {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [CheckoutDataManager new];
//    });
//    
//    return instance;
//}
//
//-(void)getMultistepAddressList:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
//    [self.requestManager asyncGET:target path:RI_API_MULTISTEP_GET_ADDRESSES params:nil type:RequestExecutionTypeForeground completion:^(NSInteger statusCode, ResponseData *data, NSArray *errorMessages) {
//        [self processResponse:statusCode ofClass:[RICart class] forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
//-(void)setMultistepAddress:(id<DataServiceProtocol>)target forShipping:(NSString *)shippingAddressId billing:(NSString *)billingAddressId completion:(DataCompletion)completion {
//    NSDictionary *params = @{ @"addresses[shipping_id]": shippingAddressId, @"addresses[billing_id]": billingAddressId };
//    
//    [self.requestManager asyncPOST:target path:RI_API_MULTISTEP_SUBMIT_ADDRESSES params:params type:RequestExecutionTypeForeground completion:^(NSInteger statusCode, ResponseData *data, NSArray *errorMessages) {
//        [self processResponse:statusCode ofClass:[MultistepEntity class] forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
//-(void)getMultistepConfirmation:(id<DataServiceProtocol>)target type:(RequestExecutionType)type completion:(DataCompletion)completion {
//    [self.requestManager asyncGET:target path:RI_API_MULTISTEP_GET_FINISH params:nil type:type completion:^(NSInteger statusCode, ResponseData *data, NSArray *errorMessages) {
//        [self processResponse:statusCode ofClass:[RICart class] forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
//-(void) getMultistepShipping:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
//    [self.requestManager asyncGET:target path:RI_API_MULTISTEP_GET_SHIPPING params:nil type:RequestExecutionTypeForeground completion:^(NSInteger statusCode, ResponseData *data, NSArray *errorMessages) {
//        [self processResponse:statusCode ofClass:[RICart class] forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
///*-(void) setMultistepShipping:(id<DataServiceProtocol>)target forShippingMethod:(NSString*)shippingMethod pickupStation:(NSString*)pickupStation region:(NSString*)region completion:(DataCompletion)completion {
// NSDictionary *params = @{
// @"shipping_method[shipping_method]": shippingMethod,
// @"shipping_method[pickup_station]": pickupStation,
// @"shipping_method[pickup_station_customer_address_region]": region
// };
// 
// [RequestManager asyncPOST:target path:RI_API_MULTISTEP_SUBMIT_SHIPPING params:params type:REQUEST_EXEC_IN_FOREGROUND completion:^(RIApiResponse response, id data, NSArray *errorMessages) {
// [self serialize:data into:[RICart class] response:response errorMessages:errorMessages completion:completion];
// }];
// }*/
//
//- (void) getMultistepPayment:(id<DataServiceProtocol>)target completion:(DataCompletion)completion {
//    [self.requestManager asyncGET:target path:RI_API_MULTISTEP_GET_PAYMENT params:nil type:RequestExecutionTypeContainer completion:^(NSInteger statusCode, ResponseData *data, NSArray *errorMessages) {
//        [self processResponse:statusCode ofClass:[RICart class] forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
//-(void)setMultistepPayment:(id<DataServiceProtocol>)target params:(NSDictionary *)params completion:(DataCompletion)completion {
//    [self.requestManager asyncPOST:target path:RI_API_MULTISTEP_SUBMIT_PAYMENT params:params type:RequestExecutionTypeContainer completion:^(NSInteger statusCode, ResponseData *data, NSArray *errorMessages) {
//        [self processResponse:statusCode ofClass:[MultistepEntity class] forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
//-(void) setMultistepConfirmation:(id<DataServiceProtocol>)target cart:(RICart *)cart completion:(DataCompletion)completion {
//    NSDictionary *params = @{ @"app": @"ios", @"customer_device": UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() ? @"tablet" : @"mobile" };
//    
//    [self.requestManager asyncPOST:target path:RI_API_MULTISTEP_SUBMIT_FINISH params:params type:RequestExecutionTypeForeground completion:^(NSInteger statusCode, ResponseData *data, NSArray *errorMessages) {
//        if(completion != nil && errorMessages.count == 0) {
//            completion([RICart parseCheckoutFinish:data.metadata forCart:cart], nil);
//        } else {
//            completion(nil, [self getErrorFrom:statusCode errorMessages:errorMessages]);
//        }
//    }];
//}
//
//
//-(void) applyVoucher:(id<DataServiceProtocol>)target voucherCode:(NSString *)voucherCode completion:(DataCompletion)completion {
//    NSDictionary *params = @{ @"couponcode": voucherCode };
//    
//    [self.requestManager asyncPOST:target path:RI_API_ADD_VOUCHER_TO_CART params:params type:RequestExecutionTypeForeground completion:^(NSInteger statusCode, ResponseData *data, NSArray *errorMessages) {
//        [self processResponse:statusCode ofClass:[RICart class] forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
//-(void) removeVoucher:(id<DataServiceProtocol>)target voucherCode:(NSString *)voucherCode completion:(DataCompletion)completion {
//    NSDictionary *params = @{ @"couponcode": voucherCode };
//    
//    [self.requestManager asyncDELETE:target path:RI_API_REMOVE_VOUCHER_FROM_CART params:params type:RequestExecutionTypeForeground completion:^(NSInteger statusCode, ResponseData *data, NSArray *errorMessages) {
//        [self processResponse:statusCode ofClass:[RICart class] forData:data errorMessages:errorMessages completion:completion];
//    }];
//}
//
//@end
