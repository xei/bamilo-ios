//
//  JACenterNavigationController.m
//  Jumia
//
//  Created by Miguel Chaves on 31/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACenterNavigationController.h"
#import "JANavigationBarView.h"
#import "JASplashViewController.h"
#import "RICart.h"
#import "JAHomeViewController.h"
#import "JAMyFavouritesViewController.h"
#import "JAChooseCountryViewController.h"
#import "JARecentSearchesViewController.h"
#import "JACatalogViewController.h"
#import "JAPDVViewController.h"
#import "JACategoriesViewController.h"
#import "JARecentlyViewedViewController.h"
#import "JACartViewController.h"
#import "JAForgotPasswordViewController.h"
#import "JALoginViewController.h"
#import "JAAddressesViewController.h"
#import "JASignInViewController.h"
#import "JASignupViewController.h"
#import "JAAddNewAddressViewController.h"
#import "JAEditAddressViewController.h"
#import "JAShippingViewController.h"
#import "JAPaymentViewController.h"
#import "JAOrderViewController.h"
#import "JAExternalPaymentsViewController.h"
#import "JAThanksViewController.h"
#import "RIProduct.h"
#import "RIApi.h"
#import "JANavigationBarLayout.h"
#import "RICustomer.h"
#import "JATrackMyOrderViewController.h"
#import "JAMyAccountViewController.h"
#import "JAUserDataViewController.h"
#import "JAEmailNotificationsViewController.h"
#import "JACampaignsViewController.h"
#import "JAAppDelegate.h"

@interface JACenterNavigationController ()

@property (strong, nonatomic) RICart *cart;
@property (assign, nonatomic) BOOL neeedsExternalPaymentMethod;

@end

@implementation JACenterNavigationController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.neeedsExternalPaymentMethod = NO;
    
    [self customizeNavigationBar];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectCountry:)
                                                 name:kSelectedCountryNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectRecentSearch:)
                                                 name:kSelectedRecentSearchNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectItemInMenu:)
                                                 name:kMenuDidSelectOptionNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectLeafCategoryInMenu:)
                                                 name:kMenuDidSelectLeafCategoryNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(openCart)
                                                 name:kOpenCartNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCart:)
                                                 name:kUpdateCartNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeEditButtonState:)
                                                 name:kEditShouldChangeStateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeDoneButtonState:)
                                                 name:kDoneShouldChangeStateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectTeaserWithCatalogUrl:)
                                                 name:kDidSelectTeaserWithCatalogUrlNofication
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectCampaign:)
                                                 name:kDidSelectCampaignNofication
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectTeaserWithPDVUrl:)
                                                 name:kDidSelectTeaserWithPDVUrlNofication
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectTeaserWithAllCategories:)
                                                 name:kDidSelectTeaserWithAllCategoriesNofication
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectCategoryFromCenterPanel:)
                                                 name:kDidSelectCategoryFromCenterPanelNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeCurrentScreenNotificaion)
                                                 name:kCloseCurrentScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showHomeScreen)
                                                 name:kShowHomeScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeNavigationWithNotification:)
                                                 name:kChangeNavigationBarNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSignUpScreen:)
                                                 name:kShowSignUpScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSignInScreen:)
                                                 name:kShowSignInScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showFavoritesViewController:)
                                                 name:kShowFavoritesScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showForgotPasswordScreen)
                                                 name:kShowForgotPasswordScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutLoginScreen)
                                                 name:kShowCheckoutLoginScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutForgotPasswordScreen)
                                                 name:kShowCheckoutForgotPasswordScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutAddressesScreen)
                                                 name:kShowCheckoutAddressesScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutAddAddressScreen:)
                                                 name:kShowCheckoutAddAddressScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutEditAddressScreen:)
                                                 name:kShowCheckoutEditAddressScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutShippingScreen)
                                                 name:kShowCheckoutShippingScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutPaymentScreen)
                                                 name:kShowCheckoutPaymentScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutFinishScreen:)
                                                 name:kShowCheckoutFinishScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutExternalPaymentsScreen:)
                                                 name:kShowCheckoutExternalPaymentsScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showCheckoutThanksScreen:)
                                                 name:kShowCheckoutThanksScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deactivateExternalPayment)
                                                 name:kDeactivateExternalPaymentNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showTrackOrderViewController:)
                                                 name:kShowTrackOrderScreenNotification
                                               object:nil];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Left Menu Actions

