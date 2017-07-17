//
//  SuccessPaymentViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 4/24/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SuccessPaymentViewController.h"
#import "EmarsysRecommendationMinimalCarouselWidget.h"
#import "EmarsysPredictProtocol.h"
#import "ThreadManager.h"
#import "NSArray+Extension.h"
#import "EventUtilities.h"
#import "EmarsysPredictManager.h"
#import "Bamilo-Swift.h"


// --- Legacy imports ---
#import "RIProduct.h"
#import "RICartItem.h"
#import "JAUtils.h"

@interface SuccessPaymentViewController () <EmarsysPredictProtocol, PerformanceTrackerProtocol, FeatureBoxCollectionViewWidgetViewDelegate>
@property (nonatomic, weak) IBOutlet EmarsysRecommendationMinimalCarouselWidget *carouselWidget;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *descLabel;
@end

@implementation SuccessPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.carouselWidget hide];
    [self.carouselWidget setBackgroundColor:[Theme color:kColorVeryLightGray]];
    self.carouselWidget.delegate = self;
    [self setupView];
    [self trackPurchase];
    [self.carouselWidget updateTitle:STRING_BAMILO_RECOMMENDATION];
}

- (void)setupView {
    [self.titleLabel applyStyle:[Theme font:kFontVariationRegular size:20.0f] color:[Theme color:kColorGreen]];
    [self.descLabel applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[UIColor blackColor]];
    self.titleLabel.text = STRING_THANK_YOU_ORDER_TITLE;
    self.descLabel.text = STRING_ORDER_SUCCESS;
    [self.carouselWidget hide];
}

- (void)trackPurchase {
    //EVENT: PURCHASE
    [TrackerManager postEventWithSelector:[EventSelectors purchaseSelector] attributes:[EventAttributes purchaseWithCart:self.cart success:YES]];
    [TrackerManager postEventWithSelector:[EventSelectors checkoutFinishedSelector] attributes:[EventAttributes chekcoutFinishWithCart:self.cart]];
    
    [TrackerManager sendTagWithTags:@{ @"PurchaseCount": @([UserDefaultsManager incrementCounter:kUDMPurchaseCount]) } completion:^(NSError *error) {
        if(error == nil) {
            NSLog(@"TrackerManager > PurchaseCount > %d", [UserDefaultsManager getCounter:kUDMPurchaseCount]);
        }
    }];
    
    //check if came from teasers and track that info
    NSDictionary* teaserTrackingInfoDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey];
    [self.cart.cartEntity.cartItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[RICartItem class]]) {
            NSString *teaserTrackingInfo = [teaserTrackingInfoDictionary objectForKey:((RICartItem *)obj).sku];
            if (teaserTrackingInfo.length) {
                [TrackerManager postEventWithSelector:[EventSelectors teaserPurchasedSelector] attributes:[EventAttributes teaserPurchaseWithTeaserName:teaserTrackingInfo screenName:@"HomePage"]];
            }
        }
    }];
    
    
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSkusFromTeaserInCartKey];
    //// ------- START OF LEGACY CODES ------
    // Notification to clean cart
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    [RICart resetCartWithSuccessBlock:^{} andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {}];
    
//    BOOL userDidFirstBuy = NO;
//    if(VALID_NOTEMPTY([[NSUserDefaults standardUserDefaults] objectForKey:kDidFirstBuyKey], NSNumber)) {
//        userDidFirstBuy = [[[NSUserDefaults standardUserDefaults] objectForKey:kDidFirstBuyKey] boolValue];
//    }
    
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
//    
//    NSString *isNewCustomer = @"false";
//    if([RICustomer wasSignup] && !userDidFirstBuy) {
//        isNewCustomer = @"true";
//    }
    
