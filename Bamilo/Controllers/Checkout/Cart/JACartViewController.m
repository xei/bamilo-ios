//
//  JACartViewController.m
//  Jumia
//
//  Created by Jose Mota on 11/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JACartViewController.h"
#import "JACartProductsView.h"
#import "JAEmptyCartView.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import "JAButton.h"
#import "JACartResumeView.h"
#import "RICartItem.h"
#import "JAAuthenticationViewController.h"
#import "RIAddress.h"
#import "JAPicker.h"

@interface JACartViewController () <JACartProductsProtocol, JAPickerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) JAEmptyCartView *emptyCartView;
@property (nonatomic, strong) JACartProductsView *cartProductsView;
@property (nonatomic, strong) JACartResumeView *resumeView;

@property (nonatomic, strong) JAPicker *picker;
@property (nonatomic, strong) RICartItem *currentItem;

@end

@implementation JACartViewController

- (UIScrollView *)scrollView
{
    if (!VALID(_scrollView, UIScrollView)) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

- (JAEmptyCartView *)emptyCartView
{
    if (!VALID(_emptyCartView, JAEmptyCartView)) {
        _emptyCartView = [[JAEmptyCartView alloc] initWithFrame:self.viewBounds];
        [_emptyCartView setBackgroundColor:JAWhiteColor];
        [_emptyCartView addHomeScreenTarget:self action:@selector(goToHomeScreen)];
        [self.view addSubview:_emptyCartView];
    }
    return _emptyCartView;
}

- (JACartProductsView *)cartProductsView
{
    if (!VALID(_cartProductsView, JACartProductsView)) {
        _cartProductsView = [[JACartProductsView alloc] initWithFrame:CGRectZero];
        [_cartProductsView setBackgroundColor:JAOrange1Color];
        [_cartProductsView setDelegate:self];
        [self.view addSubview:_cartProductsView];
    }
    return _cartProductsView;
}

- (JACartResumeView *)resumeView
{
    if (!VALID(_resumeView, JACartResumeView)) {
        _resumeView = [[JACartResumeView alloc] initWithFrame:CGRectZero];
        [_resumeView addProceedTarget:self action:@selector(proceedToCheckout)];
        [_resumeView addCallTarget:self action:@selector(proceedToCall)];
        [_resumeView addCouponTarget:self action:@selector(useCoupon)];
        [self.scrollView addSubview:_resumeView];
    }
    return _resumeView;
}

- (void)setCart:(RICart *)cart
{
    _cart = cart;
    if (VALID(self.cart, RICart)) {
        if (self.cart.cartCount.integerValue == 0) {
            [self setCartEmpty:YES];
            return;
        }
        [self setCartEmpty:NO];
        [self.cartProductsView setCart:self.cart];
        [self.resumeView setCart:self.cart];
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, CGRectGetMaxY(self.resumeView.frame))];
        [self viewWillLayoutSubviews];
    }
}

- (void)setCartEmpty:(BOOL)empty
{
    [self.cartProductsView setHidden:empty];
    [self.resumeView setHidden:empty];
    [self.emptyCartView setHidden:!empty];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.A4SViewControllerAlias = @"CART";
    self.screenName = @"Cart";

    self.navBarLayout.title = STRING_CART;
    self.navBarLayout.showBackButton = NO;
    self.navBarLayout.showCartButton = NO;
    self.tabBarIsVisible = YES;
    
    [self.view setBackgroundColor:JAWhiteColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadingCart];
    if (self.firstLoading) {
        NSMutableDictionary* skusFromTeaserInCart = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey]];

        NSNumber *timeInMillis =  [NSNumber numberWithInt:(int)([self.startLoadingTime timeIntervalSinceNow]*-1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName label:[NSString stringWithFormat:@"%@", [skusFromTeaserInCart allKeys]]];
        self.firstLoading = NO;
    }
}

- (void)loadingCart
{
    [self showLoading];
    [self setCartEmpty:YES];
    [RICart getCartWithSuccessBlock:^(RICart *cartData) {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cartData forKey:kUpdateCartNotificationValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
        self.cart = cartData;
        if (VALID_NOTEMPTY(self.cart.cartItems, NSArray)) {
            [self setCartEmpty:NO];
        }else{
            [self setCartEmpty:YES];
        }
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadingCart) objects:nil];
        [self hideLoading];
    }];
}

