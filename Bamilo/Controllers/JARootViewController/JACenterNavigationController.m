//
//  JACenterNavigationController.m
//  Jumia
//
//  Created by Miguel Chaves on 31/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACenterNavigationController.h"
#import "AuthenticationContainerViewController.h"
#import "JARecentlyViewedViewController.h"
#import "JAExternalPaymentsViewController.h"
#import "RIProduct.h"
#import "RISeller.h"
#import "JANavigationBarLayout.h"
#import "RICustomer.h"
#import "JACampaignsViewController.h"
#import "JASizeGuideViewController.h"
#import "JAOtherOffersViewController.h"
#import "JAShopWebViewController.h"
#import "RICountry.h"

#import "JAStepByStepTabViewController.h"
#import "JACheckoutStepByStepModel.h"
#import "JAReturnStepByStepModel.h"
#import "RICategory.h"

#import "OrderListViewController.h"
//###################################################
#import "ViewControllerManager.h"
#import "ContactUsViewController.h"
#import "CheckoutAddressViewController.h"
#import "CartViewController.h"
#import "AuthenticationContainerViewController.h"
#import "ProtectedViewControllerProtocol.h"
#import "ArgsReceiverProtocol.h"
#import "SuccessPaymentViewController.h"
#import "Bamilo-Swift.h"

@interface JACenterNavigationController ()

@property (assign, nonatomic) BOOL neeedsExternalPaymentMethod;
@property (strong, nonatomic) UIStoryboard *mainStoryboard;

//@property (nonatomic, strong) JASearchView *searchView;

@property (nonatomic, strong) JAStepByStepTabViewController *checkoutStepByStepViewController;
@property (nonatomic, strong) JAStepByStepTabViewController *returnsStepByStepViewController;

@end

@implementation JACenterNavigationController

- (JAStepByStepTabViewController *)checkoutStepByStepViewController {
    if (!_checkoutStepByStepViewController) {
        _checkoutStepByStepViewController = [self getNewCheckoutStepByStepViewController];
    }
    return _checkoutStepByStepViewController;
}

- (JAStepByStepTabViewController *)getNewCheckoutStepByStepViewController {
    JAStepByStepTabViewController *checkoutStepByStepViewController = [JAStepByStepTabViewController new];
    return checkoutStepByStepViewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    self.neeedsExternalPaymentMethod = NO;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)registerObservingOnNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHomeScreen:) name:kShowHomeScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSavedListViewController:) name:kShowSavedListScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRecentlyViewedController) name:kShowRecentlyViewedScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMyAccountController) name:kShowMyAccountScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserData:) name:kShowUserDataScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMyOrdersViewController:) name:kShowMyOrdersScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationScreen:) name:kShowAuthenticationScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSignUpScreen:) name:kShowSignUpScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCheckoutExternalPaymentsScreen:) name:kShowCheckoutExternalPaymentsScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectLeafCategoryInMenu:) name:kMenuDidSelectLeafCategoryNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openCart:) name:kOpenCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTeaserWithCatalogUrl:) name:kDidSelectTeaserWithCatalogUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectCampaign:) name:kDidSelectCampaignNofication object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTeaserWithPDVUrl:) name:kDidSelectTeaserWithPDVUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTeaserWithShopUrl:) name:kDidSelectTeaserWithShopUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCurrentScreenNotificaion:) name:kCloseCurrentScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeTopTwoScreensNotificaion:) name:kCloseTopTwoScreensNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOtherOffers:) name:kOpenOtherOffers object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkRedirectInfo) name:kCheckRedirectInfoNotification object:nil];
}

- (void)removeObservingNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowHomeScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowSavedListScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowRecentlyViewedScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowMyAccountScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowUserDataScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowMyOrdersScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowAuthenticationScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowSignUpScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowCheckoutExternalPaymentsScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMenuDidSelectLeafCategoryNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidSelectTeaserWithCatalogUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidSelectCampaignNofication object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidSelectTeaserWithPDVUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidSelectTeaserWithShopUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCloseCurrentScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCloseTopTwoScreensNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenOtherOffers object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCheckRedirectInfoNotification object:nil];
    
}

- (void)openTargetString:(NSString *)targetString purchaseInfo:(NSString *)purchaseInfo currentScreenName: (NSString *)screenName {
    [self openScreenTarget:[RITarget parseTarget:targetString] purchaseInfo:purchaseInfo currentScreenName: (NSString *)screenName];
}

