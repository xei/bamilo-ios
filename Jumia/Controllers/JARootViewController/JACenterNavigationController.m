//
//  JACenterNavigationController.m
//  Jumia
//
//  Created by Miguel Chaves on 31/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACenterNavigationController.h"
#import "JANavigationBarView.h"

#import "JAChooseCountryViewController.h"
#import "JAHomeViewController.h"
#import "JALoadCountryViewController.h"
#import "JAMyFavouritesViewController.h"
#import "JARecentSearchesViewController.h"
#import "JARecentlyViewedViewController.h"
#import "JAMyAccountViewController.h"
#import "JAUserDataViewController.h"
#import "JAEmailNotificationsViewController.h"
#import "JAMyOrdersViewController.h"
#import "JASignInViewController.h"
#import "JASignupViewController.h"
#import "JAForgotPasswordViewController.h"
#import "JALoginViewController.h"
#import "JAAddressesViewController.h"
#import "JAAddNewAddressViewController.h"
#import "JAEditAddressViewController.h"
#import "JAShippingViewController.h"
#import "JAPaymentViewController.h"
#import "JAOrderViewController.h"
#import "JACatalogViewController.h"
#import "JAPDVViewController.h"
#import "JACategoriesViewController.h"
#import "JARecentlyViewedViewController.h"
#import "JACartViewController.h"
#import "JAForgotPasswordViewController.h"
#import "JALoginViewController.h"
#import "JAExternalPaymentsViewController.h"
#import "JAThanksViewController.h"
#import "RIProduct.h"
#import "RISeller.h"
#import "JANavigationBarLayout.h"
#import "RICustomer.h"
#import "JAUserDataViewController.h"
#import "JAEmailNotificationsViewController.h"
#import "JACampaignsViewController.h"
#import "JAPriceFilterViewController.h"
#import "JAGenericFilterViewController.h"
#import "JAProductDetailsViewController.h"
#import "JARatingsViewController.h"
#import "JANewRatingViewController.h"
#import "JASubCategoriesViewController.h"
#import "RICart.h"
#import "JASizeGuideViewController.h"
#import "JAOtherOffersViewController.h"
#import "JASellerRatingsViewController.h"
#import "JANewSellerRatingViewController.h"
#import "JAShopWebViewController.h"

@interface JACenterNavigationController ()

@property (strong, nonatomic) RICart *cart;
@property (assign, nonatomic) BOOL neeedsExternalPaymentMethod;
@property (strong, nonatomic) UIStoryboard *mainStoryboard;

@end

@implementation JACenterNavigationController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.neeedsExternalPaymentMethod = NO;
    
    [self customizeNavigationBar];
    
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showLoadCountryScreen:)
                                                 name:kSelectedCountryNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showChooseCountry:)
                                                 name:kShowChooseCountryScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showHomeScreen:)
                                                 name:kShowHomeScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showFavoritesViewController:)
                                                 name:kShowFavoritesScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showRecentSearchesController:)
                                                 name:kShowRecentSearchesScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showRecentlyViewedController)
                                                 name:kShowRecentlyViewedScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMyAccountController)
                                                 name:kShowMyAccountScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showUserData:)
                                                 name:kShowUserDataScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showEmailNotificaitons:)
                                                 name:kShowEmailNotificationsScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showMyOrdersViewController:)
                                                 name:kShowMyOrdersScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSignInScreen:)
                                                 name:kShowSignInScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSignUpScreen:)
                                                 name:kShowSignUpScreenNotification
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
                                             selector:@selector(showCheckoutAddressesScreen:)
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
                                             selector:@selector(didSelectTeaserWithShopUrl:)
                                                 name:kDidSelectTeaserWithShopUrlNofication
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
                                             selector:@selector(closeCurrentScreenNotificaion:)
                                                 name:kCloseCurrentScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(closeTopTwoScreensNotificaion:)
                                                 name:kCloseTopTwoScreensNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeNavigationWithNotification:)
                                                 name:kChangeNavigationBarNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deactivateExternalPayment)
                                                 name:kDeactivateExternalPaymentNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showFiltersScreen:)
                                                 name:kShowFiltersScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showPriceFiltersScreen:)
                                                 name:kShowPriceFiltersScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showGenericFiltersScreen:)
                                                 name:kShowGenericFiltersScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showProductSpecificationScreen:)
                                                 name:kShowProductSpecificationScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showRatingsScreen:)
                                                 name:kShowRatingsScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNewRatingScreen:)
                                                 name:kShowNewRatingScreenNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSizeGuide:)
                                                 name:kShowSizeGuideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showOtherOffers:)
                                                 name:kOpenOtherOffers
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSellerReviews:)
                                                 name:kOpenSellerReviews
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNewSellerReview:)
                                                 name:kOpenNewSellerReview
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSellerCatalog:)
                                                 name:kOpenSellerPage
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showSpecificationsScreen:)
                                                 name:kOpenSpecificationsScreen
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Home Screen
- (void)showHomeScreen:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAHomeViewController class]])
    {
        if(VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY([notification object], NSDictionary))
        {
            [self showRootViewController];
        } else {
            [self popToRootViewControllerAnimated:NO];
        }
        
        JAHomeViewController *home = [JAHomeViewController new];
        [self pushViewController:home animated:NO];
    }
}