- (void)didSelectItemInMenu:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSDictionary *selectedItem = [notification object];
    
    if ([selectedItem objectForKey:@"index"]) {
        NSNumber *index = [selectedItem objectForKey:@"index"];
        
        if ([index isEqual:@(0)]) {
            [self changeCenterPanel:STRING_HOME notification:notification];
            
        } else {
            if ([index isEqual:@(99)])
            {
                // It's to perform a search
                [self pushCatalogToShowSearchResults:[selectedItem objectForKey:@"text"]];
            }
            else if ([index isEqual:@(98)])
            {
                [self pushCatalogForUndefinedSearchWithBrandUrl:[selectedItem objectForKey:@"url"]
                                                   andBrandName:[selectedItem objectForKey:@"name"]];
            }
            else
            {
                [self changeCenterPanel:[selectedItem objectForKey:@"name"] notification:notification];
            }
        }
    }
    
}

- (void)changeCenterPanel:(NSString *)newScreenName notification:(NSNotification *)notification
{
    if ([newScreenName isEqualToString:STRING_HOME])
    {
        if (![[self topViewController] isKindOfClass:[JAHomeViewController class]])
        {
            [self popToRootViewControllerAnimated:YES];
//            JAHomeViewController *home = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"homeViewController"];
            
//            [self pushViewController:home
//                            animated:YES];
//            
//            self.viewControllers = @[home];
        }
    }
    else if ([newScreenName isEqualToString:STRING_MY_FAVOURITES])
    {
        if (![[self topViewController] isKindOfClass:[JAMyFavouritesViewController class]])
        {
            [self showFavoritesViewController:nil];
        }
    }
    else if ([newScreenName isEqualToString:STRING_CHOOSE_COUNTRY])
    {
        if (![[self topViewController] isKindOfClass:[JAChooseCountryViewController class]])
        {
            JAChooseCountryViewController *country = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"chooseCountryViewController"];
            
            [self pushViewController:country animated:YES];
        }
    }
    else if ([newScreenName isEqualToString:STRING_RECENT_SEARCHES])
    {
        if (![[self topViewController] isKindOfClass:[JARecentSearchesViewController class]])
        {
            JARecentSearchesViewController *searches = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"recentSearchesViewController"];
            
            [self pushViewController:searches animated:YES];
            
//            self.viewControllers = @[searches];
        }
    }
    else if ([newScreenName isEqualToString:STRING_LOGIN])
    {
        [self showSignInScreen:nil];
    }
    else if ([newScreenName isEqualToString:STRING_RECENTLY_VIEWED])
    {
        if (![[self topViewController] isKindOfClass:[JARecentlyViewedViewController class]])
        {
            JARecentlyViewedViewController *recentlyViewed = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"recentlyViewedViewController"];
            
            [self pushViewController:recentlyViewed animated:YES];
            
//            self.viewControllers = @[recentlyViewed];
        }
    }
    else if([newScreenName isEqualToString:STRING_MY_ACCOUNT])
    {
        if (![[self topViewController] isKindOfClass:[JAMyAccountViewController class]])
        {
            JAMyAccountViewController *myAccountViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"myAccountViewController"];
            
            [self pushViewController:myAccountViewController animated:YES];
            
//            self.viewControllers = @[myAccountViewController];
        }
    }
    else if ([newScreenName isEqualToString:STRING_TRACK_MY_ORDER])
    {
        [self showTrackOrderViewController:nil];
    }
    else if ([newScreenName isEqualToString:STRING_USER_DATA])
    {
        if([RICustomer checkIfUserIsLogged])
        {
            if (![[self topViewController] isKindOfClass:[JAUserDataViewController class]])
            {
                JAUserDataViewController *userData = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"userDataViewController"];
                
                [self pushViewController:userData animated:YES];
            }
        }
        else
        {
            if (![[self topViewController] isKindOfClass:[JASignInViewController class]])
            {
                JASignInViewController *signInViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"signInViewController"];
                
                signInViewController.fromSideMenu = NO;
                signInViewController.nextNotification = notification;
                
                [self pushViewController:signInViewController animated:YES];
            }
        }
        
    }
    else if ([newScreenName isEqualToString:STRING_USER_EMAIL_NOTIFICATIONS])
    {
        if([RICustomer checkIfUserIsLogged])
        {
            if (![[self topViewController] isKindOfClass:[JAEmailNotificationsViewController class]])
            {
                JAEmailNotificationsViewController *email = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"emailNotificationsViewController"];
                
                [self pushViewController:email animated:YES];
            }
        }
        else
        {
            if (![[self topViewController] isKindOfClass:[JASignInViewController class]])
            {
                JASignInViewController *signInViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"signInViewController"];
                
                signInViewController.fromSideMenu = NO;
                signInViewController.nextNotification = notification;
                
                [self pushViewController:signInViewController animated:YES];
            }
        }
    }
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:newScreenName forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"ActionOverflow" forKey:kRIEventCategoryKey];
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSideMenu]
                                              data:[trackingDictionary copy]];
}