- (BOOL)openScreenTarget:(RITarget *)target purchaseInfo:(NSString *)purchaseInfo currentScreenName: (NSString *)screenName {
    if ([[self topViewController] isKindOfClass:[JABaseViewController class]] && [[(JABaseViewController *)[self topViewController] targetString] isEqualToString:target.targetString]) {
        return NO;
    }
    switch (target.targetType) {
        case PRODUCT_DETAIL: {
            ProductDetailViewController *pdvViewCtrl = (ProductDetailViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"ProductDetailViewController"];
            pdvViewCtrl.purchaseTrackingInfo = purchaseInfo;
            pdvViewCtrl.productSku = target.node;
            pdvViewCtrl.hidesBottomBarWhenPushed = YES;
            [self pushViewController:pdvViewCtrl animated:true];
            return YES;
        }
        case CATALOG_HASH:
        case CATALOG_BRAND:
        case CATALOG_CATEGORY:
        case CATALOG_SEARCH:
        case CATALOG_SELLER:{
            CatalogViewController *viewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"catalogViewController"];;
            viewController.searchTarget = target;
            viewController.purchaseTrackingInfo = purchaseInfo;
            viewController.initiatorScreenName = screenName;
            viewController.hidesBottomBarWhenPushed = NO;
            [self pushViewController:viewController animated:true];
            return YES;
        }
        case STATIC_PAGE:
        case SHOP_IN_SHOP: {
            JAShopWebViewController* viewController = [[JAShopWebViewController alloc] init];
            viewController.purchaseTrackingInfo = purchaseInfo;
            [self loadScreenTarget:target forBaseViewController:viewController];
            [self pushViewController:viewController animated: true];
            return YES;
        }
        case EXTERNAL_LINK: {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[RITarget getURLStringforTargetString: target.targetString]]];
            return YES;
        }
        case CAMPAIGN: {
            JACampaignsViewController *viewController = [JACampaignsViewController new];
            viewController.purchaseTrackingInfo = purchaseInfo;
            [self loadScreenTarget:target forBaseViewController:viewController];
            [self pushViewController:viewController animated:true];
            return YES;
        }
            
        default:
            if (target.node &&
                ([target.node containsString:@"itms-apps://"] || [target.node containsString:@"https://app."])) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:target.node]];
                return YES;
            }
            return NO;
    }
}

- (void)loadScreenTarget:(RITarget *)screenTarget forBaseViewController:(JABaseViewController *)viewController {
    [viewController setTargetString: screenTarget.targetString];
}

#pragma mark Home Screen
- (void)showHomeScreen:(NSNotification*)notification {
    [MainTabBarViewController showHome];
}

- (void)showRootViewController {
    [self popToRootViewControllerAnimated:YES];
}

- (void)changeCenterPanel:(NSString *)newScreenName notification:(NSNotification *)notification {
    if ([newScreenName isEqualToString:STRING_HOME]) {
        [self showHomeScreen:nil];
    }
    else if ([newScreenName isEqualToString:STRING_LOGIN]) {
        [self showSignInScreen:nil];
    } else if ([newScreenName isEqualToString:STRING_RECENTLY_VIEWED]) {
        [self showRecentlyViewedController];
    } else if([newScreenName isEqualToString:STRING_MY_ACCOUNT]) {
        [self showMyAccountController];
    } else if ([newScreenName isEqualToString:STRING_MY_ORDERS]) {
        [self showMyOrdersViewController:nil];
    } else if ([newScreenName isEqualToString:STRING_USER_DATA]) {
        [self showUserData:nil];
    }
}

#pragma mark Favorites Screen
- (void)showSavedListViewController:(NSNotification*)notification {
    [MainTabBarViewController showWishList];
}

