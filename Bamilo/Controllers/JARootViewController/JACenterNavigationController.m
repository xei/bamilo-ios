//
//  JACenterNavigationController.m
//  Jumia
//
//  Created by Miguel Chaves on 31/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACenterNavigationController.h"
#import "AuthenticationContainerViewController.h"
#import "JAChooseCountryViewController.h"
#import "JAHomeViewController.h"
#import "JALoadCountryViewController.h"
#import "JARecentSearchesViewController.h"
#import "JARecentlyViewedViewController.h"
#import "JAUserDataViewController.h"
#import "JAPDVViewController.h"
#import "JAExternalPaymentsViewController.h"
#import "RIProduct.h"
#import "RISeller.h"
#import "JANavigationBarLayout.h"
#import "RICustomer.h"
#import "JACampaignsViewController.h"
#import "JATabNavigationViewController.h"
#import "JANewRatingViewController.h"
#import "JASizeGuideViewController.h"
#import "JAOtherOffersViewController.h"
#import "JASellerRatingsViewController.h"
#import "JANewSellerRatingViewController.h"
#import "JAShopWebViewController.h"
#import "JABundlesViewController.h"
#import "JAPDVVariationsViewController.h"
#import "RICountry.h"
#import "JANewsletterViewController.h"
#import "JANewsletterSubscriptionViewController.h"

#import "JAActionWebViewController.h"

#import "JAStepByStepTabViewController.h"
#import "JACheckoutStepByStepModel.h"
#import "JAReturnStepByStepModel.h"

#import "JAORConfirmConditionsViewController.h"
#import "JAORConfirmationScreenViewController.h"
#import "JAORCallToReturnViewController.h"
#import "RIHtmlShop.h"

#import "JAORReasonsViewController.h"
#import "JAORWaysViewController.h"
#import "JAORPaymentViewController.h"
#import "JAORPickupStationWebViewController.h"
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

- (JAStepByStepTabViewController *)returnsStepByStepViewController {
    if (!VALID(_returnsStepByStepViewController, JAStepByStepTabViewController)) {
        _returnsStepByStepViewController = [self getNewReturnsStepByStepViewController];
    }
    return _returnsStepByStepViewController;
}

- (JAStepByStepTabViewController *)getNewReturnsStepByStepViewController {
    JAStepByStepTabViewController *returnsStepByStepViewController = [JAStepByStepTabViewController new];
    
    [returnsStepByStepViewController setStepByStepModel:[JAReturnStepByStepModel new]];
    [returnsStepByStepViewController setIndexInit:0];
    return returnsStepByStepViewController;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self.neeedsExternalPaymentMethod = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCart:) name:kUpdateCartNotification object:nil];
}

- (void)registerObservingOnNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHomeScreen:) name:kShowHomeScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSavedListViewController:) name:kShowSavedListScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRecentSearchesController:) name:kShowRecentSearchesScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showRecentlyViewedController) name:kShowRecentlyViewedScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMyAccountController) name:kShowMyAccountScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showUserData:) name:kShowUserDataScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showEmailNotificaitons:) name:kShowEmailNotificationsScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewsletterSubscritions:) name:kShowNewsletterSubscriptionsScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMyOrdersViewController:) name:kShowMyOrdersScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAuthenticationScreen:) name:kShowAuthenticationScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSignUpScreen:) name:kShowSignUpScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCheckoutExternalPaymentsScreen:) name:kShowCheckoutExternalPaymentsScreenNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showCheckoutThanksScreen:) name:kShowCheckoutThanksScreenNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectRecentSearch:) name:kSelectedRecentSearchNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectItemInMenu:) name:kMenuDidSelectOptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectLeafCategoryInMenu:) name:kMenuDidSelectLeafCategoryNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openCart:) name:kOpenCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTeaserWithCatalogUrl:) name:kDidSelectTeaserWithCatalogUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectCampaign:) name:kDidSelectCampaignNofication object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTeaserWithPDVUrl:) name:kDidSelectTeaserWithPDVUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTeaserWithShopUrl:) name:kDidSelectTeaserWithShopUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeCurrentScreenNotificaion:) name:kCloseCurrentScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeTopTwoScreensNotificaion:) name:kCloseTopTwoScreensNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProductSpecificationScreen:) name:kShowProductSpecificationScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewRatingScreen:) name:kShowNewRatingScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProductBundlesScreen:) name:kOpenProductBundlesScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProductVariationsScreen:) name:kOpenProductVariationsScreen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSizeGuide:) name:kShowSizeGuideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showOtherOffers:) name:kOpenOtherOffers object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSellerReviews:) name:kOpenSellerReviews object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNewSellerReview:) name:kOpenNewSellerReview object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSellerCatalog:) name:kOpenSellerPage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkRedirectInfo) name:kCheckRedirectInfoNotification object:nil];
}