- (void)showRootViewController
{
    JABaseViewController* rootViewController = [[JABaseViewController alloc] init];
    [self setViewControllers:@[rootViewController]];
}

- (void)showChooseCountry:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAChooseCountryViewController class]])
    {
        JAChooseCountryViewController *country = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"chooseCountryViewController"];
        
        country.navBarLayout.showMenuButton = NO;
        if(VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY(notification.object, NSDictionary))
        {
            country.navBarLayout.showMenuButton = [[notification.object objectForKey:@"show_menu_button"] boolValue];
        }
        
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:country animated:NO];
    }
}

- (void)showLoadCountryScreen:(NSNotification*)notification
{
    JALoadCountryViewController *loadCountry = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"loadCountryViewController"];
    
    loadCountry.selectedCountry = notification.object;
    loadCountry.pushNotification = notification.userInfo;
    
    [self setViewControllers:@[loadCountry]];
}

#pragma mark - Left Menu Actions

- (void)didSelectItemInMenu:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSDictionary *selectedItem = [notification object];
    
    if ([selectedItem objectForKey:@"index"]) {
        NSNumber *index = [selectedItem objectForKey:@"index"];
        
        if ([index isEqual:@(0)])
        {
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
        [self showHomeScreen:nil];
    }
    else if ([newScreenName isEqualToString:STRING_MY_FAVOURITES])
    {
        [self showFavoritesViewController:nil];
    }
    else if ([newScreenName isEqualToString:STRING_CHOOSE_COUNTRY])
    {
        [self showChooseCountry:[NSNotification notificationWithName:kShowChooseCountryScreenNotification
                                                              object:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"show_menu_button"]]];
    }
    else if ([newScreenName isEqualToString:STRING_RECENT_SEARCHES])
    {
        [self showRecentSearchesController:nil];
    }
    else if ([newScreenName isEqualToString:STRING_LOGIN])
    {
        [self showSignInScreen:nil];
    }
    else if ([newScreenName isEqualToString:STRING_RECENTLY_VIEWED])
    {
        [self showRecentlyViewedController];
    }
    else if([newScreenName isEqualToString:STRING_MY_ACCOUNT])
    {
        [self showMyAccountController];
    }
    else if ([newScreenName isEqualToString:STRING_MY_ORDERS])
    {
        [self showMyOrdersViewController:nil];
    }
    else if ([newScreenName isEqualToString:STRING_USER_DATA])
    {
        [self showUserData:nil];
    }
    else if ([newScreenName isEqualToString:STRING_USER_EMAIL_NOTIFICATIONS])
    {
        [self showEmailNotificaitons:nil];
    }
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:newScreenName forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"ActionOverflow" forKey:kRIEventCategoryKey];
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSideMenu]
                                              data:[trackingDictionary copy]];
}

#pragma mark Favorites Screen
- (void)showFavoritesViewController:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAMyFavouritesViewController class]])
    {
        JAMyFavouritesViewController *favourites = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"myFavouritesViewController"];
        
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:favourites animated:NO];
    }
}

#pragma mark Recent Searches Screen
- (void)showRecentSearchesController:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JARecentSearchesViewController class]])
    {
        JARecentSearchesViewController *recentSearches = [[JARecentSearchesViewController alloc] initWithNibName:@"JARecentSearchesViewController" bundle:nil];
        
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:recentSearches animated:NO];
    }
}

#pragma mark Sign In Screen
- (void)showSignInScreen:(NSNotification *)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JASignInViewController class]] && ![RICustomer checkIfUserIsLogged])
    {
        JASignInViewController *signInVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"signInViewController"];
        
        if(VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"notification"], NSNotification))
        {
            NSNumber *fromSideMenu = [notification.userInfo objectForKey:@"from_side_menu"];
            signInVC.navBarLayout.showBackButton = ![fromSideMenu boolValue];
            signInVC.fromSideMenu = [fromSideMenu boolValue];
            signInVC.nextNotification = [notification.userInfo objectForKey:@"notification"];
        }
        else
        {
            signInVC.fromSideMenu = YES;
            [self popToRootViewControllerAnimated:NO];
        }
        
        [self pushViewController:signInVC animated:NO];
    }
}

#pragma mark Sign Up Screen
- (void)showSignUpScreen:(NSNotification *)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JASignupViewController class]] && ![RICustomer checkIfUserIsLogged])
    {
        JASignupViewController *signUpVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"signUpViewController"];
        
        if(VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"notification"], NSNotification))
        {
            signUpVC.navBarLayout.showBackButton = ![[notification.userInfo objectForKey:@"from_side_menu"] boolValue];
            signUpVC.fromSideMenu = [[notification.userInfo objectForKey:@"from_side_menu"] boolValue];
            signUpVC.nextNotification = [notification.userInfo objectForKey:@"notification"];
            [self popViewControllerAnimated:NO];
        }
        else
        {
            signUpVC.fromSideMenu = YES;
            [self popToRootViewControllerAnimated:NO];
        }
        
        [self pushViewController:signUpVC animated:NO];
    }
}

