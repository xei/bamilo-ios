//
//  CartViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartViewController.h"
#import "DataManager.h"
#import "JAEmptyCartView.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import "RICartItem.h"
#import "CartTableViewCell.h"
#import "RecieptViewCartTableViewCell.h"
#import "JAAuthenticationViewController.h"
#import "NSString+Extensions.h"
#import "RIAddress.h"
#import "ViewControllerManager.h"
#import "AlertManager.h"
#import "CartEntitySummaryViewControl.h"
#import "EmptyCartViewController.h"


@interface CartViewController() <CartTableViewCellDelegate>
//@property (nonatomic, strong) JAEmptyCartView *emptyCartView;
@property (nonatomic, strong) RICartItem *currentItem;
@property (nonatomic, weak) IBOutlet UIView *contentWrapper;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *cartSummeryView;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
@property (weak, nonatomic) IBOutlet UILabel *totalDiscountedPrice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *costSummeryContainerTopToWholeCostTopConstraint;
@property (weak, nonatomic) IBOutlet CartEntitySummaryViewControl *summeryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *summeryViewToBottomConstraint;
@property (weak, nonatomic) EmptyCartViewController *emptyCartViewController;
@property (weak, nonatomic) IBOutlet UIView *emptyCartViewContainer;
@end

@implementation CartViewController

- (void)setCart:(RICart *)cart {
    _cart = cart;
    
    if (cart.cartEntity.cartItems.count) {
        [self setCartEmpty:NO];
    } else {
        [self setCartEmpty:YES];
    }
    self.totalPrice.text = cart.cartEntity.cartUnreducedValueFormatted;
    self.totalDiscountedPrice.text = cart.cartEntity.discountValueFormated;
    [self.summeryView updateWithModel:self.cart.cartEntity];
}

- (void)setCartEmpty:(BOOL)empty {
    [self.emptyCartViewContainer setHidden:!empty];
    if (empty) {
        [self.emptyCartViewController getSuggestions];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.title = STRING_CART;
    self.navBarLayout.showBackButton = NO;
    self.navBarLayout.showCartButton = NO;
    self.tabBarIsVisible = YES;
    [self.view setBackgroundColor:JAWhiteColor];
    
    //TableView registerations
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName: [CartTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[CartTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName: [RecieptViewCartTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[RecieptViewCartTableViewCell nibName]];
    self.summeryView.delegate = self;
}

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
}

- (void)removeCartItem:(RICartItem *)cartItem {
    [self showLoading];
    [RICart removeProductWithSku:cartItem.simpleSku withSuccessBlock:^(RICart *cart) {
        
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        [self onErrorResponse:apiResponse messages:@[STRING_NO_NETWORK_DETAILS] showAsMessage:YES selector:@selector(removeCartItem:) objects:@[cartItem]];
        [self hideLoading];
    }];
}

#pragma mark - tableView dataSource & delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.cart.cartEntity.cartItems.count) {
        RecieptViewCartTableViewCell *receiptView = [tableView dequeueReusableCellWithIdentifier:[RecieptViewCartTableViewCell nibName] forIndexPath:indexPath];
        [receiptView updateWithModel:self.cart.cartEntity];
        return receiptView;
    }
    
    CartTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[CartTableViewCell nibName] forIndexPath:indexPath];
    cell.cartItem = self.cart.cartEntity.cartItems[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cart.cartEntity.cartItems.count + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.cart.cartEntity.cartItems.count) {
        return [RecieptViewCartTableViewCell cellHeightByModel:self.cart.cartEntity];
    }
    return UITableViewAutomaticDimension;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showDetailSummeryView:NO];
    
    
    // ------ if we are approching the end of tableview ------
    CGPoint offset = self.tableView.contentOffset;
    CGRect bounds = self.tableView.bounds;
    CGSize size = self.tableView.contentSize;
    UIEdgeInsets inset = self.tableView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    float reload_distance = 30;
    if(y + reload_distance > h) {
        [self showSummeryView:NO];
    } else {
        [self showSummeryView:YES];
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

#pragma mark - CartTableViewCellDelegate

- (void)wantsToLikeCartItem:(RICartItem *)cartItem byCell:(id)cartCell {
    
}

- (void)wantToIncreaseCartItemCountMoreThanMax:(RICartItem *)cartItem byCell:(id)cartCell {
    [self showMessage:[[NSString stringWithFormat:@"سقف خرید %@ عدد می باشد", cartItem.maxQuantity] numbersToPersian] success:NO];
}

- (void)wantsToRemoveCartItem:(RICartItem *)cartItem byCell:(id)cartCell {
    [[AlertManager sharedInstance] confirmAlert:@"حذف کالا" text:@"از حذف کالا از سبد خریدتان اطمینان دارید؟" confirm:@"بله" cancel:@"خیر" completion:^(BOOL OK) {
        if(OK) [self removeCartItem:cartItem];
    }];
}

#pragma mark - CartEntitySummaryViewControlDelegate
- (void)cartEntityTapped:(id)cartEntityControl {
    if (self.costSummeryContainerTopToWholeCostTopConstraint.constant == 0) {
        [self showDetailSummeryView:YES];
    } else {
        [self showDetailSummeryView:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DataManager sharedInstance] getUserCart:self completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self publishScreenLoadTime];
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    RICart *cart = (RICart *)data;
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo: @{kUpdateCartNotificationValue: cart}];
    self.cart = cart;
    [self.tableView reloadData];
    [self checkIfSummeryViewsMustBeVisibleOrNot];
}