- (void)pushCatalogToShowSearchResults:(NSString *)query
{
    JACatalogViewController *catalog = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"catalogViewController"];
    catalog.searchString = query;
    
    catalog.navBarLayout.title = query;
    
    [self pushViewController:catalog animated:YES];
}

- (void)pushCatalogForUndefinedSearchWithBrandUrl:(NSString *)brandUrl
                                     andBrandName:(NSString *)brandName
{
    JACatalogViewController *catalog = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"catalogViewController"];
    catalog.catalogUrl = brandUrl;
    catalog.forceShowBackButton = YES;
    
    catalog.navBarLayout.title = brandName;
    
    [self pushViewController:catalog animated:YES];
}

- (void)didSelectLeafCategoryInMenu:(NSNotification *)notification
{
    NSDictionary *selectedItem = [notification object];
    RICategory* category = [selectedItem objectForKey:@"category"];
    NSString* categoryId = [selectedItem objectForKey:@"category_id"];
    NSString* categoryName = [selectedItem objectForKey:@"category_name"];
    if (VALID_NOTEMPTY(category, RICategory))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                            object:nil];
        
        JACatalogViewController *catalog = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"catalogViewController"];
        
        catalog.navBarLayout.title = category.name;
        catalog.category = category;
        
        [self pushViewController:catalog animated:YES];
        
//        self.viewControllers = @[catalog];
    }
    else if (VALID_NOTEMPTY(categoryId, NSString))
    {
        JACatalogViewController *catalog = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"catalogViewController"];
        
        catalog.categoryId = categoryId;
        
        [self pushViewController:catalog animated:YES];
        
//        self.viewControllers = @[catalog];
    }
    else if (VALID_NOTEMPTY(categoryName, NSString))
    {
        JACatalogViewController *catalog = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"catalogViewController"];
        
        catalog.categoryName = categoryName;
        
        [self pushViewController:catalog animated:YES];
        
//        self.viewControllers = @[catalog];
    }
}

- (void) closeCurrentScreenNotificaion
{
    [self popViewControllerAnimated:YES];
}

- (void) showHomeScreen
{
    [self changeCenterPanel:STRING_HOME notification:nil];
}

- (void)showFavoritesViewController:(NSNotification*)notification
{
    if (![[self topViewController] isKindOfClass:[JAMyFavouritesViewController class]])
    {
        JAMyFavouritesViewController *favourites = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"myFavouritesViewController"];
        
        [self pushViewController:favourites animated:YES];
        
        //            self.viewControllers = @[favourites];
    }
}

- (void)showTrackOrderViewController:(NSNotification*)notification
{
    if (![[self topViewController] isKindOfClass:[JATrackMyOrderViewController class]])
    {
        JATrackMyOrderViewController *trackOrder = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"jaTrackOrderViewController"];
        
        if (VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY(notification.object, NSString)) {
            trackOrder.startingTrackOrderNumber = notification.object;
        }
        
        [self pushViewController:trackOrder animated:YES];
        
//        self.viewControllers = @[trackOrder];
    }
}

#pragma mark - Teaser Actions

- (void)didSelectTeaserWithCatalogUrl:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSString* url = [notification.userInfo objectForKey:@"url"];
    NSString* title = [notification.userInfo objectForKey:@"title"];
    
    if (VALID_NOTEMPTY(url, NSString)) {
        
        JACatalogViewController *catalog = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"catalogViewController"];
        
        catalog.catalogUrl = url;
        catalog.navBarLayout.title = title;
        catalog.navBarLayout.backButtonTitle = STRING_HOME;
        
        [self pushViewController:catalog animated:YES];
    }
}

- (void)didSelectCampaign:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSArray* campaignTeasers = [notification.userInfo objectForKey:@"campaignTeasers"];
    NSString* title = [notification.userInfo objectForKey:@"title"];
    
    if (VALID_NOTEMPTY(campaignTeasers, NSArray)) {
        
        JACampaignsViewController* campaignsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"campaignsViewController"];
        
        campaignsVC.campaignTeasers = campaignTeasers;
        campaignsVC.startingTitle = title;
        
        [self pushViewController:campaignsVC animated:YES];
    }
}