- (void)viewWillLayoutSubviews
{
    [self.emptyCartView setFrame:self.viewBounds];
    if (self.isIpadLandscape) {
        if (self.cartProductsView.superview != self.view) {
            [self.view addSubview:self.cartProductsView];
        }
        [self.scrollView setFrame:CGRectMake(self.view.width/2, 0.f, self.viewBounds.size.width/2, self.viewBounds.size.height)];
        [self.cartProductsView setFrame:CGRectMake(self.viewBounds.origin.x, self.viewBounds.origin.y, self.viewBounds.size.width/2, self.viewBounds.size.height)];
        [self.resumeView setY:0.f];
    }else{
        if (self.cartProductsView.superview != self.scrollView) {
            [self.scrollView addSubview:self.cartProductsView];
        }
        [self.scrollView setFrame:self.viewBounds];
        [self.cartProductsView setFrame:CGRectMake(self.viewBounds.origin.x, self.viewBounds.origin.y, self.viewBounds.size.width, self.cartProductsView.maxHeight)];
        [self.resumeView setY:CGRectGetMaxY(self.cartProductsView.frame)];
    }
    [self.resumeView setWidth:self.scrollView.width];
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, CGRectGetMaxY(self.resumeView.frame))];
    
    if (RI_IS_RTL) {
        [self.cartProductsView flipViewPositionInsideSuperview];
        [self.scrollView flipViewPositionInsideSuperview];
    }
    
    [super viewWillLayoutSubviews];
}

- (void)onOrientationChanged {
    if(VALID(self.picker, JAPicker))
    {
        [self setupPickerView];
    }
}

-(void) goToHomeScreen {
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"ContinueShopping" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutContinueShopping]
                                              data:[trackingDictionary copy]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}

- (void) proceedToCheckout {
    [JAAuthenticationViewController goToCheckoutWithBlock:^{
//        [self showLoading];
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"Started" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
        
        [trackingDictionary setValue:[NSNumber numberWithInteger:[[self.cart cartItems] count]] forKey:kRIEventQuantityKey];
        [trackingDictionary setValue:[self.cart cartValueEuroConverted] forKey:kRIEventTotalCartKey];
        
        NSMutableString* attributeSetID = [NSMutableString new];
        for (RICartItem* pd in [self.cart cartItems]) {
            [attributeSetID appendFormat:@"%@;",[pd attributeSetID]];
        }
        [trackingDictionary setValue:[attributeSetID copy] forKey:kRIEventAttributeSetIDCartKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutStart]
                                                  data:[trackingDictionary copy]];
        
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification object:nil userInfo:nil];
    
        [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CheckoutAddress"];
        
        //        [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
        //            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        //            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
        //            [trackingDictionary setValue:@"Started" forKey:kRIEventActionKey];
        //            [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
        //
        //            [trackingDictionary setValue:[NSNumber numberWithInteger:[[self.cart cartItems] count]] forKey:kRIEventQuantityKey];
        //            [trackingDictionary setValue:[self.cart cartValueEuroConverted] forKey:kRIEventTotalCartKey];
        //
        //            NSMutableString* attributeSetID = [NSMutableString new];
        //            for (RICartItem* pd in [self.cart cartItems]) {
        //                [attributeSetID appendFormat:@"%@;",[pd attributeSetID]];
        //            }
        //            [trackingDictionary setValue:[attributeSetID copy] forKey:kRIEventAttributeSetIDCartKey];
        //
        //            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutStart]
        //                                                      data:[trackingDictionary copy]];
        //
        //            [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        //            [self hideLoading];
        //
        ////            if (VALID_NOTEMPTY(adressList, NSDictionary)) {
        //                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
        //                                                                    object:nil
        //                                                                  userInfo:nil];
        //                [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CheckoutAddress"];
        ////            } else {
        ////                NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES]] forKeys:@[@"show_back_button", @"from_checkout"]];
        ////
        ////                [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
        ////                                                                    object:nil
        ////                                                                  userInfo:userInfo];
        ////                [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CheckoutAddress"];
        ////            }
        //        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        //            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        //            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
        //            [trackingDictionary setValue:@"NativeCheckoutError" forKey:kRIEventActionKey];
        //            [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
        //
        //            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutError]
        //                                                      data:[trackingDictionary copy]];
        //            
        //            [self hideLoading];
        //            
        //            [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:@selector(proceedToCheckout) objects:nil];
        //        }];
    }];
}

- (void) proceedToCall {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"تماس با تیم خدمات مشتریان بامیلو" delegate:nil cancelButtonTitle:@"لغو" otherButtonTitles:@"تایید", nil];
    alert.delegate = self;
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != 0) {
        [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration) {
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
            [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCallToOrder]
                                                      data:[trackingDictionary copy]];
            
            NSString *phoneNumber = [@"tel://" stringByAppendingString:[JAUtils convertToEnglishNumber:configuration.phoneNumber]];//tessa
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:nil objects:nil];
        }];
    }
}