#pragma mark - PerformanceTrackerProtocol
- (NSString *)getPerformanceTrackerScreenName {
    return @"Cart";
}

- (NSString *)getPerformanceTrackerLabel {
     NSMutableDictionary* skusFromTeaserInCart = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey]];
    return [NSString stringWithFormat:@"%@", [skusFromTeaserInCart allKeys]];
}

#pragma mark - DataTrackerProtocol
-(NSString *)getDataTrackerAlias {
    return @"CART";
}

#pragma mark - Helpers
- (void)checkIfSummeryViewsMustBeVisibleOrNot {
    [self.tableView layoutIfNeeded];
    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        [self showSummeryView:NO];
        [self showDetailSummeryView:NO];
    } else {
        [self showSummeryView:YES];
        [self showDetailSummeryView:YES];
    }
}

- (void)showSummeryView:(Boolean)show {
    if (show) {
        if (self.summeryViewToBottomConstraint.constant != 0) {
            [self changeTheSummeryBottomConstraintByAnimationTo:0];
        }
        return;
    }
    if (self.summeryViewToBottomConstraint.constant != -45) {
        [self changeTheSummeryBottomConstraintByAnimationTo:-45];
    }
}

- (void)showDetailSummeryView:(Boolean)show {
    if (show){
        if (self.costSummeryContainerTopToWholeCostTopConstraint.constant != 75) {
            [self changeTheSummeryTopConstraintByAnimationTo:75];
            return;
        }
    }
    if (self.costSummeryContainerTopToWholeCostTopConstraint.constant != 0) {
        [self changeTheSummeryTopConstraintByAnimationTo:0];
    }
}

- (void)changeTheSummeryTopConstraintByAnimationTo:(CGFloat)constant {
    [UIView animateWithDuration:0.15 animations:^{
        self.costSummeryContainerTopToWholeCostTopConstraint.constant = constant;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)changeTheSummeryBottomConstraintByAnimationTo:(CGFloat)constant {
    [UIView animateWithDuration:0.15 animations:^{
        self.summeryViewToBottomConstraint.constant = constant;
        [self.view layoutIfNeeded];
    } completion:nil];
}


#pragma mark - EmarsysPredictProtocol
- (NSArray<EMRecommendationRequest *> *)getRecommendations {
    
    EMRecommendationRequest *recommend = [EMRecommendationRequest requestWithLogic:@"CART"];
    recommend.limit = 15;
    recommend.completionHandler = ^(EMRecommendationResult *_Nonnull result) {
        
    };
    return @[recommend];
}


#pragma segue preparation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"embedEmptyCartViewController"]) {
        self.emptyCartViewController = (EmptyCartViewController *) [segue destinationViewController];
    }
}
@end