#pragma mark Sign In Screen
- (void)showAuthenticationScreen:(NSNotification *)notification {
    if ([self showAndCheckIfUserAlreadyLoggedIn]) {
        return;
    }
    
    AuthenticationContainerViewController *authenticationViewController = (AuthenticationContainerViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"Authentication" nibName:@"AuthenticationContainerViewController" resetCache:YES];
    
    authenticationViewController.fromSideMenu = NO;
    if (VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"from_side_menu"], NSNumber)) {
        NSNumber* fromSide = [notification.userInfo objectForKey:@"from_side_menu"];
        authenticationViewController.fromSideMenu = [fromSide boolValue];
    }
    BOOL animated = YES;
    if (VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"tabbar_is_visible"], NSNumber)) {
        [self popToRootViewControllerAnimated:NO];
        animated = NO;
    }
    if (VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"animated"], NSNumber)) {
        NSNumber* animatedNumber = [notification.userInfo objectForKey:@"animated"];
        animated = [animatedNumber boolValue];
    }
    
    BOOL isFromCheckout = NO;
    if (VALID_NOTEMPTY([notification.userInfo objectForKey:@"continue_button"], NSNumber)) {
        isFromCheckout = [[notification.userInfo objectForKey:@"continue_button"] boolValue];
    }
    authenticationViewController.showContinueWithoutLogin = isFromCheckout;
    
    if (VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY(notification.userInfo, NSDictionary)) {
        [authenticationViewController setUserInfo:notification.userInfo];
    }
    [self pushViewController:authenticationViewController animated:YES];
}

- (void)showSignInScreen:(NSNotification *)notification {
    [self showAuthenticationScreen:nil];
}

#pragma mark Sign Up Screen
- (void)showSignUpScreen:(NSNotification *)notification {
    if ([self showAndCheckIfUserAlreadyLoggedIn]) {
        return;
    }

    AuthenticationContainerViewController *authenticationViewController = (AuthenticationContainerViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"Authentication" nibName:@"AuthenticationContainerViewController" resetCache:YES];
    authenticationViewController.startWithSignUpViewController = YES;
    [self pushViewController:authenticationViewController animated:YES];
}

- (BOOL)showAndCheckIfUserAlreadyLoggedIn {
    if ([RICustomer checkIfUserIsLogged]) {
        if ([self.topViewController isKindOfClass:[BaseViewController class]]) {
            [((BaseViewController *)self.topViewController) showNotificationBarMessage:STRING_ALREADY_LOGGED_IN isSuccess:YES];
        } else if ([self.topViewController isKindOfClass:[JABaseViewController class]]) {
            [((JABaseViewController *)self.topViewController) showMessage:STRING_ALREADY_LOGGED_IN success:YES];
        }
        return YES;
    }
    return NO;
}

#pragma mark Recently Viewed Screen
- (void)showRecentlyViewedController {
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JARecentlyViewedViewController class]]) {
        JARecentlyViewedViewController *recentlyViewedViewController = [[JARecentlyViewedViewController alloc]init];
        
        [self pushViewController:recentlyViewedViewController animated:YES];
    }
}

#pragma mark My Account Screen
- (void)showMyAccountController {
    [MainTabBarViewController showProfile];
}

#pragma mark Track Order Screen
- (void)showMyOrdersViewController:(NSNotification*)notification {
    //UIViewController *topViewController = [self topViewController];
    if([RICustomer checkIfUserIsLogged]) {
        OrderListViewController *myOrderViewCtrl = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"OrderListViewController"];
        [self pushViewController:myOrderViewCtrl animated:YES];
    } else {
        [self performProtectedBlock:^(BOOL userHadSession) {
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }];
    }
}

#pragma mark Track Order Detail Screen
- (void)showMyOrderDetailViewController:(NSNotification*)notification {
}

#pragma mark User Data Screen
- (void)showUserData:(NSNotification*)notification {
    [self requestNavigateToNib:@"EditProfileViewController" ofStoryboard:@"Main" useCache:NO args:nil];
}

//#pragma mark Checkout External Payments Screen
- (void)showCheckoutExternalPaymentsScreen:(NSNotification *)notification {
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAExternalPaymentsViewController class]] && [RICustomer checkIfUserIsLogged]) {
        self.neeedsExternalPaymentMethod = YES;
        JAExternalPaymentsViewController *externalPaymentsVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"externalPaymentsViewController"];
        externalPaymentsVC.cart = [notification.userInfo objectForKey:kCart];
        [self pushViewController:externalPaymentsVC animated:YES];
    }
}

#pragma mark Catalog Screen
- (void)pushCatalogToShowSearchResults:(NSString *)query {
    [self openScreenTarget:[RITarget getTarget:CATALOG_SEARCH node:query] purchaseInfo:nil currentScreenName:nil];
}

