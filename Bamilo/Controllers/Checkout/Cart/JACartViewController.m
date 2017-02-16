//
//  JACartViewController.m
//  Jumia
//
//  Created by Jose Mota on 11/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JACartViewController.h"
#import "JAEmptyCartView.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import "RICartItem.h"
#import "CartTableViewCell.h"
#import "JAAuthenticationViewController.h"
#import "NSString+Extensions.h"
#import "RIAddress.h"
//#import "JAPicker.h"
#import "ViewControllerManager.h"
#import "CartEntitySummeryViewControl.h"
//#import "JAPicker.h"
#import "ViewControllerManager.h"
#import "CartEntitySummeryViewControl.h"

@interface JACartViewController ()  <CartTableViewCellDelegate>

@property (nonatomic, strong) JAEmptyCartView *emptyCartView;
@property (nonatomic, strong) RICartItem *currentItem;
@property (nonatomic, weak) IBOutlet UIView *contentWrapper;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *cartSummeryView;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
@property (weak, nonatomic) IBOutlet UILabel *totalDiscountedPrice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *costSummeryContainerTopToWholeCostTopConstraint;
@property (weak, nonatomic) IBOutlet CartEntitySummeryViewControl *summeryView;

@end

@implementation JACartViewController

- (JAEmptyCartView *)emptyCartView {
    if (!VALID(_emptyCartView, JAEmptyCartView)) {
        _emptyCartView = [[JAEmptyCartView alloc] initWithFrame:self.viewBounds];
        [_emptyCartView setBackgroundColor:JAWhiteColor];
        [_emptyCartView addHomeScreenTarget:self action:@selector(goToHomeScreen)];
        [self.view addSubview:_emptyCartView];
    }
    return _emptyCartView;
}

- (void)setCart:(RICart *)cart {
    _cart = cart;
    
    if (cart.cartEntity.cartItems.count) {
        [self setCartEmpty:NO];
    } else {
        [self setCartEmpty:YES];
    }
    
    self.totalPrice.text = cart.cartEntity.cartUnreducedValueFormatted;
//    self.totalPaymentPrice.text = cart.cartEntity.cartValueFormatted;
    self.totalDiscountedPrice.text = cart.cartEntity.discountedValueFormated;
//    self.totalPaymentTitleLabel.text = [[NSString stringWithFormat:@"جمع نهایی‌(%d کالا)", cart.cartEntity.cartCount.intValue] numbersToPersian];
    
    [self.summeryView updateWithModel:self.cart.cartEntity];
}

- (void)setCartEmpty:(BOOL)empty {
    [self.emptyCartView setHidden:!empty];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.A4SViewControllerAlias = @"CART";
    self.screenName = @"Cart";
    self.navBarLayout.title = STRING_CART;
    self.navBarLayout.showBackButton = NO;
    self.navBarLayout.showCartButton = NO;
    self.tabBarIsVisible = YES;
    [self.view setBackgroundColor:JAWhiteColor];
    
    
    //TableView registerations
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName: [CartTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[CartTableViewCell nibName]];
    
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadingCart];
    if (self.firstLoading) {
        NSMutableDictionary* skusFromTeaserInCart = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey]];
        NSNumber *timeInMillis =  [NSNumber numberWithInt:(int)([self.startLoadingTime timeIntervalSinceNow]*-1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName label:[NSString stringWithFormat:@"%@", [skusFromTeaserInCart allKeys]]];
        self.firstLoading = NO;
    }
}

- (void)loadingCart {
    [self showLoading];
    [RICart getCartWithSuccessBlock:^(RICart *cartData) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo: @{kUpdateCartNotificationValue: cartData}];
        self.cart = cartData;
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadingCart) objects:nil];
        [self hideLoading];
    }];
}*/

- (void)viewWillLayoutSubviews {

    [super viewWillLayoutSubviews];
    self.contentWrapper.frame = self.viewBounds;
}

- (void)goToHomeScreen {
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"ContinueShopping" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];

    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutContinueShopping] data:[trackingDictionary copy]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}

- (IBAction)proceedToCheckout:(id)sender {
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"Started" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:[NSNumber numberWithInteger:[[self.cart.cartEntity cartItems] count]] forKey:kRIEventQuantityKey];
    [trackingDictionary setValue:[self.cart.cartEntity cartValueEuroConverted] forKey:kRIEventTotalCartKey];
    NSMutableString* attributeSetID = [NSMutableString new];
    for (RICartItem* pd in [self.cart.cartEntity cartItems]) {
        [attributeSetID appendFormat:@"%@;",[pd attributeSetID]];
    }
    [trackingDictionary setValue:[attributeSetID copy] forKey:kRIEventAttributeSetIDCartKey];
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutStart] data:[trackingDictionary copy]];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CheckoutAddress"];
    
    [[ViewControllerManager centerViewController] requestNavigateToNib:@"CheckoutAddressViewController" ofStoryboard:@"Checkout" useCache:NO args:nil];
    
    /*
    [JAAuthenticationViewController goToCheckoutWithBlock:^{
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"Started" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
        [trackingDictionary setValue:[NSNumber numberWithInteger:[[self.cart.cartEntity cartItems] count]] forKey:kRIEventQuantityKey];
        [trackingDictionary setValue:[self.cart.cartEntity cartValueEuroConverted] forKey:kRIEventTotalCartKey];
        NSMutableString* attributeSetID = [NSMutableString new];
        for (RICartItem* pd in [self.cart.cartEntity cartItems]) {
            [attributeSetID appendFormat:@"%@;",[pd attributeSetID]];
        }
        [trackingDictionary setValue:[attributeSetID copy] forKey:kRIEventAttributeSetIDCartKey];
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutStart] data:[trackingDictionary copy]];
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification object:nil userInfo:nil];
        [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CheckoutAddress"];
        
        [RIAddress getCustomerAddressListWithSuccessBlock:^(id adressList) {
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"Started" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Checkout" forKey:kRIEventCategoryKey];
            
            [trackingDictionary setValue:[NSNumber numberWithInteger:[[self.cart.cartEntity cartItems] count]] forKey:kRIEventQuantityKey];
            [trackingDictionary setValue:[self.cart.cartEntity cartValueEuroConverted] forKey:kRIEventTotalCartKey];
            
            NSMutableString* attributeSetID = [NSMutableString new];
            for (RICartItem* pd in [self.cart.cartEntity cartItems]) {
                [attributeSetID appendFormat:@"%@;",[pd attributeSetID]];
            }
            [trackingDictionary setValue:[attributeSetID copy] forKey:kRIEventAttributeSetIDCartKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutStart]
                                                      data:[trackingDictionary copy]];
            
            [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
            [self hideLoading];
            
         
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification object:nil userInfo:nil];
            [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CheckoutAddress"];
         
        } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"NativeCheckoutError" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutError] data:[trackingDictionary copy]];
            
            [self hideLoading];
            
            [self onErrorResponse:apiResponse messages:errorMessages showAsMessage:YES selector:nil objects:nil];
        }];
    }];*/
}

