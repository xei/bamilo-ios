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
#import "MoreMenuTableViewCell.h"
#import "SimpleHeaderTableViewCell.h"

@interface JAMoreMenuViewController ()

@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* tableViewListItems;

@end

@implementation JAMoreMenuViewController

const int tableViewCllHeihgt = 50;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showSeparatorView = NO;
    self.tabBarIsVisible = YES;
    self.searchBarIsVisible = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    //   Nib registration for tableView
    [self.tableView registerNib: [UINib nibWithNibName: [MoreMenuTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [MoreMenuTableViewCell nibName]];
    
    [self.tableView registerNib:[UINib nibWithNibName:[SimpleHeaderTableViewCell nibName] bundle:nil]
         forCellReuseIdentifier:[SimpleHeaderTableViewCell nibName]];
    
    self.tableViewListItems = @[
                                @{
                                    @"title": [RICustomer checkIfUserIsLogged] ? STRING_LOGOUT : STRING_LOGIN,
                                    @"isLoginBtn" : @YES,
                                    @"notification" : kShowAuthenticationScreenNotification
                                  },
                                @{
                                    @"title": STRING_RECENTLY_VIEWED,
                                    @"notification" : kShowAuthenticationScreenNotification
                                    },
                                @{
                                    @"title": STRING_TRACK_MY_ORDER,
                                    @"notification" : kShowAuthenticationScreenNotification
                                    },
                                @{
                                    @"title": STRING_CONTACT_US,
                                    @"notification" : kShowAuthenticationScreenNotification
                                    },
                                @{
                                    @"title": STRING_FAQ,
                                    @"isFAQBtn":@YES,
                                    @"notification" : kDidSelectTeaserWithShopUrlNofication
                                    }
                                ];
}


- (void)viewDidLayoutSubviews {
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
    MoreMenuTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[MoreMenuTableViewCell nibName] forIndexPath:indexPath];
    cell.title = [self.tableViewListItems[indexPath.row] objectForKey:@"title"];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return tableViewCllHeihgt;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    SimpleHeaderTableViewCell * headerCell = [self.tableView dequeueReusableCellWithIdentifier: [SimpleHeaderTableViewCell nibName]];
    headerCell.titleString = STRING_MORE;
    return headerCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return tableViewCllHeihgt;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary* userInfo;
    
    if([(self.tableViewListItems[indexPath.row]) objectForKey:@"isLoginBtn"]) {
        if ([RICustomer checkIfUserIsLogged]) {
            [self logout];
            return;
        }
        userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"from_side_menu"];
    }
    
    if([(self.tableViewListItems[indexPath.row]) objectForKey:@"isFAQBtn"]) {
        userInfo = @{
                     @"title"                   : @"راهنما",
                     @"targetString"            : @"shop_in_shop::help",
                     @"show_back_button_title"  : @""
                     };
    }
    
    NSString *notificationName = [(self.tableViewListItems[indexPath.row]) objectForKey:@"notification"];
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo: userInfo];
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
