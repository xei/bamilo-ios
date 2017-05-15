//
//  CheckoutDataManager.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 4/9/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"

@interface CheckoutDataManager : DataManager

-(void) getMultistepAddressList:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;
-(void) setMultistepAddress:(id<DataServiceProtocol>)target forShipping:(NSString *)shippingAddressId billing:(NSString*)billingAddressId completion:(DataCompletion)completion;

-(void) getMultistepConfirmation:(id<DataServiceProtocol>)target type:(RequestExecutionType)type completion:(DataCompletion)completion;
-(void) getMultistepShipping:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;
//-(void) setMultistepShipping:(id<DataServiceProtocol>)target forShippingMethod:(NSString*)shippingMethod pickupStation:(NSString*)pickupStation region:(NSString*)region completion:(DataCompletion)completion;
-(void) getMultistepPayment:(id<DataServiceProtocol>)target completion:(DataCompletion)completion;
-(void) setMultistepPayment:(id<DataServiceProtocol>)target params:(NSDictionary *)params completion:(DataCompletion)completion;
-(void) setMultistepConfirmation:(id<DataServiceProtocol>)target cart:(RICart *)cart completion:(DataCompletion)completion;

- (void)applyVoucher:(id<DataServiceProtocol>)target voucherCode:(NSString *)voucherCode completion:(DataCompletion)completion;
- (void)removeVoucher:(id<DataServiceProtocol>)target voucherCode:(NSString *)voucherCode completion:(DataCompletion)completion;

@end