- (void)removeObservingNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowHomeScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowSavedListScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowRecentSearchesScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowRecentlyViewedScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowMyAccountScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowUserDataScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowEmailNotificationsScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowNewsletterSubscriptionsScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowMyOrdersScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowAuthenticationScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowSignUpScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowCheckoutExternalPaymentsScreenNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowCheckoutThanksScreenNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSelectedRecentSearchNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMenuDidSelectOptionNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMenuDidSelectLeafCategoryNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenCartNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidSelectTeaserWithCatalogUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidSelectCampaignNofication object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidSelectTeaserWithPDVUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kDidSelectTeaserWithShopUrlNofication object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCloseCurrentScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCloseTopTwoScreensNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowProductSpecificationScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowNewRatingScreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenProductBundlesScreen object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenProductVariationsScreen object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kShowSizeGuideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenOtherOffers object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenSellerReviews object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenNewSellerReview object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kOpenSellerPage object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kCheckRedirectInfoNotification object:nil];
    
}

- (void)openTargetString:(NSString *)targetString purchaseInfo:(NSString *)purchaseInfo {
    JAScreenTarget *screenTarget = [JAScreenTarget new];
    screenTarget.target = [RITarget parseTarget:targetString];
    screenTarget.pushAnimation = YES;
    [self openScreenTarget:screenTarget purchaseInfo:purchaseInfo];
}

- (BOOL)openScreenTarget:(JAScreenTarget *)screenTarget purchaseInfo:(NSString *)purchaseInfo {
    if ([[self topViewController] isKindOfClass:[JABaseViewController class]] && [[(JABaseViewController *)[self topViewController] targetString] isEqualToString:screenTarget.target.targetString]) {
        return NO;
    }
    switch (screenTarget.target.targetType) {
        case PRODUCT_DETAIL: {
            JAPDVViewController *viewController = [JAPDVViewController new];
            viewController.purchaseTrackingInfo = purchaseInfo;
            viewController.targetString = screenTarget.target.targetString;
            viewController.hidesBottomBarWhenPushed = YES;
            [self pushViewController:viewController animated:screenTarget.pushAnimation];
            return YES;
        }
        case CATALOG_SEARCH: {
            CatalogViewController *viewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
            viewController.searchTarget = screenTarget.target;
            viewController.purchaseTrackingInfo = purchaseInfo;
            [self pushViewController:viewController animated:screenTarget.pushAnimation];
            return YES;
        }
        case CATALOG_HASH:
        case CATALOG_BRAND:
        case CATALOG_CATEGORY: {
            CatalogViewController *viewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"catalogViewController"];;
            viewController.searchTarget = screenTarget.target;
            viewController.purchaseTrackingInfo = purchaseInfo;
            [self pushViewController:viewController animated:screenTarget.pushAnimation];
            return YES;
        }
        case STATIC_PAGE:
        case SHOP_IN_SHOP: {
            JAShopWebViewController* viewController = [[JAShopWebViewController alloc] init];
            viewController.purchaseTrackingInfo = purchaseInfo;
            [self loadScreenTarget:screenTarget forBaseViewController:viewController];
            [viewController setTitle:screenTarget.target.node];
            [self pushViewController:viewController animated:screenTarget.pushAnimation];
            return YES;
        }
        case EXTERNAL_LINK: {
            JAActionWebViewController* viewController = [[JAActionWebViewController alloc] init];
            [self loadScreenTarget:screenTarget forBaseViewController:viewController];
            [viewController setHtmlString:VALID_NOTEMPTY_VALUE([screenTarget.screenInfo objectForKey:@"html"], NSString)];
            [self pushViewController:viewController animated:screenTarget.pushAnimation];
            return YES;
        }
        case CAMPAIGN: {
            JACampaignsViewController *viewController = [JACampaignsViewController new];
            viewController.purchaseTrackingInfo = purchaseInfo;
            [self loadScreenTarget:screenTarget forBaseViewController:viewController];
            [self pushViewController:viewController animated:screenTarget.pushAnimation];
            return YES;
        }
            
        default:
            if (screenTarget.target.node &&
                ([screenTarget.target.node containsString:@"itms-apps://"] || [screenTarget.target.node containsString:@"https://app."])) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:screenTarget.target.node]];
                return YES;
            }
            return NO;
    }
}