- (void)didSelectTeaserWithPDVUrl:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSString* url = [notification.userInfo objectForKey:@"url"];
    NSString* productSku = [notification.userInfo objectForKey:@"sku"];
    
    if (VALID_NOTEMPTY(url, NSString) || VALID_NOTEMPTY(productSku, NSString))
    {
        JAPDVViewController *pdv = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"pdvViewController"];
        pdv.productUrl = url;
        pdv.productSku = productSku;
        
        if ([notification.userInfo objectForKey:@"fromCatalog"])
        {
            pdv.fromCatalogue = YES;
            
            if ([notification.userInfo objectForKey:@"relatedItems"]) {
                pdv.arrayWithRelatedItems = [notification.userInfo objectForKey:@"relatedItems"];
            }
            
            if ([notification.userInfo objectForKey:@"delegate"]) {
                pdv.delegate = [notification.userInfo objectForKey:@"delegate"];
            }
        }
        else
        {
            pdv.fromCatalogue = NO;
        }
        
        if ([notification.userInfo objectForKey:@"previousCategory"])
        {
            NSString *previous = [notification.userInfo objectForKey:@"previousCategory"];
            
            if (previous.length > 0) {
                pdv.previousCategory = previous;
            }
        }
        else
        {
            pdv.previousCategory = STRING_HOME;
        }
        
        if ([notification.userInfo objectForKey:@"category"])
        {
            pdv.category = [notification.userInfo objectForKey:@"category"];
        }
        
        // For deeplink
        if ([notification.userInfo objectForKey:@"size"])
        {
            pdv.preSelectedSize = [notification.userInfo objectForKey:@"size"];
        }
        
        if([notification.userInfo objectForKey:@"show_back_button"])
        {
            pdv.showBackButton = [[notification.userInfo objectForKey:@"show_back_button"] boolValue];
        }
        
        [self pushViewController:pdv animated:YES];
    }
}

- (void)didSelectTeaserWithAllCategories:(NSNotification*)notification
{
    JACategoriesViewController* categoriesViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"categoriesViewController"];
    
    categoriesViewController.navBarLayout.title = STRING_ALL_CATEGORIES;
    categoriesViewController.navBarLayout.backButtonTitle = STRING_HOME;
    
    NSDictionary* objectdic = notification.object;
    if (VALID_NOTEMPTY(objectdic, NSDictionary)) {
        RICategory* category = [objectdic objectForKey:@"category"];
        if (VALID_NOTEMPTY(category, RICategory)) {
            categoriesViewController.currentCategory = category;
        }
    }
    
    NSDictionary* infodic = notification.userInfo;
    if (VALID_NOTEMPTY(infodic, NSDictionary)) {
        NSString* backTitle = [infodic objectForKey:@"backButtonTitle"];
        if (VALID_NOTEMPTY(backTitle, NSString)) {
            categoriesViewController.backTitle = backTitle;
        }
    }
    
    [self pushViewController:categoriesViewController animated:YES];
}

- (void)didSelectCategoryFromCenterPanel:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSDictionary *selectedItem = [notification object];
    
    RICategory* category = [selectedItem objectForKey:@"category"];
    if (VALID_NOTEMPTY(category, RICategory)) {
        
        JACatalogViewController *catalog = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"catalogViewController"];
        
        catalog.category = category;
        
        catalog.navBarLayout.title = category.name;
        catalog.navBarLayout.backButtonTitle = STRING_ALL_CATEGORIES;
        
        [self pushViewController:catalog animated:YES];
    }
}

- (void)showSignUpScreen:(NSNotification *)notification
{
    if (![[self topViewController] isKindOfClass:[JASignupViewController class]])
    {
        if(![RICustomer checkIfUserIsLogged])
        {
            JASignupViewController *signUpVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"signUpViewController"];
            
            if(VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"notification"], NSDictionary))
            {
                signUpVC.fromSideMenu = [[notification.userInfo objectForKey:@"from_side_menu"] boolValue];
                signUpVC.nextNotification = [notification.userInfo objectForKey:@"notification"];
            }
            else
            {
                signUpVC.fromSideMenu = YES;
            }
            
            [self pushViewController:signUpVC animated:YES];
        }
    }
}