//    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
//    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
//    [trackingDictionary setValue:@"Finished" forKey:kRIEventActionKey];
//    [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
//    [trackingDictionary setValue:[NSNumber numberWithInteger:[self.cart.orderNr integerValue]] forKey:kRIEventValueKey];
//    
//    NSMutableString* attributeSetID = [NSMutableString new];
//    for( RICartItem* pd in [self.cart.cartEntity cartItems]) {
//        [attributeSetID appendFormat:@"%@;",[pd attributeSetID]];
//    }
//    [trackingDictionary setValue:[attributeSetID copy] forKey:kRIEventAttributeSetIDCartKey];
//    
//    if (VALID_NOTEMPTY(self.cart.totalNumberOfOrders, NSNumber)) {
//        [trackingDictionary setObject:self.cart.totalNumberOfOrders forKey:kRIEventAmountTransactions];
//    }
//    [trackingDictionary setObject:self.cart.orderNr ?: @"" forKey:kRIEventOrderNumber];
//    RICartItem* lastCartItem = [self.cart.cartEntity.cartItems lastObject];
//    if (VALID_NOTEMPTY(lastCartItem, RICartItem)) {
//        [trackingDictionary setObject:lastCartItem.name forKey:kRIEventProductNameKey];
//        [trackingDictionary setObject:lastCartItem.simpleSku forKey:kRIEventSkuKey];
//        [trackingDictionary setObject:lastCartItem.brand forKey:kRIEventBrandName];
//        [trackingDictionary setObject:lastCartItem.brandUrlKey forKey:kRIEventBrandKey];
//        if (VALID_NOTEMPTY(lastCartItem.category, NSString)) {
//            [trackingDictionary setObject:lastCartItem.category forKey:kRIEventCategoryNameKey];
//        }
//        if (VALID_NOTEMPTY(lastCartItem.categoryUrlKey, NSString)) {
//            [trackingDictionary setObject:lastCartItem.categoryUrlKey forKey:kRIEventCategoryIdKey];
//        }
//    }
//    [trackingDictionary setObject:@"0" forKey:kRIEventTotalCartKey];
    
//    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutEnd]
//                                              data:[trackingDictionary copy]];
    