- (void)loadScreenTarget:(JAScreenTarget *)screenTarget forBaseViewController:(JABaseViewController *)viewController {
    [viewController setTargetString:screenTarget.target.targetString];
}

#pragma mark Home Screen
- (void)showHomeScreen:(NSNotification*)notification {
    [MainTabBarViewController showHome];
}

- (void)showRootViewController {
    [self popToRootViewControllerAnimated:YES];
}


#pragma mark - Left Menu Actions
- (void)didSelectItemInMenu:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification object:nil];
    NSDictionary *selectedItem = [notification object];
    if ([selectedItem objectForKey:@"index"]) {
        NSNumber *index = [selectedItem objectForKey:@"index"];
        
        if ([index isEqual:@(0)]) {
            [self changeCenterPanel:STRING_HOME notification:notification];
        } else {
            if ([index isEqual:@(99)]) {
                // It's to perform a search
                [self pushCatalogToShowSearchResults:[selectedItem objectForKey:@"text"]];
            } else if ([index isEqual:@(98)]) {
                [self  pushCatalogForUndefinedSearchWithBrandTargetString:[selectedItem objectForKey:@"targetString"]
                                                   andBrandName:[selectedItem objectForKey:@"name"]];
            } else {
                [self changeCenterPanel:[selectedItem objectForKey:@"name"] notification:notification];
            }
        }
    }
    
}

- (void)changeCenterPanel:(NSString *)newScreenName notification:(NSNotification *)notification {
    if ([newScreenName isEqualToString:STRING_HOME]) {
        [self showHomeScreen:nil];
    }
    else if ([newScreenName isEqualToString:STRING_RECENT_SEARCHES]) {
        [self showRecentSearchesController:nil];
    } else if ([newScreenName isEqualToString:STRING_LOGIN]) {
        [self showSignInScreen:nil];
    } else if ([newScreenName isEqualToString:STRING_RECENTLY_VIEWED]) {
        [self showRecentlyViewedController];
    } else if([newScreenName isEqualToString:STRING_MY_ACCOUNT]) {
        [self showMyAccountController];
    } else if ([newScreenName isEqualToString:STRING_MY_ORDERS]) {
        [self showMyOrdersViewController:nil];
    } else if ([newScreenName isEqualToString:STRING_USER_DATA]) {
        [self showUserData:nil];
    } else if ([newScreenName isEqualToString:STRING_USER_EMAIL_NOTIFICATIONS]) {
        [self showEmailNotificaitons:nil];
    }
    
//    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
//    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
//    [trackingDictionary setValue:newScreenName forKey:kRIEventActionKey];
//    [trackingDictionary setValue:@"ActionOverflow" forKey:kRIEventCategoryKey];
//    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSideMenu]
//                                              data:[trackingDictionary copy]];
}