#pragma mark Forgot Password Screen
- (void)showForgotPasswordScreen
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JASignupViewController class]] && ![RICustomer checkIfUserIsLogged])
    {
        JAForgotPasswordViewController *forgotVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"forgotPasswordViewController"];
        
        [forgotVC.navBarLayout setShowBackButton:YES];
        
        [self pushViewController:forgotVC animated:YES];
    }
}

#pragma mark Recently Viewed Screen
- (void)showRecentlyViewedController
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JARecentlyViewedViewController class]])
    {
        JARecentlyViewedViewController *recentlyViewed = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"recentlyViewedViewController"];
        
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:recentlyViewed animated:NO];
    }
}

#pragma mark My Account Screen
- (void)showMyAccountController
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAMyAccountViewController class]])
    {
        JAMyAccountViewController *myAccountViewController = [[JAMyAccountViewController alloc]initWithNibName:@"JAMyAccountViewController" bundle:nil];
        if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()){
            
            myAccountViewController = [[JAMyAccountViewController alloc] initWithNibName:@"JAMyAccountViewController~iPad" bundle:nil];
        
        }
        [self pushViewController:myAccountViewController animated:NO];
    }
}

#pragma mark Track Order Screen
- (void)showMyOrdersViewController:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAMyOrdersViewController class]])
    {
        JAMyOrdersViewController *myOrderVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"jAMyOrdersViewController"];
        
        NSString* orderNumber = notification.object;
        if (VALID_NOTEMPTY(orderNumber, NSString))
        {
            myOrderVC.selectedIndex = 0;
            myOrderVC.startingTrackOrderNumber = orderNumber;
        }

        NSDictionary *userInfo = notification.userInfo;
        if(VALID_NOTEMPTY(userInfo, NSDictionary) && VALID_NOTEMPTY([userInfo objectForKey:@"selected_index"], NSNumber))
        {
            myOrderVC.selectedIndex = [[userInfo objectForKey:@"selected_index"] intValue];
        }        
        
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:myOrderVC animated:NO];
    }
    else
    {
        JAMyOrdersViewController *myOrderVC = (JAMyOrdersViewController*) topViewController;
        NSDictionary *userInfo = notification.userInfo;
        if(VALID_NOTEMPTY(userInfo, NSDictionary) && VALID_NOTEMPTY([userInfo objectForKey:@"selected_index"], NSNumber))
        {
            myOrderVC.selectedIndex = [[userInfo objectForKey:@"selected_index"] intValue];
        }
    }
}

- (void)showSpecificationsScreen:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAProductDetailsViewController class]])
    {
        JAProductDetailsViewController *productDetails = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"JAProductDetailsViewController"];
        
        NSString* orderNumber = notification.object;
        if (VALID_NOTEMPTY(orderNumber, NSString))
        {
            productDetails.selectedIndex = 0;
            productDetails.startingTrackOrderNumber = orderNumber;
        }
        
        NSDictionary *userInfo = notification.userInfo;
        if(VALID_NOTEMPTY(userInfo, NSDictionary) && VALID_NOTEMPTY([userInfo objectForKey:@"selected_index"], NSNumber))
        {
            productDetails.selectedIndex = [[userInfo objectForKey:@"selected_index"] intValue];
        }
        
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:productDetails animated:NO];
    }
    else
    {
        JAProductDetailsViewController *productDetails = (JAProductDetailsViewController*) topViewController;
        NSDictionary *userInfo = notification.userInfo;
        if(VALID_NOTEMPTY(userInfo, NSDictionary) && VALID_NOTEMPTY([userInfo objectForKey:@"selected_index"], NSNumber))
        {
            productDetails.selectedIndex = [[userInfo objectForKey:@"selected_index"] intValue];
        }
    }
}


#pragma mark User Data Screen
- (void)showUserData:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if([RICustomer checkIfUserIsLogged])
    {
        if (![topViewController isKindOfClass:[JAUserDataViewController class]])
        {
            BOOL animated = NO;
            if(VALID_NOTEMPTY(notification.object, NSDictionary) && VALID_NOTEMPTY([notification.object objectForKey:@"animated"], NSNumber))
            {
                animated = [[notification.object objectForKey:@"animated"] boolValue];
            }
            
            JAUserDataViewController *userData = [[JAUserDataViewController alloc] initWithNibName:@"JAUserDataViewController" bundle:nil];
            
            if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            
                userData = [[JAUserDataViewController alloc] initWithNibName:@"JAUserDataViewController~iPad" bundle:nil];
                
            }
            
            [self pushViewController:userData animated:animated];
        }
    }
    else
    {
        if (![topViewController isKindOfClass:[JASignInViewController class]])
        {
            JASignInViewController *signInViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"signInViewController"];
            
            signInViewController.navBarLayout.showBackButton = YES;
            signInViewController.fromSideMenu = NO;
            signInViewController.nextNotification = notification;
            
            [self pushViewController:signInViewController animated:NO];
        }
    }
}