- (void)didSelectLeafCategoryInMenu:(NSNotification *)notification {
    NSDictionary *selectedItem = [notification object];
    RICategory* category = [selectedItem objectForKey:@"category"];
    NSString* categoryUrlKey = [selectedItem objectForKey:@"category_url_key"];
    NSString* filterPush = [selectedItem objectForKey:@"filter"];
    NSString* sorting = [selectedItem objectForKey:@"sorting"];
    
    if (category) {
        CatalogViewController *catalog = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
        catalog.searchTarget = [RITarget getTarget:CATALOG_CATEGORY node:category.urlKey];
        
        [self pushViewController:catalog animated:YES];
    } else if (categoryUrlKey.length) {
        CatalogViewController *catalog = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
        catalog.searchTarget = [RITarget getTarget:CATALOG_CATEGORY node:categoryUrlKey];
        catalog.pushFilterQueryString = filterPush;

        catalog.sortingMethodString = sorting;
        [self pushViewController:catalog animated:YES];
    }
}

#pragma mark - PDV Actions
- (void)showOtherOffers:(NSNotification*)notification {
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAOtherOffersViewController class]]) {
    
        JAOtherOffersViewController* otherOffersVC = [[JAOtherOffersViewController alloc] init];
        
        if (notification.object && [notification.object isKindOfClass:[RIProduct class]]) {
            otherOffersVC.product = notification.object;
        }
        
        [self pushViewController:otherOffersVC animated:YES];
    }
}

#pragma mark - Teaser Actions
- (void)didSelectTeaserWithCatalogUrl:(NSNotification*)notification {
    NSString* targetString = [notification.userInfo objectForKey:@"targetString"];
    NSString* purchaseTrackingInfo = [notification.userInfo objectForKey:@"purchaseTrackingInfo"];
    if (targetString.length) {
        [self openScreenTarget:[RITarget parseTarget:targetString] purchaseInfo:purchaseTrackingInfo currentScreenName:nil];
    }
}

- (void)didSelectCampaign:(NSNotification*)notification {
    NSString* title = [notification.userInfo objectForKey:@"title"];
    
    //this is used when the teaserGrouping is campaigns and we have to show more than one campaign
    RITeaserGrouping* teaserGrouping = [notification.userInfo objectForKey:@"teaserGrouping"];

    //this is used when the teaserGrouping is not campaigns, so we're only going to be showing one
    NSString* campaignTargetString = [notification.userInfo objectForKey:@"targetString"];
    
    //this is used in deeplinking
    NSString* campaignId = [notification.userInfo objectForKey:@"campaign_id"];
    
    NSString* cameFromTeasers;
    if ([notification.userInfo objectForKey:@"purchaseTrackingInfo"]) {
        cameFromTeasers = [notification.userInfo objectForKey:@"purchaseTrackingInfo"];
    }
    
    if (teaserGrouping) {
        JACampaignsViewController* campaignsVC = [JACampaignsViewController new];
        
        campaignsVC.teaserGrouping = teaserGrouping;
        campaignsVC.startingTitle = title;
        campaignsVC.purchaseTrackingInfo = cameFromTeasers;
        
        [self pushViewController:campaignsVC animated:YES];
    } else if (campaignId.length) {
        JACampaignsViewController* campaignsVC = [JACampaignsViewController new];
        
        campaignsVC.campaignId = campaignId;
        campaignsVC.purchaseTrackingInfo = cameFromTeasers;
        
        [self pushViewController:campaignsVC animated:YES];
    } else if (campaignTargetString.length) {
        JACampaignsViewController* campaignsVC = [JACampaignsViewController new];
        campaignsVC.targetString = campaignTargetString;
        campaignsVC.purchaseTrackingInfo = cameFromTeasers;
        [self pushViewController:campaignsVC animated:YES];
    }
}

- (void)didSelectTeaserWithPDVUrl:(NSNotification*)notification {
    
    NSString* targetString = [notification.userInfo objectForKey:@"targetString"];
    NSString* productSku = [notification.userInfo objectForKey:@"sku"];
    targetString = targetString ?: [RITarget getTargetString:PRODUCT_DETAIL node:productSku];
    
    if (targetString.length || productSku.length) {
        [self openTargetString:targetString purchaseInfo:[notification.userInfo objectForKey:@"purchaseTrackingInfo"] currentScreenName:nil];
    }
}