- (void)showSignInScreen:(NSNotification *)notification
{
    if (![[self topViewController] isKindOfClass:[JASignInViewController class]])
    {
        if(![RICustomer checkIfUserIsLogged])
        {
            JASignInViewController *signInVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"signInViewController"];
            
            if(VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"notification"], NSDictionary))
            {
                signInVC.fromSideMenu = [[notification.userInfo objectForKey:@"from_side_menu"] boolValue];
                signInVC.nextNotification = [notification.userInfo objectForKey:@"notification"];
            }
            else
            {
                signInVC.fromSideMenu = YES;
            }
            
            [self pushViewController:signInVC animated:YES];
        }
    }
}

- (void)showForgotPasswordScreen
{
    if (![[self topViewController] isKindOfClass:[JAForgotPasswordViewController class]])
    {
        JAForgotPasswordViewController *forgotVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"forgotPasswordViewController"];
        
        forgotVC.navBarLayout.backButtonTitle = STRING_LOGIN;
        
        [self pushViewController:forgotVC animated:YES];
    }
}

- (void)showCheckoutLoginScreen
{
    JALoginViewController *loginVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginViewController"];
    
    [self pushViewController:loginVC animated:YES];
}

- (void)showCheckoutForgotPasswordScreen
{
    JAForgotPasswordViewController *forgotVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"forgotPasswordViewController"];
    
    forgotVC.navBarLayout.backButtonTitle = STRING_CHECKOUT;
    
    [self pushViewController:forgotVC animated:YES];
}

- (void)showCheckoutAddressesScreen
{
    JAAddressesViewController *addressesVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addressesViewController"];
    
    [self pushViewController:addressesVC animated:YES];
}

- (void)showCheckoutAddAddressScreen:(NSNotification*)notification
{
    JAAddNewAddressViewController *addAddressVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"addNewAddressViewController"];
    
    NSNumber* isBillingAddress = [notification.userInfo objectForKey:@"is_billing_address"];
    NSNumber* isShippingAddress = [notification.userInfo objectForKey:@"is_shipping_address"];
    NSNumber* showBackButton = [notification.userInfo objectForKey:@"show_back_button"];
    
    addAddressVC.isBillingAddress = [isBillingAddress boolValue];
    addAddressVC.isShippingAddress = [isShippingAddress boolValue];
    addAddressVC.showBackButton = [showBackButton boolValue];
    
    [self pushViewController:addAddressVC animated:YES];
}

- (void)showCheckoutEditAddressScreen:(NSNotification*)notification
{
    JAEditAddressViewController *editAddressVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"editAddressViewController"];
    
    RIAddress* editAddress = [notification.userInfo objectForKey:@"address_to_edit"];
    editAddressVC.editAddress = editAddress;
    
    [self pushViewController:editAddressVC animated:YES];
}

- (void)showCheckoutShippingScreen
{
    JAShippingViewController *shippingVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"shippingViewController"];
    
    [self pushViewController:shippingVC animated:YES];
}

- (void)showCheckoutPaymentScreen
{
    JAPaymentViewController *paymentVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"paymentViewController"];
    
    [self pushViewController:paymentVC animated:YES];
}

- (void)showCheckoutFinishScreen:(NSNotification*)notification
{
    JAOrderViewController *orderVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"orderViewController"];
    
    if (VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY(notification.object, RICheckout)) {
        orderVC.checkout = notification.object;
    }
    
    [self pushViewController:orderVC animated:YES];
}

- (void)showCheckoutExternalPaymentsScreen:(NSNotification *)notification
{
    self.neeedsExternalPaymentMethod = YES;
    
    JAExternalPaymentsViewController *externalPaymentsVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"externalPaymentsViewController"];
    
    externalPaymentsVC.checkout = [notification.userInfo objectForKey:@"checkout"];
    externalPaymentsVC.paymentInformation = [notification.userInfo objectForKey:@"payment_information"];
    
    [self pushViewController:externalPaymentsVC animated:YES];
}

- (void)showCheckoutThanksScreen:(NSNotification *)notification
{
    self.neeedsExternalPaymentMethod = NO;
    
    JAThanksViewController *thanksVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"thanksViewController"];
    
    thanksVC.checkout = [notification.userInfo objectForKey:@"checkout"];
    thanksVC.orderNumber = [notification.userInfo objectForKey:@"order_number"];
    
    [self pushViewController:thanksVC animated:YES];
}

- (void)deactivateExternalPayment
{
    self.neeedsExternalPaymentMethod = NO;
}

#pragma mark - Choose Country