#pragma mark Email Notifications Screen
-(void)showEmailNotificaitons:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if([RICustomer checkIfUserIsLogged])
    {
        if (![topViewController isKindOfClass:[JAEmailNotificationsViewController class]])
        {
            BOOL animated = NO;
            if(VALID_NOTEMPTY(notification.object, NSDictionary) && VALID_NOTEMPTY([notification.object objectForKey:@"animated"], NSNumber))
            {
                animated = [[notification.object objectForKey:@"animated"] boolValue];
            }
            
            JAEmailNotificationsViewController *email = [[JAEmailNotificationsViewController alloc]init];
            
            [self pushViewController:email animated:animated];
        }
    }
    else
    {
        if (![topViewController isKindOfClass:[JASignInViewController class]])
        {
            JASignInViewController *signInViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"signInViewController"];
            
            signInViewController.navBarLayout.showBackButton = YES;
            signInViewController.fromSideMenu = NO;
            signInViewController.nextNotification = notification;
            
            [self pushViewController:signInViewController animated:NO];
        }
    }
}

#pragma mark Checkout Login Screen
- (void)showCheckoutLoginScreen
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JALoginViewController class]] && ![RICustomer checkIfUserIsLogged])
    {
        JALoginViewController *loginVC = [[JALoginViewController alloc] initWithNibName:@"JALoginViewController" bundle:nil];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            loginVC = [[JALoginViewController alloc] initWithNibName:@"JALoginViewController~iPad" bundle:nil];
        }
        
        loginVC.cart = self.cart;
        
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:loginVC animated:NO];
    }
}

#pragma mark Checkout Forgot Password Screen
- (void)showCheckoutForgotPasswordScreen
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAForgotPasswordViewController class]] && ![RICustomer checkIfUserIsLogged])
    {
        
        JAForgotPasswordViewController *forgotVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"forgotPasswordViewController"];
        
        [forgotVC.navBarLayout setShowBackButton:YES];
        
        [self pushViewController:forgotVC animated:YES];
    }
}

#pragma mark Checkout Addresses Screen
- (void)showCheckoutAddressesScreen:(NSNotification*)notification
{
    BOOL animated = NO;
    if(VALID_NOTEMPTY(notification.object, NSDictionary) && VALID_NOTEMPTY([notification.object objectForKey:@"animated"], NSNumber))
    {
        animated = [[notification.object objectForKey:@"animated"] boolValue];
    }
    
    BOOL fromCheckout = YES;
    if(VALID_NOTEMPTY(notification.userInfo, NSDictionary) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"from_checkout"], NSNumber))
    {
        fromCheckout = [[notification.userInfo objectForKey:@"from_checkout"] boolValue];
    }
    
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAAddressesViewController class]] && [RICustomer checkIfUserIsLogged])
    {
        JAAddressesViewController *addressesVC = [[JAAddressesViewController alloc] initWithNibName:@"JAAddressesViewController" bundle:nil];
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            addressesVC = [[JAAddressesViewController alloc] initWithNibName:@"JAAddressesViewController~iPad" bundle:nil];
        
        }
        
        addressesVC.cart = self.cart;
        addressesVC.fromCheckout = fromCheckout;
        
        if(fromCheckout)
        {
            addressesVC.navBarLayout.showCartButton = NO;
            addressesVC.navBarLayout.title = STRING_CHECKOUT;
        }
        else
        {
            [addressesVC.navBarLayout setShowBackButton:YES];
            addressesVC.navBarLayout.showLogo = NO;
        }

        [self pushViewController:addressesVC animated:NO];
    }
    else
    {
        if (!fromCheckout && ![topViewController isKindOfClass:[JASignInViewController class]])
        {
            JASignInViewController *signInViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"signInViewController"];
            
            signInViewController.navBarLayout.showBackButton = YES;
            signInViewController.fromSideMenu = NO;
            signInViewController.nextNotification = notification;
            
            [self pushViewController:signInViewController animated:NO];
        }
    }
}

#pragma mark Checkout Add Address Screen
- (void)showCheckoutAddAddressScreen:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAAddNewAddressViewController class]] && [RICustomer checkIfUserIsLogged])
    {
        JAAddNewAddressViewController *addAddressVC = [[JAAddNewAddressViewController alloc]initWithNibName:@"JAAddNewAddressViewController" bundle:nil];
        
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
            
            addAddressVC = [[JAAddNewAddressViewController alloc]initWithNibName:@"JAAddNewAddressViewController~iPad" bundle:nil];
        }
        
        NSNumber* isBillingAddress = [notification.userInfo objectForKey:@"is_billing_address"];
        NSNumber* isShippingAddress = [notification.userInfo objectForKey:@"is_shipping_address"];
        NSNumber* showBackButton = [notification.userInfo objectForKey:@"show_back_button"];
        NSNumber* fromCheckout = [notification.userInfo objectForKey:@"from_checkout"];
        
        addAddressVC.isBillingAddress = [isBillingAddress boolValue];
        addAddressVC.isShippingAddress = [isShippingAddress boolValue];
        addAddressVC.fromCheckout = [fromCheckout boolValue];
        addAddressVC.cart = self.cart;

        if([fromCheckout boolValue])
        {
            addAddressVC.navBarLayout.showCartButton = NO;
            if([showBackButton boolValue])
            {
                [addAddressVC.navBarLayout setShowBackButton:YES];
                addAddressVC.navBarLayout.showLogo = NO;
            }
            else
            {
                addAddressVC.navBarLayout.title = STRING_CHECKOUT;
            }
        }
        else
        {
            [addAddressVC.navBarLayout setShowBackButton:YES];
            addAddressVC.navBarLayout.showLogo = NO;
        }
        
        [self pushViewController:addAddressVC animated:YES];
    }
}