- (void)didSelectTeaserWithShopUrl:(NSNotification*)notification {
    NSString* targetString = [notification.userInfo objectForKey:@"targetString"];
    JAShopWebViewController* viewController = [[JAShopWebViewController alloc] init];
    if([notification.userInfo objectForKey:@"title"]) {
        viewController.title = [notification.userInfo objectForKey:@"title"];
    }
    if ([notification.userInfo objectForKey:@"purchaseTrackingInfo"]) {
        viewController.purchaseTrackingInfo = [notification.userInfo objectForKey:@"purchaseTrackingInfo"];
    }
    if (targetString.length) {
        viewController.targetString = targetString;
        [self pushViewController:viewController animated:YES];
    }
}

- (void)closeCurrentScreenNotificaion:(NSNotification*)notification {
    BOOL animated = YES;
    if(VALID_NOTEMPTY(notification.userInfo, NSDictionary) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"animated"], NSNumber)) {
        animated = [[notification.userInfo objectForKey:@"animated"] boolValue];
    }
    if(VALID_NOTEMPTY(notification.userInfo, NSDictionary) && VALID_NOTEMPTY(notification.object, UIViewController)) {
        if ([self topViewController] != notification.object) {
            return;
        }
    }
    JAStepByStepTabViewController *topViewController = (JAStepByStepTabViewController *)[self topViewController];
    if ([topViewController isKindOfClass:[JAStepByStepTabViewController class]] && !topViewController.stackIsEmpty) {
        if ([topViewController sendBack]) {
            return;
        }
    }
    [self popViewControllerAnimated:animated];
}

- (BOOL)closeScreensToStackClass:(Class)classKind animated:(BOOL)animated {
    for (UIViewController *viewController in [[self.viewControllers reverseObjectEnumerator] allObjects]) {
        if ([viewController isKindOfClass:classKind]) {
            [self popToViewController:viewController animated:animated];
            return YES;
        }
    }
    return NO;
}

- (void)closeTopTwoScreensNotificaion:(NSNotification*)notification {
    NSInteger thirdToLastIndex = self.viewControllers.count-3;
    if (0 <= thirdToLastIndex) {
        UIViewController* thirdToLastViewController = [self.viewControllers objectAtIndex:thirdToLastIndex];
        
        BOOL animated = YES;
        if(VALID_NOTEMPTY(notification.userInfo, NSDictionary) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"animated"], NSNumber)) {
            animated = [[notification.userInfo objectForKey:@"animated"] boolValue];
        }
        [self popToViewController:thirdToLastViewController animated:YES];
    }
}

- (void)checkRedirectInfo {
    if ([RICountryConfiguration getCurrentConfiguration]) {
        if (VALID([RICountryConfiguration getCurrentConfiguration].redirectStringTarget, NSString)) {
            
            JAScreenTarget *screenTarget = [[JAScreenTarget alloc] initWithTarget:[RITarget parseTarget:[RICountryConfiguration getCurrentConfiguration].redirectStringTarget]];
            [screenTarget.screenInfo setObject:[RICountryConfiguration getCurrentConfiguration].redirectHtml forKey:@"html"];
            [screenTarget.screenInfo setObject:[RICountryConfiguration getCurrentConfiguration].redirectStringTarget forKey:@"action"];
            [screenTarget.navBarLayout setShowBackButton:NO];
            [screenTarget.navBarLayout setShowCartButton:NO];
            [screenTarget.navBarLayout setShowSearchButton:NO];
            return;
        }
    }
}

#pragma mark - OnlineReturns
- (void)updateCartWith:(RICart *)cart {
    if(cart) {
        //update navbars cart value
        [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull viewCtrl, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([viewCtrl isKindOfClass:[BaseViewController class]]) {
                [((BaseViewController *)viewCtrl) updateCartInNavBar];
            }
        }];
        self.cart = cart;
    }
}

- (void)openCart:(NSNotification*) notification {
    [MainTabBarViewController showCart];
}

- (void)showSearchView: (NSString *)screenName {
    SearchViewController *searchViewController = (SearchViewController *)[self requestViewController:@"SearchViewController" ofStoryboard:@"Main" useCache:NO];
    searchViewController.parentScreenName = screenName;
    if ([[MainTabBarViewController topViewController] conformsToProtocol:@protocol(SearchViewControllerDelegate)]) {
        searchViewController.delegate = (id<SearchViewControllerDelegate>)[MainTabBarViewController topViewController];
    }
    [self presentViewController:searchViewController animated:true completion:nil];
}

