//
//  JASuccessPageViewController.m
//  Jumia
//
//  Created by Jose Mota on 17/02/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JASuccessPageViewController.h"
#import "RICustomer.h"
#import "RICartItem.h"
#import "JAUtils.h"
#import "RIAddress.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>
#import "RIProduct.h"
#import "JABottomBar.h"
#import "JAProductInfoHeaderLine.h"
#import "JAPDVSingleRelatedItem.h"

#define kTopMargin 20.f
#define kLateralMargin 16.f

@interface JASuccessPageViewController ()

@property (nonatomic, strong) UIScrollView *topScrollView;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UILabel *thankYouLabel;
@property (nonatomic, strong) UILabel *successMessageLabel;
@property (nonatomic, strong) UIButton *orderDetailsButton;
@property (nonatomic, strong) UIButton *continueShoppingButton;
@property (nonatomic, strong) JABottomBar *orderDetailsButtonBar;
@property (nonatomic, strong) JABottomBar *continueShoppingButtonBar;

@property (nonatomic, strong) UIView *rrView;
@property (nonatomic, strong) JAProductInfoHeaderLine *rrHeaderLine;
@property (nonatomic, strong) UIScrollView *rrScrollView;

@property (nonatomic, strong) NSSet *rrProducts;

@end

@implementation JASuccessPageViewController

- (UIScrollView *)topScrollView
{
    if (!VALID(_topScrollView, UIScrollView)) {
        CGFloat viewWidth = 320;
        _topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.width/2-viewWidth/2, 0, viewWidth, self.viewBounds.size.height)];
    }
    return _topScrollView;
}

- (UIImageView *)topImageView
{
    if (!VALID(_topImageView, UIImageView)) {
        CGSize imageSize = CGSizeMake(50, 50);
        _topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.topScrollView.width/2-imageSize.width/2, kTopMargin, imageSize.width, imageSize.height)];
        [_topImageView setImage:[UIImage imageNamed:@"successIcon"]];
    }
    return _topImageView;
}

- (UILabel *)thankYouLabel
{
    if (!VALID(_thankYouLabel, UILabel)) {
        CGFloat viewWidth = self.topScrollView.width;
        _thankYouLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.topImageView.frame) + 16.f, viewWidth-2*kLateralMargin, 20)];
        [_thankYouLabel setText:STRING_THANK_YOU_ORDER_TITLE];
        [_thankYouLabel setTextAlignment:NSTextAlignmentCenter];
        [_thankYouLabel setFont:JADisplay1NewFont];
        [_thankYouLabel setTextColor:JAGreen1Color];
        [_thankYouLabel setHeight:[_thankYouLabel sizeThatFits:CGSizeMake(viewWidth, CGFLOAT_MAX)].height];
    }
    return _thankYouLabel;
}

- (UILabel *)successMessageLabel
{
    if (!VALID(_successMessageLabel, UILabel)) {
        CGFloat viewWidth = self.topScrollView.width;
        _successMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.thankYouLabel.frame) + 16.f, viewWidth-2*kLateralMargin, 20)];
        [_successMessageLabel setText:STRING_ORDER_SUCCESS];
        [_successMessageLabel setNumberOfLines:0];
        [_successMessageLabel setTextAlignment:NSTextAlignmentCenter];
        [_successMessageLabel setFont:JABodyFont];
        [_successMessageLabel setTextColor:JABlack800Color];
        [_successMessageLabel setHeight:[_successMessageLabel sizeThatFits:CGSizeMake(viewWidth, CGFLOAT_MAX)].height];
    }
    return _successMessageLabel;
}

- (JABottomBar *)orderDetailsButtonBar
{
    if (!VALID(_orderDetailsButtonBar, JABottomBar)) {
        CGFloat viewWidth = self.topScrollView.width;
        _orderDetailsButtonBar = [[JABottomBar alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.successMessageLabel.frame)+16.f, viewWidth-2*kLateralMargin, kBottomDefaultHeight)];
        self.orderDetailsButton = [_orderDetailsButtonBar addButton:STRING_ORDER_DETAILS target:self action:@selector(goToTrackOrders)];
        [self.orderDetailsButton setBackgroundColor:[UIColor whiteColor]];
        [self.orderDetailsButton.layer setBorderColor:JABlack300Color.CGColor];
        [self.orderDetailsButton.layer setBorderWidth:1];
        [self.orderDetailsButton setTintColor:JABlack800Color];
    }
    return _orderDetailsButtonBar;
}