#pragma mark Favorites Screen
- (void)showSavedListViewController:(NSNotification*)notification {
    [MainTabBarViewController showWishList];
}

#pragma mark Recent Searches Screen
- (void)showRecentSearchesController:(NSNotification*)notification {
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JARecentSearchesViewController class]]) {
        JARecentSearchesViewController *recentSearches = [[JARecentSearchesViewController alloc] initWithNibName:@"JARecentSearchesViewController" bundle:nil];

        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:recentSearches animated:NO];
    }
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
    [self requestNavigateToNib:@"EditProfileViewController" args:nil];
}

#pragma mark Email Notifications Screen
- (void)showEmailNotificaitons:(NSNotification*)notification {
    UIViewController *topViewController = [self topViewController];
    if([RICustomer checkIfUserIsLogged]) {
        if (![topViewController isKindOfClass:[JANewsletterViewController class]]) {
            JANewsletterViewController* vc = [[JANewsletterViewController alloc] init];
            [self pushViewController:vc animated:YES];
        }
    } else {
        [self performProtectedBlock:^(BOOL userHadSession) {
            [[NSNotificationCenter defaultCenter] postNotification:notification];
        }];
    }
}

- (void)showNewsletterSubscritions:(NSNotification*)notification {
    NSDictionary* userInfo = notification.userInfo;
    NSString* targetString = [userInfo objectForKey:@"targetString"];
    
    if (VALID_NOTEMPTY(targetString, NSString)) {
        JANewsletterSubscriptionViewController* vc = [[JANewsletterSubscriptionViewController alloc] init];
        vc.targetString = targetString;
        
        id<JANewsletterSubscriptionDelegate> delegate = [userInfo objectForKey:@"delegate"];
        if (delegate) {
            vc.delegate = delegate;
        }
        
        [self pushViewController:vc animated:YES];
    }
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

//#pragma mark Checkout Thanks Screen
//- (void)showCheckoutThanksScreen:(NSNotification *)notification {
//    SuccessPaymentViewController *viewCtrl = (SuccessPaymentViewController *)[[ViewControllerManager sharedInstance] loadViewController:@"Checkout" nibName:NSStringFromClass([SuccessPaymentViewController class]) resetCache:NO];
//    viewCtrl.success = [(NSNumber *)[notification.userInfo objectForKey:@"success"] boolValue];
//    viewCtrl.cart = [notification.userInfo objectForKey:kCart];
//    [self pushViewController:viewCtrl animated:YES];
//}

#pragma mark Catalog Screen
- (void)pushCatalogToShowSearchResults:(NSString *)query {
    CatalogViewController *catalog = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
    catalog.searchTarget = [RITarget getTarget:CATALOG_SEARCH node:query];
    [self pushViewController:catalog animated:YES];
}

- (void)pushCatalogForUndefinedSearchWithBrandTargetString:(NSString *)brandTargetString andBrandName:(NSString *)brandName {
    CatalogViewController *catalog = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
    catalog.searchTarget = [RITarget parseTarget:brandTargetString];
    [self pushViewController:catalog animated:YES];
}

- (void)didSelectLeafCategoryInMenu:(NSNotification *)notification {
    NSDictionary *selectedItem = [notification object];
    RICategory* category = [selectedItem objectForKey:@"category"];
    NSString* categoryUrlKey = [selectedItem objectForKey:@"category_url_key"];
    NSString* filterPush = [selectedItem objectForKey:@"filter"];
    NSString* sorting = [selectedItem objectForKey:@"sorting"];
    
    if (category) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification object:nil];
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

#pragma mark - Filters

- (void)showProductSpecificationScreen:(NSNotification*)notification {
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JATabNavigationViewController class]]) {
        JATabNavigationViewController *productDetailsViewController = [[JATabNavigationViewController alloc] init];
        
        if ([notification.userInfo objectForKey:@"product"]) {
            productDetailsViewController.product = [notification.userInfo objectForKey:@"product"];
        }
        if ([notification.userInfo objectForKey:@"product.screen"]) {
            if ([[notification.userInfo objectForKey:@"product.screen"] isEqualToString:@"description"]) {
                [productDetailsViewController setTabScreenEnum:kTabScreenDescription];
            }else if ([[notification.userInfo objectForKey:@"product.screen"] isEqualToString:@"specifications"]) {
                [productDetailsViewController setTabScreenEnum:kTabScreenSpecifications];
            }else if ([[notification.userInfo objectForKey:@"product.screen"] isEqualToString:@"reviews"]) {
                [productDetailsViewController setTabScreenEnum:kTabScreenReviews];
            }
        }
        
        [self pushViewController:productDetailsViewController animated:YES];
    }
}