//    NSMutableArray *viewCartTrackingProducts = [[NSMutableArray alloc] init];
//    
//    NSDictionary* teaserTrackingInfoDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey];
//    
//    NSNumber *priceSum = [NSNumber numberWithFloat:0.0f];
//    NSMutableArray *skusArray = [NSMutableArray new];
//    
//    for (int i = 0; i < self.cart.cartEntity.cartItems.count; i++) {
//        RICartItem *cartItem = [self.cart.cartEntity.cartItems objectAtIndex:i];
//        
//        BOOL isConverted = YES;
//        NSString *discount = @"false";
//        NSNumber *priceNumber = cartItem.priceEuroConverted;
//        if (VALID_NOTEMPTY(cartItem.specialPriceEuroConverted, NSNumber) && [cartItem.specialPriceEuroConverted longValue] > 0.0f) {
//            discount = @"true";
//            priceNumber = cartItem.specialPriceEuroConverted;
//        }
//        
//        if(!VALID_NOTEMPTY(priceNumber, NSNumber)) {
//            isConverted = NO;
//            priceNumber = cartItem.price;
//            if (VALID_NOTEMPTY(cartItem.specialPrice, NSNumber) && [cartItem.specialPrice longValue] > 0.0f) {
//                discount = @"true";
//                priceNumber = cartItem.specialPrice;
//            }
//        }
//        
//        [skusArray addObject:cartItem.sku];
//        priceSum = [NSNumber numberWithLong:([priceSum longValue] + [priceNumber longValue])];
//        
//        //check if came from teasers and track that info
//        NSString* teaserTrackingInfo = [teaserTrackingInfoDictionary objectForKey:cartItem.sku];
//        if (VALID_NOTEMPTY(teaserTrackingInfo, NSString)) {
//            NSMutableDictionary* teaserTrackingDictionary = [NSMutableDictionary new];
//            [teaserTrackingDictionary setValue:teaserTrackingInfo forKey:kRIEventCategoryKey];
//            [teaserTrackingDictionary setValue:@"Purchase" forKey:kRIEventActionKey];
//            [teaserTrackingDictionary setValue:cartItem.sku forKey:kRIEventLabelKey];
//            [teaserTrackingDictionary setValue:priceNumber forKey:kRIEventPriceKey];
//            
//            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventTeaserPurchase]
//                                                      data:[teaserTrackingDictionary copy]];
//        }
//        
//        NSMutableDictionary *viewCartTrackingProduct = [[NSMutableDictionary alloc] init];
//        [viewCartTrackingProduct setValue:cartItem.sku forKey:kRIEventSkuKey];
//        
//        // Since we're sending the converted price, we have to send the currency as EUR.
//        // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
//        [viewCartTrackingProduct setValue:priceNumber forKey:kRIEventPriceKey];
//        if(isConverted){
//            [viewCartTrackingProduct setObject:@"EUR" forKey:kRIEventCurrencyCodeKey];
//        } else {
//            [viewCartTrackingProduct setObject:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
//        }
//        
//        [viewCartTrackingProduct setValue:[cartItem.quantity stringValue] forKey:kRIEventQuantityKey];
//        [viewCartTrackingProducts addObject:viewCartTrackingProduct];
//    }
//    
//    trackingDictionary = [[NSMutableDictionary alloc] init];
//    
//    [trackingDictionary setValue:[priceSum stringValue] forKey:kRIEventFBValueToSumKey];
//    [trackingDictionary setValue:[skusArray componentsJoinedByString:@","] forKey:kRIEventFBContentIdKey];
//    [trackingDictionary setValue:@"product" forKey:kRIEventFBContentTypeKey];
//    [trackingDictionary setValue:@"EUR" forKey:kRIEventFBCurrency];
//    
//    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewTransaction]
//                                              data:[trackingDictionary copy]];
    
    //clean teaserTrackingInfoDictionary from user defaults
//    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSkusFromTeaserInCartKey];
    
//    trackingDictionary = [[NSMutableDictionary alloc] init];
//    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
//    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
//    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
//    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
//    [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
//    [trackingDictionary setValue:self.cart.orderNr forKey:kRIEventTransactionIdKey];
//    [trackingDictionary setValue:isNewCustomer forKey:kRIEventNewCustomerKey];
//    
//    if(VALID_NOTEMPTY(viewCartTrackingProducts, NSMutableArray)) {
//        [trackingDictionary setObject:[viewCartTrackingProducts copy] forKey:kRIEventProductsKey];
//    }
//    
//    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventTransactionConfirm]
//                                              data:[trackingDictionary copy]];
    
//    if(!userDidFirstBuy) {
//        // Send customer event
//        NSMutableDictionary *customerDictionary = [[NSMutableDictionary alloc] init];
//        [customerDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
//        [customerDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
//        [customerDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
//        [customerDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
//        [customerDictionary setValue:self.cart.orderNr forKey:kRIEcommerceTransactionIdKey];
//        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithFloat:RIEventGuestCustomer] data:customerDictionary];
//    }
    