- (JABottomBar *)continueShoppingButtonBar
{
    if (!VALID(_continueShoppingButtonBar, JABottomBar)) {
        CGFloat viewWidth = self.topScrollView.width;
        _continueShoppingButtonBar = [[JABottomBar alloc] initWithFrame:CGRectMake(kLateralMargin, CGRectGetMaxY(self.orderDetailsButtonBar.frame)+16.f, viewWidth-2*kLateralMargin, kBottomDefaultHeight)];
        self.continueShoppingButton = [_continueShoppingButtonBar addButton:STRING_CONTINUE_SHOPPING target:self action:@selector(goToHomeScreen)];
    }
    return _continueShoppingButtonBar;
}

- (UIView *)rrView
{
    if (!VALID(_rrView, UIView)) {
        _rrView = [[UIView alloc] init];
    }
    return _rrView;
}

- (JAProductInfoHeaderLine *)rrHeaderLine
{
    if (!VALID(_rrHeaderLine, JAProductInfoHeaderLine)) {
        _rrHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, 0, self.rrView.width, kProductInfoHeaderLineHeight)];
        [_rrHeaderLine setTopSeparatorVisibility:YES];
        [_rrHeaderLine setBottomSeparatorVisibility:YES];
        [_rrHeaderLine setBackgroundColor:[UIColor whiteColor]];
    }
    return _rrHeaderLine;
}