#pragma mark Checkout Edit Address Screen
- (void)showCheckoutEditAddressScreen:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAEditAddressViewController class]] && [RICustomer checkIfUserIsLogged])
    {
        JAEditAddressViewController *editAddressVC = [[JAEditAddressViewController alloc] initWithNibName:@"JAEditAddressViewController" bundle:nil];
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            editAddressVC = [[JAEditAddressViewController alloc] initWithNibName:@"JAEditAddressesViewController~iPad" bundle:nil];
        }
        
        NSNumber* fromCheckout = [notification.userInfo objectForKey:@"from_checkout"];
        
        RIAddress* editAddress = [notification.userInfo objectForKey:@"address_to_edit"];
        editAddressVC.editAddress = editAddress;
        editAddressVC.cart = self.cart;
        editAddressVC.fromCheckout = [fromCheckout boolValue];
        
        if([fromCheckout boolValue])
        {
            editAddressVC.navBarLayout.showCartButton = NO;
            editAddressVC.navBarLayout.title = STRING_CHECKOUT;
        }
        else
        {
            [editAddressVC.navBarLayout setShowBackButton:YES];
            editAddressVC.navBarLayout.showLogo = NO;
        }
        
        [self pushViewController:editAddressVC animated:YES];
    }
}

#pragma mark Checkout Shipping Screen
- (void)showCheckoutShippingScreen
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAShippingViewController class]] && [RICustomer checkIfUserIsLogged])
    {
        JAShippingViewController *shippingVC = [[JAShippingViewController alloc] initWithNibName:@"JAShippingViewController" bundle:nil];
        
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            shippingVC = [[JAShippingViewController alloc] initWithNibName:@"JAShippingViewController~iPad" bundle:nil];
        }
        
        [self pushViewController:shippingVC animated:YES];
    }
}

#pragma mark Checkout Payment Screen
- (void)showCheckoutPaymentScreen
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAPaymentViewController class]] && [RICustomer checkIfUserIsLogged])
    {
        JAPaymentViewController *paymentVC = [[JAPaymentViewController alloc] initWithNibName:@"JAPaymentViewController" bundle:nil];
        
        if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
        {
            paymentVC = [[JAPaymentViewController alloc] initWithNibName:@"JAPaymentViewController~iPad" bundle:nil];
        
        }
        
        [self pushViewController:paymentVC animated:YES];
    }
}

#pragma mark Checkout Finish Screen
- (void)showCheckoutFinishScreen:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAOrderViewController class]] && [RICustomer checkIfUserIsLogged])
    {
        JAOrderViewController *orderVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"orderViewController"];
        
        if (VALID_NOTEMPTY(notification, NSNotification) && VALID_NOTEMPTY(notification.object, RICheckout)) {
            orderVC.checkout = notification.object;
        }
        
        [self pushViewController:orderVC animated:YES];
    }
}

#pragma mark Checkout External Payments Screen
- (void)showCheckoutExternalPaymentsScreen:(NSNotification *)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAExternalPaymentsViewController class]] && [RICustomer checkIfUserIsLogged])
    {
        self.neeedsExternalPaymentMethod = YES;
        
        JAExternalPaymentsViewController *externalPaymentsVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"externalPaymentsViewController"];
        
        externalPaymentsVC.checkout = [notification.userInfo objectForKey:@"checkout"];
        externalPaymentsVC.paymentInformation = [notification.userInfo objectForKey:@"payment_information"];
        
        [self pushViewController:externalPaymentsVC animated:YES];
    }
}

#pragma mark Checkout Thanks Screen
- (void)showCheckoutThanksScreen:(NSNotification *)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAThanksViewController class]] && [RICustomer checkIfUserIsLogged])
    {
        self.neeedsExternalPaymentMethod = NO;
        
        JAThanksViewController *thanksVC = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"thanksViewController"];
        
        thanksVC.cart = self.cart;
        thanksVC.checkout = [notification.userInfo objectForKey:@"checkout"];
        thanksVC.orderNumber = [notification.userInfo objectForKey:@"order_number"];
        
        [self pushViewController:thanksVC animated:YES];
    }
}

- (void)deactivateExternalPayment
{
    self.neeedsExternalPaymentMethod = NO;
}