//    
//    NSMutableDictionary *ecommerceDictionary = [[NSMutableDictionary alloc] init];
//    [ecommerceDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
//    [ecommerceDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
//    [ecommerceDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
//    [ecommerceDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
//    [ecommerceDictionary setValue:self.cart.orderNr forKey:kRIEcommerceTransactionIdKey];
//    [ecommerceDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEcommerceCurrencyKey];
//    [ecommerceDictionary setValue:self.cart.totalNumberOfOrders forKey:kRIEventAmountTransactions];
//    [ecommerceDictionary setValue:self.cart.cartEntity.paymentMethod forKey:kRIEcommercePaymentMethodKey];
//    
//    NSArray *products = self.cart.cartEntity.cartItems;
//    
//    NSMutableArray *ecommerceSkusArray = [NSMutableArray new];
//    NSMutableArray *ecommerceProductsArray = [NSMutableArray new];
//    CGFloat averageValue = 0.0f;
//    if(VALID_NOTEMPTY(products, NSArray)) {
//        for (RICartItem* product in products) {
//            [ecommerceSkusArray addObject:product.simpleSku];
//            
//            BOOL isConverted = YES;
//            NSMutableDictionary *productDictionary = [[NSMutableDictionary alloc] init];
//            [productDictionary setObject:product.sku forKey:kRIEventSkuKey];
//            [productDictionary setObject:product.name forKey:kRIEventProductNameKey];
//            [productDictionary setObject:product.quantity forKey:kRIEventQuantityKey];
//            
//            // Since we're sending the converted price, we have to send the currency as EUR.
//            // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
//            NSNumber *price = product.priceEuroConverted;
//            if(VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f) {
//                price = product.specialPriceEuroConverted;
//            }
//            
//            if(!VALID_NOTEMPTY(price, NSNumber)) {
//                isConverted = NO;
//                price = product.price;
//                if (VALID_NOTEMPTY(product.specialPrice, NSNumber) && [product.specialPrice floatValue] > 0.0f) {
//                    price = product.specialPrice;
//                }
//            }
//            
//            averageValue += [price longValue];
//            
//            // Since we're sending the converted price, we have to send the currency as EUR.
//            // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
//            [productDictionary setValue:price forKey:kRIEventPriceKey];
//            if(isConverted) {
//                [productDictionary setObject:@"EUR" forKey:kRIEventCurrencyCodeKey];
//            } else {
//                [productDictionary setObject:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
//            }
//            
//            [ecommerceProductsArray addObject:productDictionary];
//        }
//        
//        averageValue = averageValue / [products count];
//    }
//    [ecommerceDictionary setValue:[ecommerceSkusArray copy] forKey:kRIEcommerceSkusKey];
//    [ecommerceDictionary setValue:[NSNumber numberWithFloat:averageValue] forKey:kRIEcommerceCartAverageValueKey];
//    
//    if(VALID_NOTEMPTY(self.cart.cartEntity.couponCode, NSString)) {
//        [ecommerceDictionary setValue:self.cart.cartEntity.couponCode forKey:kRIEcommerceCouponKey];
//    }
//    
//    if(VALID_NOTEMPTY(self.cart.cartEntity.couponMoneyValueEuroConverted, NSNumber)) {
//        [ecommerceDictionary setValue:self.cart.cartEntity.couponMoneyValueEuroConverted forKey:kRIEcommerceCouponValue];
//    }
//    
//    [ecommerceDictionary setValue:self.cart.cartEntity.shippingValue forKey:kRIEcommerceShippingKey];
//    [ecommerceDictionary setValue:self.cart.cartEntity.vatValue forKey:kRIEcommerceTaxKey];
//    
//    NSNumber *total = self.cart.cartEntity.cartValue;
//    
//    NSNumber *convertedTotal = [NSNumber numberWithFloat:0.0f];
//    if(VALID_NOTEMPTY(self.cart.cartEntity.cartValueEuroConverted, NSNumber)) {
//        convertedTotal = self.cart.cartEntity.cartValueEuroConverted;
//    }
//    
//    [ecommerceDictionary setValue:total forKey:kRIEcommerceTotalValueKey];
//    [ecommerceDictionary setValue:convertedTotal forKey:kRIEcommerceConvertedTotalValueKey];
//    
//    NSNumber *grandTotal = self.cart.cartEntity.cartValue;
//    
//    NSNumber *convertedGrandTotal = [NSNumber numberWithFloat:0.0f];
//    if(VALID_NOTEMPTY(self.cart.cartEntity.cartValueEuroConverted, NSNumber)) {
//        convertedGrandTotal = self.cart.cartEntity.cartValueEuroConverted;
//    }
//    
//    [ecommerceDictionary setValue:grandTotal forKey:kRIEcommerceGrandTotalValueKey];
//    [ecommerceDictionary setValue:convertedGrandTotal forKey:kRIEcommerceConvertedGrandTotalValueKey];
//    
//    if([RICustomer wasSignup]) {
//        [ecommerceDictionary setValue:[NSNumber numberWithBool:[RICustomer wasSignup]] forKey:kRIEcommerceGuestKey];
//    }
//    
//    [ecommerceDictionary setValue:[ecommerceProductsArray copy] forKey:kRIEcommerceProducts];
//    
//    CGFloat totalOfPurchasesValue = grandTotal.longValue;
//    NSNumber *totalOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountValueTransactions];
//    if(VALID_NOTEMPTY(totalOfPurchases, NSNumber)) {
//        totalOfPurchasesValue += [totalOfPurchases longValue];
//    }
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:totalOfPurchasesValue] forKey:kRIEventAmountValueTransactions];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    [ecommerceDictionary setValue:[NSNumber numberWithFloat:totalOfPurchasesValue] forKey:kRIEventAmountValueTransactions];
//    
//    NSString *lastProductFavToCartSKU = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventProductFavToCartKey];
//    if (VALID_NOTEMPTY(lastProductFavToCartSKU, NSString)) {
//        [ecommerceDictionary setObject:lastProductFavToCartSKU forKey:kRIEventProductFavToCartKey];
//    }
//    
//    [[RITrackingWrapper sharedInstance] trackCheckout:ecommerceDictionary];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kDidFirstBuyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //// ------- END OF LEGACY CODES ------
    
    [self publishScreenLoadTime];
    [EmarsysPredictManager sendTransactionsOf:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"ThankYou"];
    self.tabBarController.tabBar.hidden = NO;
}

