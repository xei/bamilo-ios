//
//  CartEntity.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartEntity.h"
#import "RICountryConfiguration.h"
#import "RICartItem.h"
#import "RIPaymentInformation.h"
#import "RIAddress.h"
#import "RISellerDelivery.h"
#import "RIProduct.h"

@implementation CartEntity

#pragma mark - JSONVerboseModel
+ (instancetype)parseToDataModelWithObjects:(NSArray *)objects {
    NSDictionary *dict = objects[0];
    RICountryConfiguration *country = objects[1];
    
    CartEntity *cartEntity = [[CartEntity alloc] init];
    
    BOOL showUnreducedPrice = NO;
    long int cartUnreducedValue = 0;
    long int onlyProductDiscount = 0;
    if ([dict objectForKey:@"products"]) {
        NSArray *cartItemObjects = [dict objectForKey:@"products"];
        if (VALID_NOTEMPTY(cartItemObjects, NSArray)) {
            NSMutableArray *cartItems = [[NSMutableArray alloc] init];
            for(NSDictionary *cartItemObject in cartItemObjects) {
                RICartItem *cartItem = [RICartItem parseCartItem:cartItemObject country:country];
                [cartItems addObject:cartItem];
                cartUnreducedValue += ([cartItem.price longValue] * [cartItem.quantity integerValue]);
                if (cartItem.specialPrice) {
                    onlyProductDiscount += (([cartItem.price longValue] - [cartItem.specialPrice longValue]) * [cartItem.quantity integerValue]);
                }
                if(!showUnreducedPrice && VALID_NOTEMPTY(cartItem.specialPrice , NSNumber) && 0.0f < [cartItem.specialPrice longValue] && [cartItem.price longValue] != [cartItem.specialPrice longValue]) {
                    showUnreducedPrice = YES;
                }
            }
            
            cartEntity.cartItems = [cartItems copy];
            
            if(showUnreducedPrice) {
                cartEntity.cartUnreducedValue = [NSNumber numberWithLong:cartUnreducedValue];
                cartEntity.cartUnreducedValueFormatted = [RICountryConfiguration formatPrice:cartEntity.cartUnreducedValue country:country];
            }
        }
    }
    
    cartEntity.onlyProductsDiscount = [NSNumber numberWithLong:onlyProductDiscount];;
    cartEntity.onlyProductsDiscountFormated = [RICountryConfiguration formatPrice:cartEntity.onlyProductsDiscount country:country];
    
    
    if([dict objectForKey:@"sub_total_undiscounted"]) {
        cartEntity.cartUnreducedValue = [dict objectForKey:@"sub_total_undiscounted"];
        cartEntity.cartUnreducedValueFormatted = [RICountryConfiguration formatPrice:cartEntity.cartUnreducedValue country:country];
    }
    
    if([dict objectForKey:@"sub_total"]){
        if(![[dict objectForKey:@"sub_total"] isKindOfClass:[NSNull class]]){
            cartEntity.subTotal = [dict objectForKey:@"sub_total"];
            cartEntity.subTotalFormatted = [RICountryConfiguration formatPrice:cartEntity.subTotal country:country];
        }
    }
    
    if ([dict objectForKey:@"total_products"]) {
        if (![[dict objectForKey:@"total_products"] isKindOfClass:[NSNull class]]) {
            cartEntity.cartCount = [dict objectForKey:@"total_products"];
        }
    }
    
    if ([dict objectForKey:@"total"]) {
        if (![[dict objectForKey:@"total"] isKindOfClass:[NSNull class]]) {
            cartEntity.cartValue = [dict objectForKey:@"total"];
            cartEntity.cartValueFormatted = [RICountryConfiguration formatPrice:cartEntity.cartValue country:country];
        }
    }
    
    
    if ([dict objectForKey:@"total_converted"]) {
        if (![[dict objectForKey:@"total_converted"] isKindOfClass:[NSNull class]]) {
            cartEntity.cartValueEuroConverted = [dict objectForKey:@"total_converted"];
        }
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"delivery"], NSDictionary)) {
        NSDictionary *deliveryDic = [dict objectForKey:@"delivery"];
        if (VALID_NOTEMPTY([deliveryDic objectForKey:@"amount"], NSNumber)) {
            cartEntity.shippingValue = [deliveryDic objectForKey:@"amount"];
            cartEntity.shippingValueFormatted = [RICountryConfiguration formatPrice:cartEntity.shippingValue country:country];
        }
        if (VALID_NOTEMPTY([deliveryDic objectForKey:@"amount_converted"], NSNumber)) {
            cartEntity.shippingValueEuroConverted = [dict objectForKey:@"amount_converted"];
        }
        if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_amount"], NSNumber)) {
            cartEntity.deliveryDiscountAmount = [dict objectForKey:@"discount_amount"];
        }
        if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_amount_converted"], NSNumber)) {
            cartEntity.deliveryDiscountAmountConverted = [dict objectForKey:@"discount_amount_converted"];
        }
        if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_cart_rule_discount"], NSNumber)) {
            cartEntity.deliveryDiscountCartRuleDiscount = [dict objectForKey:@"discount_cart_rule_discount"];
        }
        if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_cart_rule_discount_converted"], NSNumber)) {
            cartEntity.deliveryDiscountCartRuleDiscountConverted = [dict objectForKey:@"discount_cart_rule_discount_converted"];
        }
        if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_coupon_money_value"], NSNumber)) {
            cartEntity.deliveryDiscountCouponMoneyValue = [dict objectForKey:@"discount_coupon_money_value"];
        }
        if (VALID_NOTEMPTY([deliveryDic objectForKey:@"discount_coupon_money_value_converted"], NSNumber)) {
            cartEntity.deliveryDiscountCouponMoneyValueConverted = [dict objectForKey:@"discount_coupon_money_value_converted"];
        }
    }
    
    if (cartEntity.cartValue && cartEntity.cartUnreducedValue) {
        cartEntity.discountValue = [NSNumber numberWithInt: cartEntity.cartUnreducedValue.intValue - cartEntity.cartValue.intValue + cartEntity.shippingValue.intValue];
        cartEntity.discountValueFormated = [RICountryConfiguration formatPrice:cartEntity.discountValue country:country];
    }
    
    if ([dict objectForKey:@"extra_costs"]) {
        if (![[dict objectForKey:@"extra_costs"] isKindOfClass:[NSNull class]]) {
            cartEntity.extraCosts = [dict objectForKey:@"extra_costs"];
            cartEntity.extraCostsFormatted = [RICountryConfiguration formatPrice:cartEntity.extraCosts country:country];
        }
    }
    
    if ([dict objectForKey:@"extra_costs_converted"]) {
        if (![[dict objectForKey:@"extra_costs_converted"] isKindOfClass:[NSNull class]]) {
            cartEntity.extraCostsEuroConverted = [dict objectForKey:@"extra_costs_converted"];
        }
    }
    
    if ([dict objectForKey:@"vat"]) {
        if (VALID_NOTEMPTY([dict objectForKey:@"vat"], NSDictionary)) {
            NSDictionary *vatDict = [dict objectForKey:@"vat"];
            if (VALID_NOTEMPTY([vatDict objectForKey:@"label"], NSString)) {
                cartEntity.vatLabel = [vatDict objectForKey:@"label"];
            }
            if (VALID_NOTEMPTY([vatDict objectForKey:@"label_configuration"], NSNumber)) {
                cartEntity.vatLabelEnabled = [vatDict objectForKey:@"label_configuration"];
            }
            if (VALID_NOTEMPTY([vatDict objectForKey:@"value"], NSNumber)) {
                cartEntity.vatValue = [vatDict objectForKey:@"value"];
                cartEntity.vatValueFormatted = [RICountryConfiguration formatPrice:cartEntity.vatValue country:country];
            }
            if (VALID_NOTEMPTY([vatDict objectForKey:@"value_converted"], NSNumber)) {
                cartEntity.vatValueEuroConverted = [vatDict objectForKey:@"value_converted"];
            }
        }
    }
    
    if ([dict objectForKey:@"sub_total"]) {
        if (![[dict objectForKey:@"sub_total"] isKindOfClass:[NSNull class]]) {
            cartEntity.sumCosts = [dict objectForKey:@"sub_total"];
        }
    }
    
    if ([dict objectForKey:@"sub_total_converted"]) {
        if (![[dict objectForKey:@"sub_total_converted"] isKindOfClass:[NSNull class]]) {
            cartEntity.sumCostsEuroConverted = [dict objectForKey:@"sub_total_converted"];
        }
    }
    
    if ([dict objectForKey:@"sum_costs_value"]) {
        if (![[dict objectForKey:@"sum_costs_value"] isKindOfClass:[NSNull class]]) {
            cartEntity.sumCostsValue = [dict objectForKey:@"sum_costs_value"];
        }
    }
    
    if ([dict objectForKey:@"sum_costs_value_converted"]) {
        if (![[dict objectForKey:@"sum_costs_value_converted"] isKindOfClass:[NSNull class]]) {
            cartEntity.sumCostsValueEuroConverted = [dict objectForKey:@"sum_costs_value_converted"];
        }
    }
    
    if ([dict objectForKey:@"price_rules"]) {
        if (![[dict objectForKey:@"price_rules"] isKindOfClass:[NSNull class]]) {
            NSArray *priceRulesObject = [dict objectForKey:@"price_rules"];
            if(VALID_NOTEMPTY(priceRulesObject, NSArray)) {
                NSMutableDictionary *priceRules = [[NSMutableDictionary alloc] init];
                for(NSDictionary *priceRulesDictionary in priceRulesObject) {
                    if(VALID_NOTEMPTY(priceRulesDictionary, NSDictionary)) {
                        if ([priceRulesDictionary objectForKey:@"label"] && ![[priceRulesDictionary objectForKey:@"label"] isKindOfClass:[NSNull class]]) {
                            if ([priceRulesDictionary objectForKey:@"value"] && ![[priceRulesDictionary objectForKey:@"value"] isKindOfClass:[NSNull class]]) {
                                if(VALID_NOTEMPTY([priceRulesDictionary objectForKey:@"value"], NSNumber)) {
                                    //since it's a rule to create a discount, add the minus signal to the string
                                    [priceRules setValue:[RICountryConfiguration formatPrice:[priceRulesDictionary objectForKey:@"value"] country:country] forKey:[priceRulesDictionary objectForKey:@"label"]];
                                } else {
                                    [priceRules setValue:[priceRulesDictionary objectForKey:@"value"] forKey: [priceRulesDictionary objectForKey:@"label"]];
                                }
                            }
                        }
                    }
                }
                cartEntity.priceRules = [priceRules copy];
            }
        }
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"coupon"], NSDictionary)) {
        NSDictionary *couponDic = [dict objectForKey:@"coupon"];
        if (VALID_NOTEMPTY([couponDic objectForKey:@"code"], NSString)) {
            cartEntity.couponCode = [couponDic objectForKey:@"code"];
        }
        if (VALID_NOTEMPTY([couponDic objectForKey:@"value"], NSNumber)) {
            cartEntity.couponMoneyValue = [couponDic objectForKey:@"value"];
            cartEntity.couponMoneyValueFormatted = [RICountryConfiguration formatPrice:cartEntity.couponMoneyValue country:country];
        }
        if (VALID_NOTEMPTY([couponDic objectForKey:@"value_converted"], NSNumber)) {
            cartEntity.couponMoneyValueEuroConverted = [couponDic objectForKey:@"value_converted"];
        }
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"shipping_method"], NSDictionary)) {
        NSDictionary* shipMethodDic = [dict objectForKey:@"shipping_method"];
        if (VALID_NOTEMPTY([shipMethodDic objectForKey:@"method"], NSString)) {
            cartEntity.shippingMethod = [shipMethodDic objectForKey:@"method"];
        }
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"payment_method"], NSDictionary)) {
        NSDictionary* payMethodDic = [dict objectForKey:@"payment_method"];
        if (VALID_NOTEMPTY([payMethodDic objectForKey:@"label"], NSString)) {
            cartEntity.paymentMethod = [payMethodDic objectForKey:@"label"];
        }
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"billing_address"], NSDictionary)) {
        NSDictionary* billingAddressJSON = [dict objectForKey:@"billing_address"];
        RIAddress* billingAddress = [RIAddress parseAddress:billingAddressJSON];
        if (VALID_NOTEMPTY(billingAddress, RIAddress)) {
            cartEntity.billingAddress = billingAddress;
        }
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"shipping_address"], NSDictionary)) {
        NSDictionary* shippingAddressJSON = [dict objectForKey:@"shipping_address"];
        RIAddress* shippingAddress = [RIAddress parseAddress:shippingAddressJSON];
        if (VALID_NOTEMPTY(shippingAddress, RIAddress)) {
            cartEntity.shippingAddress = shippingAddress;
        }
    }
    
    if (VALID_NOTEMPTY([dict objectForKey:@"fulfillment"], NSArray)) {
        NSArray* fulfillment = [dict objectForKey:@"fulfillment"];
        NSMutableArray* sellers = [[NSMutableArray alloc] init];
        
        for (NSDictionary* seller in fulfillment) {
            RISellerDelivery* sellerDelivery = [RISellerDelivery parseSellerDelivery:[seller objectForKey:@"seller_entity"]];
            NSMutableArray* products = [[NSMutableArray alloc] init];
            
            for (NSDictionary* prod in [seller objectForKey:@"products"]) {
                NSString* simpleSku = [prod objectForKey:@"simple_sku"];
                
                for (RICartItem* cartItem in cartEntity.cartItems) {
                    if ([cartItem.simpleSku isEqual:simpleSku]) {
                        [products addObject:cartItem];
                        break;
                    }
                }
            }
            sellerDelivery.products = [products copy];
            [sellers addObject:sellerDelivery];
        }
        
        cartEntity.sellerDelivery = sellers;
    }
    
//#############################################################################
    if (VALID_NOTEMPTY([dict objectForKey:@"shipping_address"], NSDictionary)) {
        NSDictionary* shippingAddressJSON = [dict objectForKey:@"shipping_address"];
        cartEntity.address = [[Address alloc] init];
        [cartEntity.address mergeFromDictionary:shippingAddressJSON useKeyMapping:YES error:nil];
    }
    
    return cartEntity;
}

@end
