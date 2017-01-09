//
//  JAMoreMenuViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 22/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAMoreMenuViewController.h"
#import "JAProductInfoHeaderLine.h"
#import "JAProductInfoSingleLine.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#define kCellTextArray @[STRING_MORE, STRING_LOGIN, STRING_RECENTLY_VIEWED, STRING_TRACK_MY_ORDER]

@interface JAMoreMenuViewController ()

@property (strong, nonatomic) JAProductInfoHeaderLine *moreHeaderLine;
@property (strong, nonatomic) JAProductInfoSingleLine *loginSingleLine;
@property (strong, nonatomic) JAProductInfoSingleLine *recentlyViewedSingleLine;
@property (strong, nonatomic) JAProductInfoSingleLine *trackMyOrderSingleLine;
@property (strong, nonatomic) JAProductInfoSingleLine *contactUsPageSingleLine;

@end

@implementation JAMoreMenuViewController


- (JAProductInfoHeaderLine *)moreHeaderLine
{
    if (!VALID(_moreHeaderLine, JAProductInfoHeaderLine)) {
        _moreHeaderLine = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(0, self.viewBounds.origin.y, self.view.width, kProductInfoHeaderLineHeight)];
        [_moreHeaderLine setTitle:[STRING_MORE uppercaseString]];
    }
    return _moreHeaderLine;
}

- (JAProductInfoSingleLine *)loginSingleLine
{
    if (!VALID(_loginSingleLine, JAProductInfoSingleLine)) {
        _loginSingleLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.moreHeaderLine.frame), self.view.width, kProductInfoSingleLineHeight)];
        [_loginSingleLine setTopSeparatorVisibility:NO];
        [_loginSingleLine setTitle:[RICustomer checkIfUserIsLogged]?STRING_LOGOUT:STRING_LOGIN];
        [_loginSingleLine addTarget:self action:@selector(loginSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginSingleLine;
}

- (JAProductInfoSingleLine *)contactUsPageSingleLine
{
    if (!VALID(_contactUsPageSingleLine, JAProductInfoSingleLine)) {
        _contactUsPageSingleLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.trackMyOrderSingleLine.frame), self.view.width, kProductInfoSingleLineHeight)];
        [_contactUsPageSingleLine setTopSeparatorVisibility:YES];
        [_contactUsPageSingleLine setTitle:STRING_CONTACT_US];
        [_contactUsPageSingleLine addTarget:self action:@selector(contactUsPageSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contactUsPageSingleLine;
}

- (JAProductInfoSingleLine *)recentlyViewedSingleLine
{
    if (!VALID(_recentlyViewedSingleLine, JAProductInfoSingleLine)) {
        _recentlyViewedSingleLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.loginSingleLine.frame), self.view.width, kProductInfoSingleLineHeight)];
        [_recentlyViewedSingleLine setTitle:STRING_RECENTLY_VIEWED];
        [_recentlyViewedSingleLine addTarget:self action:@selector(recentlyViewedSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recentlyViewedSingleLine;
}

- (JAProductInfoSingleLine *)trackMyOrderSingleLine
{
    if (!VALID(_trackMyOrderSingleLine, JAProductInfoSingleLine)) {
        _trackMyOrderSingleLine = [[JAProductInfoSingleLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.recentlyViewedSingleLine.frame), self.view.width, kProductInfoSingleLineHeight)];
        [_trackMyOrderSingleLine setBottomSeparatorVisibility:NO];
        [_trackMyOrderSingleLine setTitle:STRING_TRACK_MY_ORDER];
        [_trackMyOrderSingleLine addTarget:self action:@selector(trackMyOrdersSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _trackMyOrderSingleLine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showSeparatorView = NO;
    self.tabBarIsVisible = YES;
    self.searchBarIsVisible = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.moreHeaderLine];
    [self.view addSubview:self.loginSingleLine];
    [self.view addSubview:self.recentlyViewedSingleLine];
    [self.view addSubview:self.trackMyOrderSingleLine];
    [self.view addSubview:self.contactUsPageSingleLine];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.loginSingleLine setTitle:[RICustomer checkIfUserIsLogged]?STRING_LOGOUT:STRING_LOGIN];
    BOOL changed = NO;
    for (UIView *subView in self.view.subviews) {
        if (!CGRectEqualToRect(subView.frame, self.viewBounds)) {
            changed = YES;
            [subView setWidth:self.view.width];
        }
    }
    if (changed && RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

- (void)loginSelection
{
    if ([RICustomer checkIfUserIsLogged]) {
        [self logout];
    } else {
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"from_side_menu"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification object:nil userInfo:userInfo];
    }
}

- (void)recentlyViewedSelection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowRecentlyViewedScreenNotification object:nil];
}

- (void)contactUsPageSelection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowContactUsScreenNotification object:nil];
}

- (void)trackMyOrdersSelection
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowMyOrdersScreenNotification object:nil];
}

- (void)logout
{
    [self showLoading];
    
    __block NSString *custumerId = [RICustomer getCustomerId];
    
    [[[FBSDKLoginManager alloc] init] logOut];
    
    [RICustomer logoutCustomerWithSuccessBlock:^
     {
         [self hideLoading];
         
         NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
         [trackingDictionary setValue:custumerId forKey:kRIEventLabelKey];
         [trackingDictionary setValue:@"LogoutSuccess" forKey:kRIEventActionKey];
         [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
         [trackingDictionary setValue:custumerId forKey:kRIEventUserIdKey];
         [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
         [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
         NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
         [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
         [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLogout]
                                                   data:[trackingDictionary copy]];

         [self userDidLogout];
         
     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorObject)
     {
         [self hideLoading];
         [self userDidLogout];
     }];
}

- (void)userDidLogout
{
    [self.loginSingleLine setTitle:[RICustomer checkIfUserIsLogged]?STRING_LOGOUT:STRING_LOGIN];
    [RICommunicationWrapper deleteSessionCookie];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}


@end