- (void)showNewRatingScreen:(NSNotification*)notification {
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JANewRatingViewController class]])
    {
        JANewRatingViewController* newRatingViewController = [[JANewRatingViewController alloc] initWithNibName:@"JANewRatingViewController" bundle:nil];
        
        if ([notification.userInfo objectForKey:@"product"]) {
            newRatingViewController.product = [notification.userInfo objectForKey:@"product"];
        }
        
        if ([notification.userInfo objectForKey:@"productRatings"]) {
            newRatingViewController.productRatings = [notification.userInfo objectForKey:@"productRatings"];
        }
        
        BOOL animated = YES;
        if([notification.userInfo objectForKey:@"animated"] && VALID_NOTEMPTY([notification.object objectForKey:@"animated"], NSNumber)) {
            animated = [[notification.userInfo objectForKey:@"animated"] boolValue];
        }
        
        [self pushViewController:newRatingViewController animated:animated];
    }
}

- (void)showSizeGuide:(NSNotification*)notification {
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JASizeGuideViewController class]]) {
        JASizeGuideViewController* viewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"sizeGuideViewController"];
        
        if ([notification.userInfo objectForKey:@"sizeGuideUrl"]) {
            viewController.sizeGuideUrl = [notification.userInfo objectForKey:@"sizeGuideUrl"];
        }
        
        [self pushViewController:viewController animated:YES];
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

- (void)showProductBundlesScreen:(NSNotification *)notification {
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JABundlesViewController class]]) {
        
        JABundlesViewController* bundlesVC = [[JABundlesViewController alloc] init];
        
        if (notification.object && [notification.object isKindOfClass:[RIProduct class]]) {
            bundlesVC.product = notification.object;
        }
        if (VALID_NOTEMPTY(notification.userInfo, NSDictionary)) {
            if (VALID_NOTEMPTY([notification.userInfo objectForKey:@"product.bundles"], NSArray)) {
                bundlesVC.bundles = [notification.userInfo objectForKey:@"product.bundles"];
            }
            if ([notification.userInfo objectForKey:@"product.bundles.onChange"]) {
                [bundlesVC onBundleSelectionChanged:[notification.userInfo objectForKey:@"product.bundles.onChange"]];
            }
            if ([notification.userInfo objectForKeyedSubscript:@"product.bundles.selected"]) {
                [bundlesVC setSelectedItems:[notification.userInfo objectForKey:@"product.bundles.selected"]];
            }
            if ([notification.userInfo objectForKeyedSubscript:@"product.bundle"]) {
                [bundlesVC setBundle:[notification.userInfo objectForKey:@"product.bundle"]];
            }
        }
        
        [self pushViewController:bundlesVC animated:YES];
    }
}


- (void)showProductVariationsScreen:(NSNotification *)notification {
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAPDVVariationsViewController class]]) {
        
        JAPDVVariationsViewController* variationsVC = [[JAPDVVariationsViewController alloc] init];
        
        if (notification.object && [notification.object isKindOfClass:[RIProduct class]]) {
            variationsVC.product = notification.object;
        }
        if (notification.userInfo) {
            if ([[notification.userInfo objectForKey:@"product.variations"] count]) {
                variationsVC.variations = [notification.userInfo objectForKey:@"product.variations"];
            }
        }
        
        [self pushViewController:variationsVC animated:YES];
    }
}

