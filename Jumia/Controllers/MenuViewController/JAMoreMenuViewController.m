//
//  JAMoreMenuViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 22/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAMoreMenuViewController.h"
#import "JAProductInfoHeaderLine.h"
#import "JAProductInfoSubLine.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#define kCellTextArray @[STRING_MORE, STRING_LOGIN, STRING_RECENTLY_VIEWED, STRING_TRACK_MY_ORDER]

@interface JAMoreMenuViewController ()

@property (strong, nonatomic) JAProductInfoHeaderLine *moreHeaderLine;
@property (strong, nonatomic) JAProductInfoSubLine *loginSubLine;
@property (strong, nonatomic) JAProductInfoSubLine *recentlyViewedSubLine;
@property (strong, nonatomic) JAProductInfoSubLine *trackMyOrderSubLine;

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

- (JAProductInfoSubLine *)loginSubLine
{
    if (!VALID(_loginSubLine, JAProductInfoSubLine)) {
        _loginSubLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.moreHeaderLine.frame), self.view.width, kProductInfoSubLineHeight)];
        [_loginSubLine setTopSeparatorVisibility:NO];
        [_loginSubLine setTitle:[RICustomer checkIfUserIsLogged]?STRING_LOGOUT:STRING_LOGIN];
        [_loginSubLine addTarget:self action:@selector(loginSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginSubLine;
}

- (JAProductInfoSubLine *)recentlyViewedSubLine
{
    if (!VALID(_recentlyViewedSubLine, JAProductInfoSubLine)) {
        _recentlyViewedSubLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.loginSubLine.frame), self.view.width, kProductInfoSubLineHeight)];
        [_recentlyViewedSubLine setTitle:STRING_RECENTLY_VIEWED];
        [_recentlyViewedSubLine addTarget:self action:@selector(recentlyViewedSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recentlyViewedSubLine;
}

- (JAProductInfoSubLine *)trackMyOrderSubLine
{
    if (!VALID(_trackMyOrderSubLine, JAProductInfoSubLine)) {
        _trackMyOrderSubLine = [[JAProductInfoSubLine alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.recentlyViewedSubLine.frame), self.view.width, kProductInfoSubLineHeight)];
        [_trackMyOrderSubLine setBottomSeparatorVisibility:YES];
        [_trackMyOrderSubLine setTitle:STRING_TRACK_MY_ORDER];
        [_trackMyOrderSubLine addTarget:self action:@selector(trackMyOrdersSelection) forControlEvents:UIControlEventTouchUpInside];
    }
    return _trackMyOrderSubLine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showSeparatorView = NO;
    self.tabBarIsVisible = YES;
    self.searchBarIsVisible = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.moreHeaderLine];
    [self.view addSubview:self.loginSubLine];
    [self.view addSubview:self.recentlyViewedSubLine];
    [self.view addSubview:self.trackMyOrderSubLine];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.loginSubLine setTitle:[RICustomer checkIfUserIsLogged]?STRING_LOGOUT:STRING_LOGIN];
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
    [self.loginSubLine setTitle:[RICustomer checkIfUserIsLogged]?STRING_LOGOUT:STRING_LOGIN];
    [RICommunicationWrapper deleteSessionCookie];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}


@end