#pragma mark - EmarsysPredictProtocol
- (EMTransaction *)getDataCollection:(EMTransaction *)transaction {
    [transaction setPurchase:self.cart.orderNr ofItems: [self.cart convertItems]];
    return transaction;
}


- (NSArray<EMRecommendationRequest *> *)getRecommendations {
    NSString *recommendationLogic = self.cart.cartEntity.cartCount.integerValue == 1 ? @"ALSO_BOUGHT" : @"PERSONAL"; //Production requirement
    EMRecommendationRequest *recommend = [EMRecommendationRequest requestWithLogic: recommendationLogic];
    recommend.limit = 15;
    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
        if (!result.products.count) return;
        [ThreadManager executeOnMainThread:^{
            [self.carouselWidget fadeIn:0.15];
            [self.carouselWidget updateWithModel:[result.products map:^id(EMRecommendationItem *item) {
                return [RecommendItem instanceWithEMRecommendationItem:item];
            }]];
        }];
        
        //Reset the shared Cart entities
        [RICart sharedInstance].cartEntity.cartItems = @[];
    };
    
    return @[recommend];
}



#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return @"CheckoutFinish";
}

- (BOOL)isPreventSendTransactionInViewWillAppear {
    return YES;
}

#pragma mark - FeatureBoxCollectionViewWidgetViewDelegate
- (void)selectFeatureItem:(NSObject *)item widgetBox:(id)widgetBox {
    if ([item isKindOfClass:[RecommendItem class]]) {
        [TrackerManager postEventWithSelector:[EventSelectors recommendationTappedSelector] attributes:[EventAttributes tapEmarsysRecommendationWithScreenName:[self getScreenName] logic:self.cart.cartEntity.cartCount.integerValue == 1 ? @"ALSO_BOUGHT" : @"PERSONAL"]];
        [[NSNotificationCenter defaultCenter] postNotificationName: kDidSelectTeaserWithPDVUrlNofication
                                                            object: nil
                                                          userInfo: @{
                                                                      @"sku": ((RecommendItem *)item).sku,
                                                                      @"show_back_button": @(YES)
                                                                      }];
    }
}

#pragma mark - hide tabbar in this view controller
- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}

@end