- (void)useCoupon {
    NSString *voucherCode = self.resumeView.couponTextField.text;
    if (!VALID_NOTEMPTY(voucherCode, NSString)) {
        [self onErrorResponse:RIApiResponseUnknownError messages:@[STRING_VOUCHER_ERROR] showAsMessage:YES target:nil selector:nil objects:nil];
        return;
    }
    
    [self showLoading];
    
    if(VALID([[self cart] couponMoneyValue], NSNumber))
    {
        [RICart removeVoucherWithCode:voucherCode withSuccessBlock:^(RICart *cart) {
            [self.resumeView removeVoucher];
            self.cart = cart;
            
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
            
            NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
            [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
            [trackingDictionary setValue:cart.cartCount forKey:kRIEventQuantityKey];
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                      data:[trackingDictionary copy]];
            [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
            [self hideLoading];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:@selector(useCoupon) objects:nil];
            [self hideLoading];
        }];
    }
    else
    {
        [RICart addVoucherWithCode:voucherCode withSuccessBlock:^(RICart *cart) {
            self.cart = cart;
            
            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
            
            NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
            [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
            [trackingDictionary setValue:cart.cartCount forKey:kRIEventQuantityKey];
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                      data:[trackingDictionary copy]];
            [self hideLoading];
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:@selector(useCoupon) objects:nil];
            [self hideLoading];
            if (apiResponse != RIApiResponseNoInternetConnection) {
                [self.resumeView setCouponValid:NO];
            }
        }];
    }
}

- (void)removeCartItem:(RICartItem *)cartItem
{
    [self showLoading];
    [RICart removeProductWithSku:cartItem.simpleSku
                withSuccessBlock:^(RICart *cart) {
                    
                    NSMutableDictionary* skusFromTeaserInCart = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey]];
                    [skusFromTeaserInCart removeObjectForKey:cartItem.sku];
                    [[NSUserDefaults standardUserDefaults] setObject:[skusFromTeaserInCart copy] forKey:kSkusFromTeaserInCartKey];
                    
                    self.cart = cart;
                    
                    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                    
                    // Since we're sending the converted price, we have to send the currency as EUR.
                    // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
                    NSNumber *price = (VALID_NOTEMPTY(cartItem.specialPriceEuroConverted, NSNumber) && [cartItem.specialPriceEuroConverted floatValue] > 0.0f) ? cartItem.specialPriceEuroConverted : cartItem.priceEuroConverted;
                    [trackingDictionary setValue:price forKey:kRIEventPriceKey];
                    [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
                    
                    [trackingDictionary setValue:cartItem.sku forKey:kRIEventSkuKey];
                    [trackingDictionary setValue:[cart.cartCount stringValue] forKey:kRIEventQuantityKey];
                    [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
                    
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromCart]
                                                              data:[trackingDictionary copy]];
                    
                    NSMutableDictionary *tracking = [NSMutableDictionary new];
                    [tracking setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
                    [tracking setValue:cart.cartCount forKey:kRIEventQuantityKey];
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                              data:[tracking copy]];
                    
                    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                    
                    [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                    [self hideLoading];
                } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                    [self onErrorResponse:apiResponse messages:@[STRING_NO_NETWORK_DETAILS] showAsMessage:YES selector:@selector(removeCartItem:) objects:@[cartItem]];
                    [self hideLoading];
                }];
}

- (void)quantitySelection:(RICartItem *)cartItem
{
    self.currentItem = cartItem;
    [self setupPickerView];
}

- (void)setupPickerView
{
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:[self viewBounds]];
    [self.picker setDelegate:self];
    
    NSMutableArray *dataSource = [NSMutableArray new];
    
    if(VALID_NOTEMPTY([self.currentItem maxQuantity], NSNumber) && 0 < [[self.currentItem maxQuantity] integerValue])
    {
        NSInteger maxQuantity = [[self.currentItem maxQuantity] integerValue];
        if(VALID_NOTEMPTY([self.currentItem maxQuantity], NSNumber))
        {
            maxQuantity = [[self.currentItem maxQuantity] integerValue];
        }
        
        for (int i = 0; i < maxQuantity; i++)
        {
            [dataSource addObject:[NSString stringWithFormat:@"%d", (i + 1)]];
        }
    }
    
    NSString *selectedItem = [NSString stringWithFormat:@"%ld", [[self.currentItem quantity] longValue]];
    
    [self.picker setDataSourceArray:[dataSource copy]
                       previousText:selectedItem
                    leftButtonTitle:nil];
    
    CGFloat pickerViewHeight = [self viewBounds].size.height;
    CGFloat pickerViewWidth = [self viewBounds].size.width;
    [self.picker setFrame:CGRectMake(0.0f,
                                     pickerViewHeight,
                                     pickerViewWidth,
                                     pickerViewHeight)];
    [self.picker.layer setZPosition:10000];
    [self.view addSubview:self.picker];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.picker setFrame:CGRectMake(0.0f,
                                                          [self viewBounds].origin.y,
                                                          pickerViewWidth,
                                                          pickerViewHeight)];
                     }];
    
    
}