#pragma mark Catalog Screen
- (void)pushCatalogToShowSearchResults:(NSString *)query
{
    JACatalogViewController *catalog = [[JACatalogViewController alloc] initWithNibName:@"JACatalogViewController" bundle:nil];
    catalog.searchString = query;
    
    catalog.navBarLayout.title = query;
    
    [self pushViewController:catalog animated:YES];
}

- (void)pushCatalogForUndefinedSearchWithBrandUrl:(NSString *)brandUrl
                                     andBrandName:(NSString *)brandName
{
    JACatalogViewController *catalog = [[JACatalogViewController alloc] initWithNibName:@"JACatalogViewController" bundle:nil];
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
    NSString* filterType = [notification.userInfo objectForKey:@"filter_type"];
    NSString* filterValue = [notification.userInfo objectForKey:@"filter_value"];
    NSNumber* sorting = [notification.userInfo objectForKey:@"sorting"];
    
    if (VALID_NOTEMPTY(category, RICategory))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                            object:nil];
        
        JACatalogViewController *catalog = [[JACatalogViewController alloc] initWithNibName:@"JACatalogViewController" bundle:nil];
        
        catalog.navBarLayout.title = category.name;
        catalog.category = category;
        
        [self pushViewController:catalog animated:YES];
    }
    else if (VALID_NOTEMPTY(categoryId, NSString))
    {
        JACatalogViewController *catalog = [[JACatalogViewController alloc] initWithNibName:@"JACatalogViewController" bundle:nil];
        
        catalog.categoryId = categoryId;
        
        [self pushViewController:catalog animated:YES];
    }
    else if (VALID_NOTEMPTY(categoryName, NSString))
    {
        JACatalogViewController *catalog = [[JACatalogViewController alloc] initWithNibName:@"JACatalogViewController" bundle:nil];
        
        catalog.categoryName = categoryName;
        catalog.filterType = filterType;
        catalog.filterValue = filterValue;
        catalog.sortingMethodFromPush = sorting;
        
        [self pushViewController:catalog animated:YES];
    }
}

#pragma mark - Filters
- (void)showFiltersScreen:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAMainFiltersViewController class]])
    {
        JAMainFiltersViewController *mainFiltersViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"mainFiltersViewController"];
        
        if ([notification.userInfo objectForKey:@"filtersArray"]) {
            mainFiltersViewController.filtersArray = [notification.userInfo objectForKey:@"filtersArray"];
        }
        if ([notification.userInfo objectForKey:@"delegate"]) {
            mainFiltersViewController.delegate = [notification.userInfo objectForKey:@"delegate"];
        }
        
        [self pushViewController:mainFiltersViewController animated:YES];
    }
}

- (void)showPriceFiltersScreen:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAPriceFilterViewController class]])
    {
        JAPriceFilterViewController* priceFilterViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"priceFilterViewController"];
        
        if ([notification.userInfo objectForKey:@"priceFilterOption"]) {
            priceFilterViewController.priceFilterOption = [notification.userInfo objectForKey:@"priceFilterOption"];
        }
        if ([notification.userInfo objectForKey:@"delegate"]) {
            priceFilterViewController.delegate = [notification.userInfo objectForKey:@"delegate"];
        }
        
        [self pushViewController:priceFilterViewController animated:YES];
    }
}

- (void)showGenericFiltersScreen:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAGenericFilterViewController class]])
    {
        JAGenericFilterViewController* genericFilterViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"genericFilterViewController"];
        
        if ([notification.userInfo objectForKey:@"filter"]) {
            genericFilterViewController.filter = [notification.userInfo objectForKey:@"filter"];
        }
        if ([notification.userInfo objectForKey:@"delegate"]) {
            genericFilterViewController.delegate = [notification.userInfo objectForKey:@"delegate"];
        }
        
        [self pushViewController:genericFilterViewController animated:YES];
    }
}

- (void)showProductSpecificationScreen:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAProductDetailsViewController class]])
    {
        JAProductDetailsViewController *productDetailsViewController = [[JAProductDetailsViewController alloc] initWithNibName:@"JAProductDetailsViewController" bundle:nil];
        
        if ([notification.userInfo objectForKey:@"product"]) {
            productDetailsViewController.product = [notification.userInfo objectForKey:@"product"];
        }
        
        [self pushViewController:productDetailsViewController animated:YES];
    }
}

- (void)showRatingsScreen:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JARatingsViewController class]])
    {
        JARatingsViewController *ratingsViewController = [[JARatingsViewController alloc] initWithNibName:@"JARatingsViewController" bundle:nil];
        
        if ([notification.userInfo objectForKey:@"product"]) {
            ratingsViewController.product = [notification.userInfo objectForKey:@"product"];
        }
        
        if ([notification.userInfo objectForKey:@"productRatings"]) {
            ratingsViewController.productRatings = [notification.userInfo objectForKey:@"productRatings"];
        }
        
        BOOL animated = YES;
        if([notification.userInfo objectForKey:@"animated"] && VALID_NOTEMPTY([notification.object objectForKey:@"animated"], NSNumber))
        {
            animated = [[notification.userInfo objectForKey:@"animated"] boolValue];
        }
        
        [self pushViewController:ratingsViewController animated:animated];
    }
}

