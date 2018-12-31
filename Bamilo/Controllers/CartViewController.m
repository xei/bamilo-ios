//
//  CartViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartViewController.h"
#import "JAUtils.h"
#import "RICartItem.h"
#import "CartTableViewCell.h"
#import "RecieptViewCartTableViewCell.h"
#import "NSString+Extensions.h"
#import "ViewControllerManager.h"
#import "AlertManager.h"
#import "CartEntitySummaryViewControl.h"
#import "EmptyViewController.h"
#import "LoadingManager.h"
#import "Bamilo-Swift.h"
#import "OrangeButton.h"


@interface CartViewController() <CartTableViewCellDelegate>
@property (nonatomic, strong) RICartItem *currentItem;
@property (nonatomic, weak) IBOutlet UIView *contentWrapper;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *cartSummeryView;
@property (weak, nonatomic) IBOutlet UILabel *totalPrice;
@property (weak, nonatomic) IBOutlet UILabel *totalDiscountedPrice;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *costSummeryContainerBottomToWholeCostBottomConstraint;
@property (weak, nonatomic) IBOutlet CartEntitySummaryViewControl *summeryView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *summeryViewToBottomConstraint;
@property (weak, nonatomic) IBOutlet OrangeButton *submitButton;
@property (weak, nonatomic) EmptyViewController *emptyCartViewController;
@property (weak, nonatomic) IBOutlet UIView *emptyCartViewContainer;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

@implementation CartViewController