- (void)didSelectCountry:(NSNotification*)notification
{
    RICountry *country = notification.object;
//    if (VALID_NOTEMPTY(country, RICountry)) {
        UINavigationController* rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
        
        JASplashViewController *splash = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"splashViewController"];
        splash.selectedCountry = country;
        splash.tempNotification = notification.userInfo;
        
        [self pushViewController:splash animated:NO];
        
        rootViewController.viewControllers = @[splash];
        [[[UIApplication sharedApplication] delegate] window].rootViewController = rootViewController;
//    }
}

#pragma mark - Recent Search

- (void)didSelectRecentSearch:(NSNotification*)notification
{
    RISearchSuggestion *recentSearch = notification.object;
    
    if (VALID_NOTEMPTY(recentSearch, RISearchSuggestion)) {
        JACatalogViewController *catalog = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"catalogViewController"];
        catalog.searchString = recentSearch.item;
        
        catalog.navBarLayout.title = recentSearch.item;
        
        [self pushViewController:catalog animated:YES];
    }
}

#pragma mark - Navigation Bar

- (void)customizeNavigationBar
{
    [self.navigationItem setHidesBackButton:YES
                                   animated:NO];
    
    self.navigationBarView = [JANavigationBarView getNewNavBarView];
    [self.navigationBarView initialSetup];
    
    [self.navigationBar.viewForBaselineLayout addSubview:self.navigationBarView];
    
    [self.navigationBarView.cartButton addTarget:self
                                          action:@selector(openCart)
                                forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView.leftButton addTarget:self
                                          action:@selector(openMenu)
                                forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView.doneButton addTarget:self
                                          action:@selector(done)
                                forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView.editButton addTarget:self
                                          action:@selector(edit)
                                forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView.backButton addTarget:self
                                          action:@selector(back)
                                forControlEvents:UIControlEventTouchUpInside];
}

- (void)changeNavigationWithNotification:(NSNotification*)notification
{
    JANavigationBarLayout* layout = notification.object;
    if (VALID_NOTEMPTY(layout, JANavigationBarLayout)) {
        [self.navigationBarView setupWithNavigationBarLayout:layout];
    }
}

- (void)changeEditButtonState:(NSNotification *)notification
{
    NSNumber* state = [notification.userInfo objectForKey:@"enabled"];
    self.navigationBarView.editButton.enabled = [state boolValue];
}

- (void)changeDoneButtonState:(NSNotification *)notification
{
    NSNumber* state = [notification.userInfo objectForKey:@"enabled"];
    self.navigationBarView.doneButton.enabled = [state boolValue];
}

- (void)updateCart:(NSNotification*) notification
{
    NSMutableDictionary* userInfo = nil;
    if(VALID_NOTEMPTY(notification, NSNotification))
    {
        userInfo = [[NSMutableDictionary alloc] initWithDictionary:notification.userInfo];
        
        if(VALID_NOTEMPTY([userInfo objectForKey:kUpdateCartNotificationValue], RICart))
        {
            self.cart = [userInfo objectForKey:kUpdateCartNotificationValue];
        }
        else
        {
            self.cart = nil;
        }
        
        if(VALID_NOTEMPTY(self.cart, RICart))
        {
            [self.navigationBarView updateCartProductCount:self.cart.cartCount];
        }
        else
        {
            [userInfo removeObjectForKey:kUpdateCartNotificationValue];
            [self.navigationBarView updateCartProductCount:0];
        }
    }
    else
    {
        self.cart = nil;
        [self.navigationBarView updateCartProductCount:0];
    }
    
    // post side menu notification;
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateSideMenuCartNotification object:nil userInfo:userInfo];
}

#pragma mark - Navbar Button actions

- (void)back
{
    [self popViewControllerAnimated:YES];
}

- (void)done
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidPressDoneNotification
                                                        object:nil];
    [self back];
}

- (void)edit
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidPressEditNotification
                                                        object:nil];
}

- (void)openCart
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    if (![[self topViewController] isKindOfClass:[JACartViewController class]])
    {
        JACartViewController *cartViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"cartViewController"];
        [cartViewController setCart:self.cart];
        
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:cartViewController animated:YES];
    }
    
}

- (void)openMenu
{
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];;
    
    if(VALID_NOTEMPTY(self.cart, RICart))
    {
        [userInfo setObject:self.cart forKey:kUpdateCartNotificationValue];
    }
    
    [userInfo setObject:[NSNumber numberWithBool:self.neeedsExternalPaymentMethod] forKey:kExternalPaymentValue];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenMenuNotification
                                                        object:nil
                                                      userInfo:[userInfo copy]];
}

@end