- (void)showNewRatingScreen:(NSNotification*)notification
{
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
        if([notification.userInfo objectForKey:@"animated"] && VALID_NOTEMPTY([notification.object objectForKey:@"animated"], NSNumber))
        {
            animated = [[notification.userInfo objectForKey:@"animated"] boolValue];
        }
        
        [self pushViewController:newRatingViewController animated:animated];
    }
}

- (void)showSizeGuide:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JASizeGuideViewController class]])
    {
        JASizeGuideViewController* viewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"sizeGuideViewController"];
        
        if ([notification.userInfo objectForKey:@"sizeGuideUrl"]) {
            viewController.sizeGuideUrl = [notification.userInfo objectForKey:@"sizeGuideUrl"];
        }
        
        [self pushViewController:viewController animated:YES];
    }

}

#pragma mark - PDV Actions

- (void)showOtherOffers:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JAOtherOffersViewController class]]) {
    
        JAOtherOffersViewController* otherOffersVC = [[JAOtherOffersViewController alloc] init];
        
        if (notification.object && [notification.object isKindOfClass:[RIProduct class]]) {
            otherOffersVC.product = notification.object;
        }
        
        [self pushViewController:otherOffersVC animated:YES];
    }
}

- (void)showSellerReviews:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JASellerRatingsViewController class]])
    {
        JASellerRatingsViewController* viewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"sellerRatingsViewController"];
        
        if (notification.object && [notification.object isKindOfClass:[RIProduct class]]) {
            viewController.product = notification.object;
        }
        
        [self pushViewController:viewController animated:YES];
    }
}

- (void)showNewSellerReview:(NSNotification*)notification
{
    UIViewController *topViewController = [self topViewController];
    if (![topViewController isKindOfClass:[JANewRatingViewController class]])
    {
        JANewSellerRatingViewController* newSellerRatingViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"newSellerRatingViewController"];
        
        if ([notification.userInfo objectForKey:@"product"]) {
            newSellerRatingViewController.product = [notification.userInfo objectForKey:@"product"];
        }
        
        if([notification.userInfo objectForKey:@"sellerAverageReviews"])
        {
            newSellerRatingViewController.sellerAverageReviews = [notification.userInfo objectForKey:@"sellerAverageReviews"];
        }
        
        BOOL animated = YES;
        if([notification.userInfo objectForKey:@"animated"] && VALID_NOTEMPTY([notification.object objectForKey:@"animated"], NSNumber))
        {
            animated = [[notification.userInfo objectForKey:@"animated"] boolValue];
        }
        
        [self pushViewController:newSellerRatingViewController animated:animated];
    }
}

-(void)showSellerCatalog: (NSNotification *)notification
{
    NSString* url = [notification.userInfo objectForKey:@"url"];
    NSString* title = [notification.userInfo objectForKey:@"name"];
    
    if(VALID_NOTEMPTY(url, NSString))
    {
        JACatalogViewController *catalog = [[JACatalogViewController alloc] initWithNibName:@"JACatalogViewController" bundle:nil];
        catalog.catalogUrl = url;
        catalog.navBarLayout.title = title;
        catalog.navBarLayout.showBackButton = YES;
        
        [self pushViewController:catalog animated:YES];
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
        
        JACatalogViewController *catalog = [[JACatalogViewController alloc] initWithNibName:@"JACatalogViewController" bundle:nil];
        
        catalog.catalogUrl = url;
        catalog.navBarLayout.title = title;
        
        if ([notification.userInfo objectForKey:@"show_back_button_title"]) {
            [catalog.navBarLayout setShowBackButton:YES];
        } else {
            [catalog.navBarLayout setShowBackButton:YES];;
        }
        
        [self pushViewController:catalog animated:YES];
    }
}

- (void)didSelectCampaign:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSString* title = [notification.userInfo objectForKey:@"title"];
    
    //this is used when the teaserGrouping is campaigns and we have to show more than one campaign
    RITeaserGrouping* teaserGrouping = [notification.userInfo objectForKey:@"teaserGrouping"];

    //this is used when the teaserGrouping is not campaigns, so we're only going to be showing one
    NSString* campaignUrl = [notification.userInfo objectForKey:@"url"];
    
    //this is used in deeplinking
    NSString* campaignId = [notification.userInfo objectForKey:@"campaign_id"];
    
    if (VALID_NOTEMPTY(teaserGrouping, RITeaserGrouping))
    {
        JACampaignsViewController* campaignsVC = [JACampaignsViewController new];
        
        campaignsVC.teaserGrouping = teaserGrouping;
        campaignsVC.startingTitle = title;
        
        [self pushViewController:campaignsVC animated:YES];
    }
    else if (VALID_NOTEMPTY(campaignId, NSString))
    {
        JACampaignsViewController* campaignsVC = [JACampaignsViewController new];
        
        campaignsVC.campaignId = campaignId;
        
        [self pushViewController:campaignsVC animated:YES];
    } else if (VALID_NOTEMPTY(campaignUrl, NSString)) {
        JACampaignsViewController* campaignsVC = [JACampaignsViewController new];
        
        campaignsVC.campaignUrl = campaignUrl;
        
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
        JAPDVViewController *pdv = [JAPDVViewController new];
        pdv.productUrl = url;
        pdv.productSku = productSku;
        
        if ([notification.userInfo objectForKey:@"fromCatalog"])
        {
            pdv.fromCatalogue = YES;
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
        
        if([notification.userInfo objectForKey:@"show_back_button_title"])
        {
            pdv.showBackButton = YES;
        }
        
        [self pushViewController:pdv animated:YES];
    }
}