- (void)showSellerReviews:(NSNotification*)notification {
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JASellerRatingsViewController class]]) {
        JASellerRatingsViewController* viewController = [[JASellerRatingsViewController alloc] initWithNibName:@"JASellerRatingsViewController" bundle:nil];
        
        if (notification.object && [notification.object isKindOfClass:[RIProduct class]]) {
            viewController.product = notification.object;
        }
        
        [self pushViewController:viewController animated:YES];
    }
}

- (void)showNewSellerReview:(NSNotification*)notification {
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JANewRatingViewController class]]) {
        JANewSellerRatingViewController* newSellerRatingViewController = [[JANewSellerRatingViewController alloc] initWithNibName:@"JANewSellerRatingViewController" bundle:nil];
        
        if ([notification.userInfo objectForKey:@"product"]) {
            newSellerRatingViewController.product = [notification.userInfo objectForKey:@"product"];
        }
        
        if([notification.userInfo objectForKey:@"sellerAverageReviews"]) {
            newSellerRatingViewController.sellerAverageReviews = [notification.userInfo objectForKey:@"sellerAverageReviews"];
        }
        
        BOOL animated = YES;
        if([notification.userInfo objectForKey:@"animated"] && VALID_NOTEMPTY([notification.object objectForKey:@"animated"], NSNumber)) {
            animated = [[notification.userInfo objectForKey:@"animated"] boolValue];
        }
        
        [self pushViewController:newSellerRatingViewController animated:animated];
    }
}

-(void)showSellerCatalog: (NSNotification *)notification {
    NSString* targetString = [notification.userInfo objectForKey:@"targetString"];
    NSString* title = [notification.userInfo objectForKey:@"name"];
    
    if(VALID_NOTEMPTY(targetString, NSString)) {
        CatalogViewController *catalog = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
        RITarget *target = [RITarget parseTarget:targetString];
        catalog.searchTarget = target;
        catalog.title = title;
        
        [self pushViewController:catalog animated:YES];
    }
}

#pragma mark - Teaser Actions
- (void)didSelectTeaserWithCatalogUrl:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSString* targetString = [notification.userInfo objectForKey:@"targetString"];
    NSString* title = [notification.userInfo objectForKey:@"title"];
    
    if (targetString.length) {
        CatalogViewController *catalog = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
        
        RITarget *target = [RITarget parseTarget:targetString];
        catalog.searchTarget = target;
        catalog.title = title;

        if ([notification.userInfo objectForKey:@"purchaseTrackingInfo"]) {
            catalog.purchaseTrackingInfo = [notification.userInfo objectForKey:@"purchaseTrackingInfo"];
        }
        
        [[MainTabBarViewController topNavigationController] pushViewController:catalog animated:YES];
    }
}

- (void)didSelectCampaign:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification object:nil];
    
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
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification object:nil];
    
    NSString* targetString = [notification.userInfo objectForKey:@"targetString"];
    NSString* productSku = [notification.userInfo objectForKey:@"sku"];
    
    if (targetString.length || productSku.length) {
        JAPDVViewController *pdv = [JAPDVViewController new];
        pdv.targetString = targetString;
        pdv.productSku = productSku;
        
        if ([notification.userInfo objectForKey:@"richRelevance"]) {
            pdv.richRelevanceParameter = [notification.userInfo objectForKey:@"richRelevance"];
        }
        
        if ([notification.userInfo objectForKey:@"fromCatalog"]) {
            pdv.fromCatalogue = YES;
        } else {
            pdv.fromCatalogue = NO;
        }
        
        if ([notification.userInfo objectForKey:@"previousCategory"]) {
            NSString *previous = [notification.userInfo objectForKey:@"previousCategory"];
            
            if (previous.length > 0) {
                pdv.previousCategory = previous;
            }
        }
        
        if ([notification.userInfo objectForKey:@"category"]) {
            pdv.category = [notification.userInfo objectForKey:@"category"];
        }
        
        // For deeplink
        if ([notification.userInfo objectForKey:@"size"]) {
            pdv.preSelectedSize = [notification.userInfo objectForKey:@"size"];
        }
        
        if ([notification.userInfo objectForKey:@"purchaseTrackingInfo"]) {
            pdv.purchaseTrackingInfo = [notification.userInfo objectForKey:@"purchaseTrackingInfo"];
        }
        pdv.hidesBottomBarWhenPushed = YES;
        [self pushViewController:pdv animated:YES];
    }
}