- (void) proceedToCall {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"تماس با تیم خدمات مشتریان بامیلو" delegate:nil cancelButtonTitle:@"لغو" otherButtonTitles:@"تایید", nil];
    alert.delegate = self;
    [alert show];
}

- (void)removeCartItem:(RICartItem *)cartItem {
    [self showLoading];
    [RICart removeProductWithSku:cartItem.simpleSku
                withSuccessBlock:^(RICart *cart) {
                    
                    NSMutableDictionary* skusFromTeaserInCart = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey]];
                    [skusFromTeaserInCart removeObjectForKey:cartItem.sku];
                    [[NSUserDefaults standardUserDefaults] setObject:[skusFromTeaserInCart copy] forKey:kSkusFromTeaserInCartKey];
                    
                    
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
                    [trackingDictionary setValue:[cart.cartEntity.cartCount stringValue] forKey:kRIEventQuantityKey];
                    [trackingDictionary setValue:cart.cartEntity.cartValueEuroConverted forKey:kRIEventTotalCartKey];
                    
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRemoveFromCart]
                                                              data:[trackingDictionary copy]];
                    
                    NSMutableDictionary *tracking = [NSMutableDictionary new];
                    [tracking setValue:cart.cartEntity.cartValueEuroConverted forKey:kRIEventTotalCartKey];
                    [tracking setValue:cart.cartEntity.cartCount forKey:kRIEventQuantityKey];
                    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart]
                                                              data:[tracking copy]];
                    
                    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                    
                    [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                    [self hideLoading];
                    
                    self.cart = cart;
                    [self.tableView reloadData];
                    
                } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                    [self onErrorResponse:apiResponse messages:@[STRING_NO_NETWORK_DETAILS] showAsMessage:YES selector:@selector(removeCartItem:) objects:@[cartItem]];
                    [self hideLoading];
                }];
}

- (IBAction)totalPaymentViewTapped :(id)sender{
    if (self.costSummeryContainerTopToWholeCostTopConstraint.constant == 0) {
        [self changeTheSummeryTopConstraintByAnimationTo:75];
    } else {
        [self changeTheSummeryTopConstraintByAnimationTo:0];
    }
}

- (void) changeTheSummeryTopConstraintByAnimationTo:(CGFloat)constant {
    [UIView animateWithDuration:0.15 animations:^{
        self.costSummeryContainerTopToWholeCostTopConstraint.constant = constant;
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma mark - tableView dataSource & delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[CartTableViewCell nibName] forIndexPath:indexPath];
    cell.cartItem = self.cart.cartEntity.cartItems[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cart.cartEntity.cartItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.costSummeryContainerTopToWholeCostTopConstraint.constant == 75) {
        [self changeTheSummeryTopConstraintByAnimationTo:0];
    }
}

#pragma CartTableViewCell Delegate

- (void)quantityWillChangeTo:(int)newValue withCell:(id)cartCell {
    [self showLoading];
}

- (void)quantityHasBeenChangedTo:(int)newValue withNewCart:(RICart *)cart withCell:(id)cartCell {
    [self hideLoading];
    
    NSMutableDictionary *trackingDictionary = [NSMutableDictionary new];
    [trackingDictionary setValue:cart.cartEntity.cartValueEuroConverted forKey:kRIEventTotalCartKey];
    [trackingDictionary setValue:cart.cartEntity.cartCount forKey:kRIEventQuantityKey];
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCart] data:[trackingDictionary copy]];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
    
    self.cart = cart;
    [self.tableView reloadData];
}

- (void)quantityHasBeenChangedTo:(int)newValue withErrorMessages:(NSArray *)errorMsgs withCell:(id)cartCell {
    [self hideLoading];
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self onErrorResponse:RIApiResponseUnknownError messages:@[STRING_NO_NETWORK_DETAILS] showAsMessage:YES selector:nil objects:nil];
    } else {
        [self onErrorResponse:RIApiResponseUnknownError messages:errorMsgs showAsMessage:YES selector:nil objects:nil];
    }
}

- (void)wantsToRemoveCartItem:(RICartItem *)cartItem byCell:(id)cartCell {
    [self removeCartItem:cartItem];
}

@end