//#####################################################################################################################
- (void) requestNavigateToNib:(NSString *)destNib args:(NSDictionary *)args {
    [self requestNavigateToNib:destNib ofStoryboard:@"Main" useCache:YES args:args];
}

- (UIViewController *)requestViewController:(NSString *)destNib ofStoryboard:(NSString *)storyboard useCache:(BOOL)useCache {
    UIViewController *destViewController;
    if(storyboard == nil) {
        destViewController = [[ViewControllerManager sharedInstance] loadNib:destNib resetCache:!useCache];
    } else {
        destViewController = [[ViewControllerManager sharedInstance] loadViewController:storyboard nibName:destNib resetCache:!useCache];
    }
    return destViewController;
}

- (void) requestNavigateToNib:(NSString *)destNib ofStoryboard:(NSString *)storyboard useCache:(BOOL)useCache args:(NSDictionary *)args {
    UIViewController *destViewController = [self requestViewController:destNib ofStoryboard:storyboard useCache:useCache];
    [self requestNavigateToViewController:destViewController args:args];
}

- (void)requestNavigateToClass:(NSString *)destClass args:(NSDictionary *)args {
    UIViewController *destViewController = (UIViewController *)[NSClassFromString(destClass) new];
    
    [self requestNavigateToViewController:destViewController args:args];
}

- (void)performProtectedBlock:(ProtectedBlock)block {
    if(block && ![RICustomer checkIfUserIsLogged]) {
        [self pushAuthenticationViewController:^{
            block(YES);
        } byAniamtion:YES];
    } else {
        block(YES);
    }
}

#pragma mark - Helpers
- (void)requestNavigateToViewController:(UIViewController *)viewController args:(NSDictionary *)args {
    NSNumber *animation  = [args objectForKey:kAnimation] ?: @(YES);
    if(viewController) {
        if([viewController conformsToProtocol:@protocol(ProtectedViewControllerProtocol)]) {
            [self performProtectedBlock:^(BOOL userHadSession) {
                [self pushViewController:[self setArgsForViewController:viewController args:args] animated: animation.boolValue];
            }];
        } else {
            [self pushViewController:[self setArgsForViewController:viewController args:args] animated: animation.boolValue];
        }
    }
}

//In existing navigation view controller force the user to login (no back button) e.g. in root of navigation view controllers
- (void)requestForcedLoginWithCompletion:(void (^)(void))completion {
    if (![RICustomer checkIfUserIsLogged]) {
        [self pushAuthenticationViewController:completion byAniamtion:NO byForce:YES];
    }
}

- (UIViewController *)setArgsForViewController:(UIViewController *)viewController args:(NSDictionary *)args {
    if([viewController conformsToProtocol:@protocol(ArgsReceiverProtocol)]) {
        [viewController performSelectorOnMainThread:@selector(updateWithArgs:) withObject:args waitUntilDone:YES];
    }
    return viewController;
}

- (void)pushAuthenticationViewController:(void (^)(void))completion byAniamtion:(BOOL)animation byForce:(BOOL)force {
    AuthenticationCompletion _authenticationCompletion = ^(AuthenticationStatus status) {
        switch (status) {
            case AuthenticationStatusSigninFinished:
                [self popViewControllerAnimated:NO];
                if(completion) completion();
                break;
            case AuthenticationStatusSignupFinished:
                if ([[MainTabBarViewController topViewController] isKindOfClass:[PhoneVerificationViewController class]]) {
                    [self popWithStep:2 animated:NO];
                } else if ([[MainTabBarViewController topViewController] isKindOfClass:[SignUpViewController class]]) {
                    [self popViewControllerAnimated:NO];
                }
                if(completion) completion();
                break;
            default:
                break;
        }
    };
    
    AuthenticationContainerViewController *authViewController = (AuthenticationContainerViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"Authentication" nibName:@"AuthenticationContainerViewController" resetCache:YES];
    authViewController.fromSideMenu = NO;
    authViewController.isForcedToLogin = force;
    authViewController.signInViewController.completion = _authenticationCompletion;
    authViewController.signUpViewController.completion = _authenticationCompletion;
    [self pushViewController:authViewController animated:animation];
}

- (void)pushAuthenticationViewController:(void (^)(void))completion byAniamtion:(BOOL)animation {
    [self pushAuthenticationViewController:completion byAniamtion:animation byForce:NO];
}


@end