- (void)setCart:(RICart *)cart {
    _cart = cart;
    if (!_cart) return;
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
    if (empty && [MainTabBarViewController topViewController] == self) {
        [self.emptyCartViewController getSuggestions];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[Theme color:kColorVeryLightGray]];
    [self.contentWrapper setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    
    //TableView registerations
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName: [CartTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[CartTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName: [RecieptViewCartTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[RecieptViewCartTableViewCell nibName]];
    self.summeryView.delegate = self;
    self.submitButton.cornerRadius = 48 / 2;
    self.submitButton.clipsToBounds = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoggedOut) name:kUserLoggedOutNotification object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)goToHomeScreen {
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}

- (IBAction)proceedToCheckout:(id)sender {
    [[MainTabBarViewController topNavigationController] requestNavigateToNib:@"CheckoutAddressViewController" ofStoryboard:@"Checkout" useCache:NO args:nil];
}

- (void)removeCartItem:(RICartItem *)cartItem {
    [LoadingManager showLoading];
    [RICart removeProductWithSku:cartItem.simpleSku withSuccessBlock:^(RICart *cart) {
        
        //remove the existing purchase behaviour with sku
        [[PurchaseBehaviourRecorder sharedInstance] deleteBehaviourWithSku:cartItem.sku];
        
        Product *product = [Product new];
        [product setPriceWithPrice: cartItem.price];
        product.sku = cartItem.sku;
        [TrackerManager postEventWithSelector:[EventSelectors removeFromCartEventSelector] attributes:[EventAttributes removeFromCardWithProduct:product success:YES]];
        
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
        self.cart = cart;
        dispatch_async(dispatch_get_main_queue(), ^{
            [LoadingManager hideLoading];
            [self.tableView reloadData];
            [self checkIfSummeryViewsMustBeVisibleOrNot];
        });
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        [LoadingManager hideLoading];
        if (![Utility handleErrorMessagesWithError:errorMessages viewController:self]) {
            [self showNotificationBarMessage:STRING_CONNECTION_SERVER_ERROR_MESSAGES isSuccess:NO];
        }
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
    if (indexPath.row < self.cart.cartEntity.cartItems.count) {
        cell.cartItem = self.cart.cartEntity.cartItems[indexPath.row];
    }
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 200;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cart.cartEntity.cartItems.count > 0 ? self.cart.cartEntity.cartItems.count + 1 : 0;
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
    [LoadingManager showLoading];
}

- (void)quantityHasBeenChangedTo:(int)newValue withNewCart:(RICart *)cart withCell:(id)cartCell {
    [LoadingManager hideLoading];
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
    
    self.cart = cart;
    [self.tableView reloadData];
}

- (void)quantityHasBeenChangedTo:(int)newValue withErrorMessages:(NSArray *)errorMsgs withCell:(id)cartCell {
    [LoadingManager hideLoading];
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        [self showNotificationBarMessage:STRING_NO_NETWORK_DETAILS isSuccess:NO];
    } else {
    }
}

#pragma mark - CartTableViewCellDelegate
- (void)wantsToLikeCartItem:(RICartItem *)cartItem byCell:(id)cartCell {
}

- (void)wantToIncreaseCartItemCountMoreThanMax:(RICartItem *)cartItem byCell:(id)cartCell {
    [self showNotificationBarMessage:[[NSString stringWithFormat:@"سقف خرید %@ عدد می باشد", cartItem.maxQuantity] numbersToPersian] isSuccess:NO];
}

- (void)wantsToRemoveCartItem:(RICartItem *)cartItem byCell:(id)cartCell {
    [[AlertManager sharedInstance] confirmAlert:@"حذف کالا" text:@"از حذف کالا از سبد خریدتان اطمینان دارید؟" confirm:@"بله" cancel:@"خیر" completion:^(BOOL OK) {
        if(OK) [self removeCartItem:cartItem];
    }];
}

#pragma mark - CartEntitySummaryViewControlDelegate
- (void)cartEntityTapped:(id)cartEntityControl {
    if (self.costSummeryContainerBottomToWholeCostBottomConstraint.constant == 0) {
        [self showDetailSummeryView:YES];
    } else { 
        [self showDetailSummeryView:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getContent:nil];
}

- (void)getContent:(void(^)(BOOL))callBack {
    [self clearContent];
    [self.activityIndicator startAnimating];
    [self recordStartLoadTime];
    [DataAggregator getUserCart:self completion:^(id data, NSError *error) {
        [self.activityIndicator stopAnimating];
        if(error != nil) {
            [Utility handleErrorMessagesWithError:error viewController:self];
            [self errorHandler:error forRequestID:0];
            if (callBack) callBack(NO);
            return;
        }
        [self bind:data forRequestId:0];
        [self publishScreenLoadTimeWithName:[self getScreenName] withLabel:@""];
        if (callBack) callBack(YES);
    }];
}

- (void) clearContent {
    self.cart = nil;
    [self.submitButton setHidden:YES];
    [self.summeryView setHidden:YES];
    [self.cartSummeryView setHidden:YES];
    [self.emptyCartViewContainer setHidden:YES];
    [self.tableView reloadData];
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    if (rid == 0 && [data isKindOfClass:[RICart class]]) {
        [self.submitButton setHidden:NO];
        [self.summeryView setHidden:NO];
        [self.cartSummeryView setHidden:NO];
        
        self.cart = (RICart *)data;
        [self.tableView reloadData];
        [self checkIfSummeryViewsMustBeVisibleOrNot];

        //When cart is ready & not empty
        if (self.cart.cartEntity.cartCount.integerValue) {
//            [EmarsysPredictManager sendTransactionsOf:self];
            [TrackerManager postEventWithSelector:[EventSelectors viewCartEventSelector] attributes:[EventAttributes viewCartWithCart:self.cart success:YES]];
        }
        
        //track Ecommerce event
        [[GoogleAnalyticsTracker sharedTracker] trackEcommerceCartInCheckoutWithCart:self.cart step:@(1) options:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo: @{kUpdateCartNotificationValue: self.cart}];
    }
}

- (void)errorHandler:(NSError *)error forRequestID:(int)rid {
    if (![Utility handleErrorMessagesWithError:error viewController:self]) {
        [self handleGenericErrorCodesWithErrorControlView:(int)error.code forRequestID:rid];
    }
}

- (void)retryAction:(RetryHandler)callBack forRequestId:(int)rid {
    [self getContent:^(BOOL success) {
        callBack(success);
    }];
}

- (NSString *)getPerformanceTrackerLabel {
     NSMutableDictionary* skusFromTeaserInCart = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey]];
    return [NSString stringWithFormat:@"%@", [skusFromTeaserInCart allKeys]];
}

#pragma mark - DataTrackerProtocol
-(NSString *)getScreenName {
    return @"CART";
}

#pragma mark - Helpers
- (void)checkIfSummeryViewsMustBeVisibleOrNot {
    [self.tableView layoutIfNeeded];
    if (self.tableView.contentSize.height < self.tableView.frame.size.height) {
        [self showSummeryView:NO];
        [self showDetailSummeryView:NO];
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 58, 0);
    } else {
        [self showSummeryView:YES];
        [self showDetailSummeryView:YES];
        self.tableView.contentInset = UIEdgeInsetsMake(45, 0, 58, 0);
    }
}

- (void)showSummeryView:(Boolean)show {
    if (show) {
        if (self.summeryViewToBottomConstraint.constant != -45) {
            [self changeTheSummeryBottomConstraintByAnimationTo:-45];
        }
        return;
    }
    if (self.summeryViewToBottomConstraint.constant != 0) {
        [self changeTheSummeryBottomConstraintByAnimationTo:0];
    }
}

- (void)showDetailSummeryView:(Boolean)show {
    if (self.costSummeryContainerBottomToWholeCostBottomConstraint.constant != (show ? 75 : 0)) {
        [self changeTheSummeryTopConstraintByAnimationTo:(show ? 75 : 0)];
    }
}

- (void)changeTheSummeryTopConstraintByAnimationTo:(CGFloat)constant {
    [UIView animateWithDuration:0.15 animations:^{
        self.costSummeryContainerBottomToWholeCostBottomConstraint.constant = constant;
        [self.view layoutIfNeeded];
    } completion:nil];
}

- (void)changeTheSummeryBottomConstraintByAnimationTo:(CGFloat)constant {
    [UIView animateWithDuration:0.15 animations:^{
        self.summeryViewToBottomConstraint.constant = constant;
        [self.view layoutIfNeeded];
    } completion:nil];
}

#pragma segue preparation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString * segueName = segue.identifier;
    if ([segueName isEqualToString: @"embedEmptyViewController"]) {
        self.emptyCartViewController = (EmptyViewController *) [segue destinationViewController];
        self.emptyCartViewController.recommendationLogic = @"PERSONAL";
        self.emptyCartViewController.parentScreenName = @"EmptyCart";
        [self.emptyCartViewController updateTitle:STRING_NO_ITEMS_IN_CART];
        [self.emptyCartViewController updateImage:[UIImage imageNamed:@"img_emptyCart"]];
    }
}

- (BOOL)isPreventSendTransactionInViewWillAppear {
    return YES;
}


- (void)didLoggedOut {
    self.cart = nil;
}

#pragma mark - navigationBarProtocol

- (NSString *)navBarTitleString {
    return STRING_CART;
}

@end