#pragma mark JAPickerDelegate
- (void)selectedRowNumber:(NSNumber *)selectedRowNumber
{
    [self selectedRow:selectedRowNumber.integerValue];
}

- (void)selectedRow:(NSInteger)selectedRow
{
    NSInteger newQuantity = selectedRow + 1;
    if(newQuantity != [[self.currentItem quantity] integerValue])
    {
        [self showLoading];
        
        NSNumber *event = [NSNumber numberWithInt:RIEventDecreaseQuantity];
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        
        // Since we're sending the converted price, we have to send the currency as EUR.
        // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
        NSNumber *price = (VALID_NOTEMPTY(self.currentItem.specialPriceEuroConverted, NSNumber) && [self.currentItem.specialPriceEuroConverted floatValue] > 0.0f) ? self.currentItem.specialPriceEuroConverted : self.currentItem.priceEuroConverted;
        [trackingDictionary setValue:price forKey:kRIEventPriceKey];
        [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
        
        [trackingDictionary setValue:self.currentItem.sku forKey:kRIEventSkuKey];
        NSString *discountPercentage = @"0";
        if(VALID_NOTEMPTY(self.currentItem.savingPercentage, NSNumber))
        {
            discountPercentage = [self.currentItem.savingPercentage stringValue];
        }
        [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
        [trackingDictionary setValue:@"Cart" forKey:kRIEventLocationKey];
        [trackingDictionary setValue:self.cart.cartValueEuroConverted  forKey:kRIEventTotalCartKey];
        
        NSInteger quantity = 0;
        if(newQuantity > [[self.currentItem quantity] integerValue])
        {
            quantity = newQuantity - [[self.currentItem quantity] integerValue];
            event = [NSNumber numberWithInt:RIEventIncreaseQuantity];
        }
        else
        {
            quantity = [[self.currentItem quantity] integerValue] - newQuantity;
        }
        [trackingDictionary setValue:[NSString stringWithFormat:@"%ld", (long)quantity] forKey:kRIEventQuantityKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:event
                                                  data:[trackingDictionary copy]];
        
        
        NSMutableDictionary *quantitiesToChange = [[NSMutableDictionary alloc] init];
        [quantitiesToChange setValue:[NSString stringWithFormat:@"%ld", (long)newQuantity] forKey:@"quantity"];
        [quantitiesToChange setValue:[self.currentItem simpleSku] forKey:@"sku"];
        
        [RICart changeQuantityInProducts:quantitiesToChange
                        withSuccessBlock:^(RICart *cart) {
                            self.cart = cart;
                            
                            NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
                            [trackingDictionary setValue:cart.cartValueEuroConverted forKey:kRIEventTotalCartKey];
                            [trackingDictionary setValue:cart.cartCount forKey:kRIEventQuantityKey];
                            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                                      data:[trackingDictionary copy]];
                            
                            NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                            [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                            
                            [self closePicker];
                            [self hideLoading];
                        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                            [self closePicker];
                            [self hideLoading];
                            Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
                            NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
                            if (networkStatus == NotReachable) {
                                [self onErrorResponse:RIApiResponseUnknownError messages:@[STRING_NO_NETWORK_DETAILS] showAsMessage:YES selector:@selector(selectedRowNumber:) objects:@[[NSNumber numberWithInteger:selectedRow]]];
                            }
                            else {
                                [self onErrorResponse:RIApiResponseUnknownError messages:errorMessages showAsMessage:YES selector:@selector(selectedRowNumber:) objects:@[[NSNumber numberWithInteger:selectedRow]]];
                            }
                        }];
    }
    else
    {
        [self closePicker];
    }
    
    CGRect frame = self.picker.frame;
    frame.origin.y = [self viewBounds].size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         self.picker = nil;
                     }];
}

- (void)closePicker
{
    CGRect frame = self.picker.frame;
    frame.origin.y = [self viewBounds].size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         self.picker = nil;
                     }];
}

#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numberOfRowsInComponent = 0;
    
    if(VALID_NOTEMPTY(self.currentItem, RICartItem))
    {
        numberOfRowsInComponent = [[self.currentItem maxQuantity] integerValue];
    }
    
    return numberOfRowsInComponent;
}

@end