- (UIScrollView *)rrScrollView
{
    if (!VALID(_rrScrollView, UIScrollView)) {
        _rrScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.rrHeaderLine.frame), self.rrView.width, 200)];
        [_rrScrollView setBackgroundColor:JABlack200Color];
        [_rrScrollView setContentSize:CGSizeMake(1024, _rrScrollView.height)];
    }
    return _rrScrollView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"CheckoutFinish";
    
    self.navBarLayout.title = STRING_CHECKOUT;
    self.navBarLayout.showCartButton = NO;
    self.tabBarIsVisible = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.topScrollView];
    [self.topScrollView addSubview:self.topImageView];
    [self.topScrollView addSubview:self.thankYouLabel];
    [self.topScrollView addSubview:self.successMessageLabel];
    [self.topScrollView addSubview:self.orderDetailsButtonBar];
    [self.topScrollView addSubview:self.continueShoppingButtonBar];
    [self.rrView addSubview:self.rrHeaderLine];
    [self.rrView addSubview:self.rrScrollView];
    
    // Notification to clean cart
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    [RICart resetCartWithSuccessBlock:^{} andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {}];
    
    [RIProduct getRichRelevanceRecommendationFromTarget:self.rrTargetString successBlock:^(NSSet *recommendationProducts) {
        [self setRrProducts:recommendationProducts];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
        NSLog(@"recommendationProducts: FAILED!!!! %@", [errorMessage componentsJoinedByString:@", "]);
    }];
    
    BOOL userDidFirstBuy = NO;
    if(VALID_NOTEMPTY([[NSUserDefaults standardUserDefaults] objectForKey:kDidFirstBuyKey], NSNumber))
    {
        userDidFirstBuy = [[[NSUserDefaults standardUserDefaults] objectForKey:kDidFirstBuyKey] boolValue];
    }
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
    
    NSString *isNewCustomer = @"false";
    if([RICustomer wasSignup] && !userDidFirstBuy)
    {
        isNewCustomer = @"true";
    }
    
    NSInteger numberOfPurchasesValue = 0;
    NSNumber *numberOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountTransactions];
    if(VALID_NOTEMPTY(numberOfPurchases, NSNumber))
    {
        numberOfPurchasesValue = [numberOfPurchases integerValue];
    }
    numberOfPurchasesValue++;
    numberOfPurchases = [NSNumber numberWithInteger:numberOfPurchasesValue];
    [[NSUserDefaults standardUserDefaults] setObject:numberOfPurchases forKey:kRIEventAmountTransactions];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"Finished" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:[NSNumber numberWithInteger:[self.cart.orderNr integerValue]] forKey:kRIEventValueKey];
    
    NSMutableString* attributeSetID = [NSMutableString new];
    for( RICartItem* pd in [self.cart cartItems]) {
        [attributeSetID appendFormat:@"%@;",[pd attributeSetID]];
    }
    [trackingDictionary setValue:[attributeSetID copy] forKey:kRIEventAttributeSetIDCartKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutEnd]
                                              data:[trackingDictionary copy]];
    
    NSMutableArray *viewCartTrackingProducts = [[NSMutableArray alloc] init];
    
    NSDictionary* teaserTrackingInfoDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey];
    
    for (int i = 0; i < self.cart.cartItems.count; i++) {
        trackingDictionary = [[NSMutableDictionary alloc] init];
        
        RICartItem *cartItem = [self.cart.cartItems objectAtIndex:i];
        
        BOOL isConverted = YES;
        NSString *discount = @"false";
        NSNumber *priceNumber = cartItem.priceEuroConverted;
        if (VALID_NOTEMPTY(cartItem.specialPriceEuroConverted, NSNumber) && [cartItem.specialPriceEuroConverted floatValue] > 0.0f)
        {
            discount = @"true";
            priceNumber = cartItem.specialPriceEuroConverted;
        }
        
        if(!VALID_NOTEMPTY(priceNumber, NSNumber))
        {
            isConverted = NO;
            priceNumber = cartItem.price;
            if (VALID_NOTEMPTY(cartItem.specialPrice, NSNumber) && [cartItem.specialPrice floatValue] > 0.0f)
            {
                discount = @"true";
                priceNumber = cartItem.specialPrice;
            }
        }
        
        //check if came from teasers and track that info
        NSString* teaserTrackingInfo = [teaserTrackingInfoDictionary objectForKey:cartItem.sku];
        if (VALID_NOTEMPTY(teaserTrackingInfo, NSString)) {
            NSMutableDictionary* teaserTrackingDictionary = [NSMutableDictionary new];
            [teaserTrackingDictionary setValue:teaserTrackingInfo forKey:kRIEventCategoryKey];
            [teaserTrackingDictionary setValue:@"Purchase" forKey:kRIEventActionKey];
            [teaserTrackingDictionary setValue:cartItem.sku forKey:kRIEventLabelKey];
            [teaserTrackingDictionary setValue:priceNumber forKey:kRIEventPriceKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventTeaserPurchase]
                                                      data:[teaserTrackingDictionary copy]];
        }
        
        // Since we're sending the converted price, we have to send the currency as EUR.
        // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
        [trackingDictionary setValue:priceNumber forKey:kRIEventPriceKey];
        if(isConverted)
        {
            [trackingDictionary setObject:@"EUR" forKey:kRIEventCurrencyCodeKey];
        }
        else
        {
            [trackingDictionary setObject:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
        }
        
        [trackingDictionary setValue:cartItem.quantity forKey:kRIEventQuantityKey];
        
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
        if(VALID_NOTEMPTY(numberOfSessions, NSNumber))
        {
            [trackingDictionary setValue:[numberOfSessions stringValue] forKey:kRIEventAmountSessions];
        }
        [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
        [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
        [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [trackingDictionary setValue:cartItem.sku forKey:kRIEventSkuKey];
        
        // Since we're sending the converted price, we have to send the currency as EUR.
        // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
        [trackingDictionary setValue:priceNumber forKey:kRIEventPriceKey];
        if(isConverted)
        {
            [trackingDictionary setObject:@"EUR" forKey:kRIEventCurrencyCodeKey];
        }
        else
        {
            [trackingDictionary setObject:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
        }
        
        [trackingDictionary setValue:discount forKey:kRIEventDiscountKey];
        [trackingDictionary setValue:[cartItem.quantity stringValue] forKey:kRIEventQuantityKey];
        [trackingDictionary setValue:cartItem.variation forKey:kRIEventSizeKey];
        [trackingDictionary setValue:isNewCustomer forKey:kRIEventNewCustomerKey];
        [trackingDictionary setValue:[self.cart.cartValueEuroConverted stringValue] forKey:kRIEventTotalTransactionKey];
        [trackingDictionary setValue:self.cart.orderNr forKey:kRIEventTransactionIdKey];
        
        if ([RICustomer checkIfUserIsLogged]) {
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
            [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
                RIAddress *shippingAddress = (RIAddress *)[adressList objectForKey:@"shipping"];
                [trackingDictionary setValue:shippingAddress.city forKey:kRIEventCityKey];
                [trackingDictionary setValue:shippingAddress.customerAddressRegion forKey:kRIEventRegionKey];
                
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewTransaction]
                                                          data:[trackingDictionary copy]];
                
            } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                NSLog(@"ERROR: getting customer");
                [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewTransaction]
                                                          data:[trackingDictionary copy]];
            }];
        }else{
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookViewTransaction]
                                                      data:[trackingDictionary copy]];
        }
        
        float value = [cartItem.price floatValue];
        [FBSDKAppEvents logPurchase:value currency:@"EUR" parameters:@{FBSDKAppEventParameterNameContentID: cartItem.sku,
                                                                       FBSDKAppEventParameterNameContentType:cartItem.name}];
        
        NSMutableDictionary *viewCartTrackingProduct = [[NSMutableDictionary alloc] init];
        [viewCartTrackingProduct setValue:cartItem.sku forKey:kRIEventSkuKey];
        
        // Since we're sending the converted price, we have to send the currency as EUR.
        // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
        [viewCartTrackingProduct setValue:priceNumber forKey:kRIEventPriceKey];
        if(isConverted)
        {
            [viewCartTrackingProduct setObject:@"EUR" forKey:kRIEventCurrencyCodeKey];
        }
        else
        {
            [viewCartTrackingProduct setObject:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
        }
        
        [viewCartTrackingProduct setValue:[cartItem.quantity stringValue] forKey:kRIEventQuantityKey];
        [viewCartTrackingProducts addObject:viewCartTrackingProduct];
    }
    
    //clean teaserTrackingInfoDictionary from user defaults
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSkusFromTeaserInCartKey];
    
    trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
    [trackingDictionary setValue:self.cart.orderNr forKey:kRIEventTransactionIdKey];
    [trackingDictionary setValue:isNewCustomer forKey:kRIEventNewCustomerKey];
    
    if(VALID_NOTEMPTY(viewCartTrackingProducts, NSMutableArray))
    {
        [trackingDictionary setObject:[viewCartTrackingProducts copy] forKey:kRIEventProductsKey];
    }
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventTransactionConfirm]
                                              data:[trackingDictionary copy]];
    
    if(!userDidFirstBuy)
    {
        // Send customer event
        NSMutableDictionary *customerDictionary = [[NSMutableDictionary alloc] init];
        [customerDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
        [customerDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [customerDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        [customerDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
        [customerDictionary setValue:self.cart.orderNr forKey:kRIEcommerceTransactionIdKey];
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithFloat:RIEventGuestCustomer] data:customerDictionary];
    }
    
    
    NSMutableDictionary *ecommerceDictionary = [[NSMutableDictionary alloc] init];
    [ecommerceDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [ecommerceDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [ecommerceDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    [ecommerceDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
    [ecommerceDictionary setValue:self.cart.orderNr forKey:kRIEcommerceTransactionIdKey];
    [ecommerceDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEcommerceCurrencyKey];
    [ecommerceDictionary setValue:numberOfPurchases forKey:kRIEventAmountTransactions];
    [ecommerceDictionary setValue:self.cart.paymentMethod forKey:kRIEcommercePaymentMethodKey];
    
    NSArray *products = self.cart.cartItems;
    
    NSMutableArray *ecommerceSkusArray = [NSMutableArray new];
    NSMutableArray *ecommerceProductsArray = [NSMutableArray new];
    CGFloat averageValue = 0.0f;
    if(VALID_NOTEMPTY(products, NSArray))
    {
        for (RICartItem* product in products) {
            [ecommerceSkusArray addObject:product.simpleSku];
            
            BOOL isConverted = YES;
            NSMutableDictionary *productDictionary = [[NSMutableDictionary alloc] init];
            [productDictionary setObject:product.sku forKey:kRIEventSkuKey];
            [productDictionary setObject:product.name forKey:kRIEventProductNameKey];
            [productDictionary setObject:product.quantity forKey:kRIEventQuantityKey];
            
            // Since we're sending the converted price, we have to send the currency as EUR.
            // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
            NSNumber *price = product.priceEuroConverted;
            if(VALID_NOTEMPTY(product.specialPriceEuroConverted, NSNumber) && [product.specialPriceEuroConverted floatValue] > 0.0f)
            {
                price = product.specialPriceEuroConverted;
            }
            
            if(!VALID_NOTEMPTY(price, NSNumber))
            {
                isConverted = NO;
                price = product.price;
                if (VALID_NOTEMPTY(product.specialPrice, NSNumber) && [product.specialPrice floatValue] > 0.0f)
                {
                    price = product.specialPrice;
                }
            }
            
            averageValue += [price floatValue];
            
            // Since we're sending the converted price, we have to send the currency as EUR.
            // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
            [productDictionary setValue:price forKey:kRIEventPriceKey];
            if(isConverted)
            {
                [productDictionary setObject:@"EUR" forKey:kRIEventCurrencyCodeKey];
            }
            else
            {
                [productDictionary setObject:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
            }
            
            [ecommerceProductsArray addObject:productDictionary];
        }
        
        averageValue = averageValue / [products count];
    }
    [ecommerceDictionary setValue:[ecommerceSkusArray copy] forKey:kRIEcommerceSkusKey];
    [ecommerceDictionary setValue:[NSNumber numberWithFloat:averageValue] forKey:kRIEcommerceCartAverageValueKey];
    
    if(VALID_NOTEMPTY(self.cart.couponCode, NSString))
    {
        [ecommerceDictionary setValue:self.cart.couponCode forKey:kRIEcommerceCouponKey];
    }
    
    if(VALID_NOTEMPTY(self.cart.couponMoneyValueEuroConverted, NSNumber))
    {
        [ecommerceDictionary setValue:self.cart.couponMoneyValueEuroConverted forKey:kRIEcommerceCouponValue];
    }
    
    [ecommerceDictionary setValue:self.cart.shippingValue forKey:kRIEcommerceShippingKey];
    [ecommerceDictionary setValue:self.cart.vatValue forKey:kRIEcommerceTaxKey];
    
    NSNumber *total = self.cart.cartValue;
    
    NSNumber *convertedTotal = [NSNumber numberWithFloat:0.0f];
    if(VALID_NOTEMPTY(self.cart.cartValueEuroConverted, NSNumber))
    {
        convertedTotal = self.cart.cartValueEuroConverted;
    }
    
    [ecommerceDictionary setValue:total forKey:kRIEcommerceTotalValueKey];
    [ecommerceDictionary setValue:convertedTotal forKey:kRIEcommerceConvertedTotalValueKey];
    
    NSNumber *grandTotal = self.cart.cartValue;
    
    NSNumber *convertedGrandTotal = [NSNumber numberWithFloat:0.0f];
    if(VALID_NOTEMPTY(self.cart.cartValueEuroConverted, NSNumber))
    {
        convertedGrandTotal = self.cart.cartValueEuroConverted;
    }
    
    [ecommerceDictionary setValue:grandTotal forKey:kRIEcommerceGrandTotalValueKey];
    [ecommerceDictionary setValue:convertedGrandTotal forKey:kRIEcommerceConvertedGrandTotalValueKey];
    
    if([RICustomer wasSignup])
    {
        [ecommerceDictionary setValue:[NSNumber numberWithBool:[RICustomer wasSignup]] forKey:kRIEcommerceGuestKey];
    }
    
    [ecommerceDictionary setValue:[ecommerceProductsArray copy] forKey:kRIEcommerceProducts];
    
    CGFloat totalOfPurchasesValue = grandTotal.floatValue;
    NSNumber *totalOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountValueTransactions];
    if(VALID_NOTEMPTY(totalOfPurchases, NSNumber))
    {
        totalOfPurchasesValue += [totalOfPurchases floatValue];
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithFloat:totalOfPurchasesValue] forKey:kRIEventAmountValueTransactions];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [ecommerceDictionary setValue:[NSNumber numberWithFloat:totalOfPurchasesValue] forKey:kRIEventAmountValueTransactions];
    
    NSString *lastProductFavToCartSKU = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventProductFavToCartKey];
    if (VALID_NOTEMPTY(lastProductFavToCartSKU, NSString)) {
        [ecommerceDictionary setObject:lastProductFavToCartSKU forKey:kRIEventProductFavToCartKey];
    }
    
    [[RITrackingWrapper sharedInstance] trackCheckout:ecommerceDictionary];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:kDidFirstBuyKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
    [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
}

- (void)setRrProducts:(NSSet *)rrProducts
{
    _rrProducts = rrProducts;
    [self reloadRR];
}

- (void)reloadRR
{
    [[self.rrScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    /*******
     Related Items
     *******/
    
    if (VALID_NOTEMPTY(self.rrProducts, NSSet) && 0 < self.rrProducts.count)
    {
        CGFloat relatedItemX = 6.f;
        CGFloat relatedItemY = 10.f;
        
        NSArray* relatedProducts = [self.rrProducts allObjects];
        
        CGSize itemSize = CGSizeMake(128, 230);
        
        for (int i = 0; i < relatedProducts.count; i++) {
            RIProduct* product = [relatedProducts objectAtIndex:i];
            
            JAPDVSingleRelatedItem *singleItem = [[JAPDVSingleRelatedItem alloc] initWithFrame:CGRectMake(0, 0, itemSize.width, itemSize.height)];
            [singleItem setBackgroundColor:[UIColor whiteColor]];
            singleItem.tag = i;
            [singleItem addTarget:self
                           action:@selector(goToSelectedRelatedItem:)
                 forControlEvents:UIControlEventTouchUpInside];
            
            CGRect tempFrame = singleItem.frame;
            tempFrame.origin.x = relatedItemX;
            tempFrame.origin.y = relatedItemY;
            singleItem.frame = tempFrame;
            singleItem.product = product;
            
            [self.rrScrollView addSubview:singleItem];
            relatedItemX += singleItem.frame.size.width+6.f;
        }
        [self.rrScrollView setHeight:itemSize.height+20];
        [self.rrView setHeight:CGRectGetMaxY(self.rrScrollView.frame)];
        
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
        {
            if (!VALID(self.rrView.superview, UIView)) {
                [self.view addSubview:self.rrView];
            }
            [self.rrView setY:self.viewBounds.size.height - self.rrView.height];
            [self.rrView setWidth:self.rrView.superview.width];
        }else{
            if (!VALID(self.rrView.superview, UIView)) {
                [self.topScrollView addSubview:self.rrView];
            }
            [self.rrView setY:CGRectGetMaxY(self.continueShoppingButtonBar.frame)+16.f];
            [self.rrView setWidth:self.rrView.superview.width];
            [self.topScrollView setContentSize:CGSizeMake(self.topScrollView.width, CGRectGetMaxY(self.rrView.frame))];
        }
        [self.rrHeaderLine setWidth:self.rrView.width];
        [self.rrScrollView setWidth:self.rrView.width];
        
        self.rrScrollView.contentSize = CGSizeMake(relatedItemX<self.rrScrollView.width?self.rrScrollView.width:relatedItemX, self.rrScrollView.frame.size.height);
        
        if (RI_IS_RTL) {
            [self.rrView flipAllSubviews];
        }
    }
    
}

- (void)onOrientationChanged
{
    [super onOrientationChanged];
    CGFloat viewWidth = 320;
    [self.topScrollView setFrame:CGRectMake(self.view.width/2-viewWidth/2, 0, viewWidth, self.viewBounds.size.height)];
    if (VALID_NOTEMPTY(self.rrProducts, NSSet)) {
        [self reloadRR];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.topScrollView setHeight:self.viewBounds.size.height];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"ThankYou"];
}

#pragma mark - Actions

- (void)goToSelectedRelatedItem:(UIControl*)sender
{
    NSArray* relatedProducts = [self.rrProducts allObjects];
    RIProduct *tempProduct = [relatedProducts objectAtIndex:sender.tag];
    
    NSMutableDictionary* userInfo = [NSMutableDictionary new];
    [userInfo setObject:[NSNumber numberWithBool:YES] forKey:@"show_back_button"];
    
    if (VALID_NOTEMPTY(tempProduct.targetString, NSString)) {
        [userInfo setObject:tempProduct.targetString forKey:@"targetString"];
        
        if (VALID_NOTEMPTY(tempProduct.richRelevanceParameter, NSString)) {
            [userInfo setObject:tempProduct.richRelevanceParameter forKey:@"richRelevance"];
        }
    } else if (VALID_NOTEMPTY(tempProduct.sku, NSString)) {
        [userInfo setObject:tempProduct.sku forKey:@"sku"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)goToHomeScreen
{
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"ContinueShopping" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutContinueShopping]
                                              data:[trackingDictionary copy]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}

- (void)goToTrackOrders
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowMyOrdersScreenNotification object:self.cart.orderNr];
}

@end