- (void)didSelectTeaserWithShopUrl:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification object:nil];
    
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
//            [[MainTabBarViewController topNavigationController] openScreenTarget:screenTarget];
            return;
        }
    }
}

#pragma mark - OnlineReturns

- (void)goToPickupStationWebViewControllerWithCMS:(NSString*)cmsBlock {
    JAORPickupStationWebViewController* viewController = [[JAORPickupStationWebViewController alloc] init];
    [viewController setCmsBlock:cmsBlock];
    [self pushViewController:viewController animated:YES];
}

- (void)goToOnlineReturnsPaymentScreenForItems:(NSArray *)items order:(RITrackOrder*)order {
    JAORPaymentViewController* viewController = [[JAORPaymentViewController alloc] init];
    [viewController setItems:items];
    [viewController setOrder:order];
    [self goToStep:viewController forStepByStepViewController:self.returnsStepByStepViewController];
}

- (void)goToOnlineReturnsWaysScreenForItems:(NSArray *)items order:(RITrackOrder*)order {
    JAORWaysViewController* viewController = [[JAORWaysViewController alloc] init];
    [viewController setItems:items];
    [viewController setOrder:order];
    [self goToStep:viewController forStepByStepViewController:self.returnsStepByStepViewController];
}

- (void)goToOnlineReturnsReasonsScreenForItems:(NSArray *)items order:(RITrackOrder*)order {
    JAORReasonsViewController* viewController = [[JAORReasonsViewController alloc] init];
    [viewController setItems:items];
    [viewController setOrder:order];
    [self goToStep:viewController forStepByStepViewController:self.returnsStepByStepViewController];
}
    
- (void)goToOnlineReturnsCall:(RIItemCollection *)item fromOrderNumber:(NSString *)orderNumber {
    JAORCallToReturnViewController *viewController = [[JAORCallToReturnViewController alloc] init];
    [viewController setItem:item];
    [viewController setOrderNumber:orderNumber];
    [self pushViewController:viewController animated:YES];
}

- (void)goToOnlineReturnsConfirmConditionsForItems:(NSArray *)items order:(RITrackOrder*)order {
    NSString *targetString = [(RIItemCollection *)[items firstObject] onlineReturnTargetString];
    
    [RIHtmlShop getHtmlShopForTargetString:targetString successBlock:^(RIHtmlShop *htmlShop) {
        JAORConfirmConditionsViewController *viewController = [[JAORConfirmConditionsViewController alloc] init];
        [viewController setHtml:htmlShop.html];
        [viewController setItems:items];
        [viewController setOrder:order];
        [self pushViewController:viewController animated:YES];
    } failureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
        [self goToOnlineReturnsReasonsScreenForItems:items order:order];
    }];
}

- (void)goToOnlineReturnsConfirmScreenForItems:(NSArray *)items order:(RITrackOrder*)order {
    JAORConfirmationScreenViewController *viewController = [[JAORConfirmationScreenViewController alloc] init];
    [viewController setItems:items];
    [viewController setOrder:order];
    [self goToStep:viewController forStepByStepViewController:self.returnsStepByStepViewController];
}

