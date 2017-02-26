//
//  CartEntity.h
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "BaseModel.h"
#import "JSONVerboseModel.h"
#import "Address.h"

@class RIPaymentInformation, RIAddress, RIForm, RISellerDelivery, RICustomer;

@interface CartEntity : BaseModel <JSONVerboseModel>

@property (strong, nonatomic) NSArray *cartItems;
@property (strong, nonatomic) NSNumber *cartUnreducedValue;
@property (copy  , nonatomic) NSString *cartUnreducedValueFormatted;
@property (strong, nonatomic) NSNumber *subTotal;
@property (copy  , nonatomic) NSString *subTotalFormatted;
@property (strong, nonatomic) NSNumber *cartCount;
@property (strong, nonatomic) NSNumber *onlyProductsDiscount;
@property (copy  , nonatomic) NSString *onlyProductsDiscountFormated;
@property (strong, nonatomic) NSNumber *cartValue;
@property (copy  , nonatomic) NSString *cartValueFormatted;
@property (copy  , nonatomic) NSString *discountValueFormated;
@property (strong, nonatomic) NSNumber *cartValueEuroConverted;
@property (strong, nonatomic) NSNumber *shippingValue;
@property (copy  , nonatomic) NSString *shippingValueFormatted;
@property (strong, nonatomic) NSNumber *shippingValueEuroConverted;
@property (strong, nonatomic) NSNumber *extraCosts;
@property (copy  , nonatomic) NSString *extraCostsFormatted;
@property (strong, nonatomic) NSNumber *extraCostsEuroConverted;
//VAT
@property (strong, nonatomic) NSNumber *vatValue;
@property (copy  , nonatomic) NSString *vatValueFormatted;
@property (strong, nonatomic) NSNumber *vatValueEuroConverted;
@property (strong, nonatomic) NSNumber *vatLabelEnabled;
@property (copy  , nonatomic) NSString *vatLabel;
//SUM
@property (strong, nonatomic) NSNumber *sumCosts;
@property (strong, nonatomic) NSNumber *sumCostsEuroConverted;
@property (strong, nonatomic) NSNumber *sumCostsValue;
@property (strong, nonatomic) NSNumber *sumCostsValueEuroConverted;
//PRICE RULES
@property (strong, nonatomic) NSDictionary *priceRules;
//COUPON
@property (copy  , nonatomic) NSString *couponCode;
@property (strong, nonatomic) NSNumber *couponMoneyValue;
@property (copy  , nonatomic) NSString *couponMoneyValueFormatted;
@property (strong, nonatomic) NSNumber *couponMoneyValueEuroConverted;
//PAYMENT
@property (nonatomic, strong) RIAddress *shippingAddress;
@property (nonatomic, strong) RIAddress *billingAddress;
@property (nonatomic, copy  ) NSString *paymentMethod;
@property (nonatomic, copy  ) NSString *shippingMethod;

@property (strong, nonatomic) NSArray* sellerDelivery;

/**
 * new params (NOT USED)
 */
@property (strong, nonatomic) NSNumber *deliveryDiscountAmount;
@property (strong, nonatomic) NSNumber *deliveryDiscountAmountConverted;
@property (strong, nonatomic) NSNumber *deliveryDiscountCartRuleDiscount;
@property (strong, nonatomic) NSNumber *deliveryDiscountCartRuleDiscountConverted;
@property (strong, nonatomic) NSNumber *deliveryDiscountCouponMoneyValue;
@property (strong, nonatomic) NSNumber *deliveryDiscountCouponMoneyValueConverted;

//#############################################################################
@property (strong, nonatomic) Address *address;

@end
