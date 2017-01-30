//
//  JAMoreMenuViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 22/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAMoreMenuViewController.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "PlainTableViewCell.h"
#import "IconTableViewCell.h"
#import "SimpleHeaderTableViewCell.h"

@interface JAMoreMenuViewController ()

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* tableViewListItems;

@end

@implementation JAMoreMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showSeparatorView = NO;
    self.tabBarIsVisible = YES;
    self.searchBarIsVisible = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //   Nib registration for tableView
    [self.tableView registerNib: [UINib nibWithNibName: [PlainTableViewCell nibName] bundle:nil]
                    forCellReuseIdentifier: [PlainTableViewCell nibName]];
    
    [self.tableView registerNib: [UINib nibWithNibName:[SimpleHeaderTableViewCell nibName] bundle:nil]
                    forHeaderFooterViewReuseIdentifier:[SimpleHeaderTableViewCell nibName]];
    
    self.tableViewListItems = @[
                                @{
                                    @"title": [RICustomer checkIfUserIsLogged] ? STRING_LOGOUT : STRING_LOGIN,
                                    @"cellType": PlainTableViewCell.nibName,
                                    @"selectorName" : @"loginOrLogoutBtnTouchUpInside"
                                  },
                                @{
                                    @"title": STRING_RECENTLY_VIEWED,
                                    @"cellType": PlainTableViewCell.nibName,
                                    @"notification" : kShowRecentlyViewedScreenNotification,
                                    @"animated": @YES,
                                    },
                                @{
                                    @"title": STRING_TRACK_MY_ORDER,
                                    @"cellType": PlainTableViewCell.nibName,
                                    @"notification" : kShowMyOrdersScreenNotification,
                                    @"animated": @YES,
                                    },
                                @{
                                    @"title": STRING_CONTACT_US,
                                    @"cellType": PlainTableViewCell.nibName,
                                    @"notification" : kShowContactUsScreenNotification,
                                    @"animated": @YES,
                                    },
                                @{
                                    @"title": STRING_FAQ,
                                    @"cellType": PlainTableViewCell.nibName,
                                    @"selectorName": @"fAQBtnTouchUpInside"
                                    }
                                ];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //Must be refactored later
    self.tableView.frame = self.viewBounds;
}

- (void)logout {
    [self showLoading];
    
    __block NSString *custumerId = [RICustomer getCustomerId];
    
    [[[FBSDKLoginManager alloc] init] logOut];
    
    [RICustomer logoutCustomerWithSuccessBlock:^ {
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
         [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLogout] data:[trackingDictionary copy]];
         [self userDidLogout];
         
     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorObject) {
         [self hideLoading];
         [self userDidLogout];
     }];
}

- (void)userDidLogout {
    
    [RICommunicationWrapper deleteSessionCookie];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
    
}


#pragma tableView DetaSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewListItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellID = [self.tableViewListItems[indexPath.row] objectForKey:@"cellType"];
    PlainTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.title = [self.tableViewListItems[indexPath.row] objectForKey:@"title"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [PlainTableViewCell heightSize];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SimpleHeaderTableViewCell * headerCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[SimpleHeaderTableViewCell nibName]];
    headerCell.titleString = STRING_MORE;
    return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [PlainTableViewCell heightSize];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    NSDictionary *selectedObjItem = self.tableViewListItems[indexPath.row];
    if ([selectedObjItem objectForKey:@"selectorName"]) {
        SEL customSelector = NSSelectorFromString([selectedObjItem objectForKey:@"selectorName"]);
        [self performSelector:customSelector withObject: 0];
        return;
    }
    
    if ([selectedObjItem objectForKey:@"notification"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[selectedObjItem objectForKey:@"notification"]
                                                            object:@{@"animated":[selectedObjItem objectForKey:@"animated"]}
                                                          userInfo:@{@"from_checkout":@NO}];
    }
}

- (void)fAQBtnTouchUpInside {
    NSDictionary *userInfo = @{
                 @"title"                   : @"راهنما",
                 @"targetString"            : @"shop_in_shop::help",
                 @"show_back_button_title"  : @""
                 };
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithShopUrlNofication object:nil userInfo: userInfo];
}

- (void)loginOrLogoutBtnTouchUpInside {
    if ([RICustomer checkIfUserIsLogged]) {
        [self logout];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification object:nil userInfo: @{@"from_side_menu":@YES}];
}

@end