- (void)goToStep:(UIViewController *)viewController forStepByStepViewController:(JAStepByStepTabViewController *)stepByStepViewController {
    if ([self.viewControllers indexOfObject:stepByStepViewController] == NSNotFound) {
        if (stepByStepViewController == self.checkoutStepByStepViewController) {
            stepByStepViewController = [self getNewCheckoutStepByStepViewController];
            self.checkoutStepByStepViewController = stepByStepViewController;
        } else if (stepByStepViewController == self.returnsStepByStepViewController) {
            stepByStepViewController = [self getNewReturnsStepByStepViewController];
            if ([viewController respondsToSelector:@selector(items)]) {
                [(JAReturnStepByStepModel *)stepByStepViewController.stepByStepModel setItems:[viewController performSelector:@selector(items) withObject:nil]];
            }
            if ([viewController respondsToSelector:@selector(order)]) {
                [(JAReturnStepByStepModel *)stepByStepViewController.stepByStepModel setOrder:[viewController performSelector:@selector(order) withObject:nil]];
            }
            self.returnsStepByStepViewController = stepByStepViewController;
        }
    }
    if ([viewController respondsToSelector:@selector(setStateInfoValues:)]) {
        [viewController performSelector:@selector(setStateInfoValues:) withObject:stepByStepViewController.stepByStepModel.stepByStepValues];
    }
    if ([viewController respondsToSelector:@selector(setStateInfoLabels:)]) {
        [viewController performSelector:@selector(setStateInfoLabels:) withObject:stepByStepViewController.stepByStepModel.stepByStepLabels];
    }
    [self closeScreensToStackClass:[JAStepByStepTabViewController class] animated:YES];
    JAStepByStepTabViewController *stepByStepTabViewController = (JAStepByStepTabViewController *)[self topViewController];
    if ([stepByStepTabViewController isKindOfClass:[JAStepByStepTabViewController class]] && [stepByStepTabViewController.stepByStepModel isKindOfClass:[stepByStepViewController.stepByStepModel class]]) {
        [stepByStepTabViewController goToViewController:viewController];
    } else {
        [self pushViewController:stepByStepViewController animated:YES];
        [stepByStepViewController goToViewController:viewController];
    }
}

#pragma mark - Recent Search

//- (void)didSelectRecentSearch:(NSNotification*)notification {
//    RISearchSuggestion *recentSearch = notification.object;
//
//    if (recentSearch) {
//        CatalogViewController *catalog = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"catalogViewController"];
//        catalog.searchTarget = [RITarget getTarget:CATALOG_SEARCH node:recentSearch.item];
//
//        [self pushViewController:catalog animated:YES];
//    }
//}

- (void)updateCart:(NSNotification*) notification {
    NSMutableDictionary* userInfo = nil;
    if(VALID_NOTEMPTY(notification, NSNotification)) {
        userInfo = [[NSMutableDictionary alloc] initWithDictionary:notification.userInfo];
        
        if(VALID_NOTEMPTY([userInfo objectForKey:kUpdateCartNotificationValue], RICart)) {
            self.cart = [userInfo objectForKey:kUpdateCartNotificationValue];
        } else {
            self.cart = nil;
        }
        
        if(self.cart) {
            [MainTabBarViewController updateCartValueWithCartItemsCount:[self.cart.cartEntity.cartCount integerValue]];
        } else {
            [userInfo removeObjectForKey:kUpdateCartNotificationValue];
            [MainTabBarViewController updateCartValueWithCartItemsCount:0];
        }
    } else {
        self.cart = nil;
        [MainTabBarViewController updateCartValueWithCartItemsCount:0];
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
            block(NO);
        } byAniamtion:YES];
    } else {
        block(YES);
    }
}

#pragma mark - Helpers
- (void)requestNavigateToViewController:(UIViewController *)viewController args:(NSDictionary *)args {
    NSNumber *animation  = [args objectForKey:kAnimation] ?: @(YES);
    if(viewController) {
        if([viewController conformsToProtocol:@protocol(ProtectedViewControllerProtocol)] && ![RICustomer checkIfUserIsLogged]) {
            [self pushAuthenticationViewController:^{
                [self pushViewController:[self setArgsForViewController:viewController args:args] animated: animation.boolValue];
            } byAniamtion:YES];
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