- (void)didSelectTeaserWithShopUrl:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    NSString* url = [notification.userInfo objectForKey:@"url"];
    NSString* uid = [notification.userInfo objectForKey:@"shop_id"];

    JAShopWebViewController* viewController = [[JAShopWebViewController alloc] init];
    if([notification.userInfo objectForKey:@"show_back_button"])
    {
        [viewController.navBarLayout setShowBackButton:YES];
    }
    if ([notification.userInfo objectForKey:@"show_back_button_title"]) {
        [viewController.navBarLayout setShowBackButton:YES];
    }
    if([notification.userInfo objectForKey:@"title"])
    {
        viewController.navBarLayout.title = [notification.userInfo objectForKey:@"title"];
    }
    
    if (VALID_NOTEMPTY(url, NSString))
    {
        viewController.url = url;
        [self pushViewController:viewController animated:YES];

    } else if (VALID_NOTEMPTY(uid, NSString))
    {
        viewController.url = [NSString stringWithFormat:@"%@%@main/getstatic/?key=%@",[RIApi getCountryUrlInUse], RI_API_VERSION, uid];
        [self pushViewController:viewController animated:YES];
    }

}

- (void)didSelectTeaserWithAllCategories:(NSNotification*)notification
{
    JACategoriesViewController* categoriesViewController = [self.mainStoryboard instantiateViewControllerWithIdentifier:@"categoriesViewController"];
    
    categoriesViewController.navBarLayout.title = STRING_ALL_CATEGORIES;
    
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
        
        JACatalogViewController *catalog = [[JACatalogViewController alloc] initWithNibName:@"JACatalogViewController" bundle:nil];
        
        catalog.category = category;
        
        catalog.navBarLayout.title = category.name;
        catalog.navBarLayout.backButtonTitle = STRING_ALL_CATEGORIES;
        
        [self pushViewController:catalog animated:YES];
    }
}

- (void) closeCurrentScreenNotificaion:(NSNotification*)notification
{
    BOOL animated = YES;
    if(VALID_NOTEMPTY(notification.userInfo, NSDictionary) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"animated"], NSNumber))
    {
        animated = [[notification.userInfo objectForKey:@"animated"] boolValue];
    }
    [self popViewControllerAnimated:animated];
}

- (void) closeTopTwoScreensNotificaion:(NSNotification*)notification
{
    NSInteger thirdToLastIndex = self.viewControllers.count-3;
    if (0 <= thirdToLastIndex) {
        UIViewController* thirdToLastViewController = [self.viewControllers objectAtIndex:thirdToLastIndex];
        
        BOOL animated = YES;
        if(VALID_NOTEMPTY(notification.userInfo, NSDictionary) && VALID_NOTEMPTY([notification.userInfo objectForKey:@"animated"], NSNumber))
        {
            animated = [[notification.userInfo objectForKey:@"animated"] boolValue];
        }
        [self popToViewController:thirdToLastViewController animated:YES];
    }
}

#pragma mark - Recent Search

- (void)didSelectRecentSearch:(NSNotification*)notification
{
    RISearchSuggestion *recentSearch = notification.object;
    
    if (VALID_NOTEMPTY(recentSearch, RISearchSuggestion)) {
        JACatalogViewController *catalog = [[JACatalogViewController alloc] initWithNibName:@"JACatalogViewController" bundle:nil];
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

    //this removes the shadow line under the navbar
    [self.navigationBar setBackgroundImage:[UIImage new]
                            forBarPosition:UIBarPositionAny
                                barMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];
    
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
    
    self.navigationBarView.titleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *touched = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goTop)];
    [self.navigationBarView.titleLabel addGestureRecognizer:touched];
    
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
}

#pragma mark - Navbar Button actions

- (void)back
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidPressBackNotification
                                                        object:nil];
    [self popViewControllerAnimated:YES];
}

-(void)goTop
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidPressNavBar object:nil];
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
    if ([[self topViewController] isKindOfClass:[JALoadCountryViewController class]]) {
        //inore the notification
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                        object:nil];
    
    if (![[self topViewController] isKindOfClass:[JACartViewController class]])
    {
        JACartViewController *cartViewController = [[JACartViewController alloc] initWithNibName:@"JACartViewController" bundle:nil];
        [cartViewController setCart:self.cart];
        
        [self popToRootViewControllerAnimated:NO];
        [self pushViewController:cartViewController animated:YES];
    }
    
}

- (void)openMenu
{
    if ([[self topViewController] isKindOfClass:[JALoadCountryViewController class]]) {
        //inore the notification
        return;
    }
    
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
