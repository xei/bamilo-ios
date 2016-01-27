//
//  JAThanksViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 12/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAThanksViewController.h"
#import "RICustomer.h"
#import "RICartItem.h"
#import "JAUtils.h"
#import "RIAddress.h"
#import <FBSDKCoreKit/FBSDKAppEvents.h>

@interface JAThanksViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *thankYouLabel;
@property (weak, nonatomic) IBOutlet UILabel *successMessage;
@property (weak, nonatomic) IBOutlet UILabel *trackOrderMessage;
@property (weak, nonatomic) IBOutlet UITextField *orderNumberField;
@property (weak, nonatomic) IBOutlet UIButton *orderCopyButton;
@property (weak, nonatomic) IBOutlet UIButton *continueShoppingButton;

@property (nonatomic, strong)UIButton* goToTrackOrdersButton;

@end

@implementation JAThanksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    self.screenName = @"CheckoutFinish";
    
    self.navBarLayout.title = STRING_CHECKOUT;
    self.navBarLayout.showCartButton = NO;
    
    self.view.backgroundColor = JABackgroundGrey;
    
    // Notification to clean cart
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    [RICart resetCartWithSuccessBlock:^{} andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {}];
    
    self.contentView.layer.cornerRadius = 5.0f;
    self.thankYouLabel.font = [UIFont fontWithName:kFontRegularName size:self.thankYouLabel.font.pointSize];
    self.thankYouLabel.textColor = UIColorFromRGB(0x666666);
    self.thankYouLabel.text = STRING_THANK_YOU_ORDER_TITLE;
    self.successMessage.font = [UIFont fontWithName:kFontLightName size:self.successMessage.font.pointSize];
    self.successMessage.textColor = UIColorFromRGB(0x666666);
    self.successMessage.text = STRING_ORDER_SUCCESS;

    NSString* baseString = STRING_ORDER_TRACK_SUCCESS;
    NSDictionary* baseAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:kFontLightName size:12], NSFontAttributeName,
                                    UIColorFromRGB(0x666666), NSForegroundColorAttributeName, nil];
    
    NSString* particleString = STRING_ORDER_TRACK_LINK;
    NSRange particleStringRange = [baseString rangeOfString:particleString];
    NSDictionary* highlightAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [UIFont fontWithName:kFontLightName size:12], NSFontAttributeName,
                                         UIColorFromRGB(0x55a1ff), NSForegroundColorAttributeName, nil];
    
    NSMutableAttributedString* finalString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:baseAttributes];
    [finalString setAttributes:highlightAttributes range:particleStringRange];
    
    self.trackOrderMessage.font = [UIFont fontWithName:kFontLightName size:self.trackOrderMessage.font.pointSize];
    self.trackOrderMessage.attributedText = finalString;
    
    self.goToTrackOrdersButton = [[UIButton alloc] init];
    [self.goToTrackOrdersButton addTarget:self action:@selector(goToTrackOrders) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.goToTrackOrdersButton];
    
    //STRING_ORDER_TRACK_LINK
    self.orderNumberField.font = [UIFont fontWithName:kFontBoldName size:self.orderNumberField.font.pointSize];
    [self.orderNumberField setText:self.cart.orderNr];
    self.orderNumberField.textColor = UIColorFromRGB(0x4e4e4e);
    
    [self.orderCopyButton addTarget:self action:@selector(copyOrderNumber) forControlEvents:UIControlEventTouchUpInside];
    
    self.continueShoppingButton.titleLabel.font = [UIFont fontWithName:kFontRegularName size:self.continueShoppingButton.titleLabel.font.pointSize];
    [self.continueShoppingButton setTitleColor:JAButtonTextOrange forState:UIControlStateNormal];
    [self.continueShoppingButton setTitle:STRING_CONTINUE_SHOPPING forState:UIControlStateNormal];
    
    self.continueShoppingButton.layer.cornerRadius = 5.0f;
    
    [self.continueShoppingButton addTarget:self action:@selector(goToHomeScreen) forControlEvents:UIControlEventTouchUpInside];
    
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"ThankYou"];
    
    [self.goToTrackOrdersButton setFrame:self.trackOrderMessage.frame];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.goToTrackOrdersButton setFrame:self.trackOrderMessage.frame];
}

- (void)copyOrderNumber
{
    [[UIPasteboard generalPasteboard] setString:[self.orderNumberField text]];
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
