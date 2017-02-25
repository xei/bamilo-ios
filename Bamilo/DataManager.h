//
//  DataManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/5/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RequestManager.h"
#import "Address.h"
#import "RICart.h"
#import "FormItemModel.h"

typedef void(^DataCompletion)(id data, NSError *error);

@interface DataManager : NSObject

+ (instancetype)sharedInstance;

//### AREA EDIT & CREATE ###
- (void)getRegions:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;
- (void)getCities:(id<DataServiceProtocol>)target forRegionId:(NSString *)uid completion:(DataCompletion)completion;
- (void)getVicinity:(id<DataServiceProtocol>)target forCityId:(NSString *)uid completion:(DataCompletion)completion;
- (void)updateAddress:(id<DataServiceProtocol>)target params:(NSDictionary *)params withID:(NSString *)uid completion:(DataCompletion)completion;
- (void)getAddress:(id<DataServiceProtocol>)target byId:(NSString *)uid completion:(DataCompletion)completion;

//### Authentications ###
- (void)forgetPassword:(id<DataServiceProtocol>)target withFields:(NSDictionary<NSString *,FormItemModel *> *)fields completion:(DataCompletion)completion;
- (void)loginUser:(id<DataServiceProtocol>)target withUsername:(NSString *)username password:(NSString *)password completion:(DataCompletion)completion;
- (void)signupUser:(id<DataServiceProtocol>)target withFieldsDictionary:(NSDictionary<NSString *,FormItemModel *> *)newUserDictionary completion:(DataCompletion)completion;

//### ADDRESS ###
- (void)getUserAddressList:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;
- (void)setDefaultAddress:(id<DataServiceProtocol>)target address:(Address *)address isBilling:(BOOL)isBilling completion:(DataCompletion)completion;
-(void)deleteAddress:(id<DataServiceProtocol>)target address:(Address *)address completion:(DataCompletion)completion;

//### CART ###
- (void)getUserCart:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;

//### ORDER ###
-(void) getMultistepAddressList:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;
-(void) setMultistepAddress:(id<DataServiceProtocol>)target forShipping:(NSString *)shippingAddressId billing:(NSString*)billingAddressId completion:(DataCompletion)completion;

-(void) getMultistepConfirmation:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;
-(void) getMultistepShipping:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;
//-(void) setMultistepShipping:(id<DataServiceProtocol>)target forShippingMethod:(NSString*)shippingMethod pickupStation:(NSString*)pickupStation region:(NSString*)region completion:(DataCompletion)completion;
-(void) getMultistepPayment:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;
-(void) setMultistepPayment:(id<DataServiceProtocol>)target params:(NSDictionary *)params completion:(DataCompletion)completion;
-(void) setMultistepConfirmation:(id<DataServiceProtocol>)target cart:(RICart *)cart completion:(DataCompletion)completion;

//### COUPON ###
- (void)applyVoucher:(id<DataServiceProtocol>)target voucherCode:(NSString *)voucherCode completion:(DataCompletion)completion;
- (void)removeVoucher:(id<DataServiceProtocol>)target voucherCode:(NSString *)voucherCode completion:(DataCompletion)completion;

@end
