//
//  JAMyAccountViewController.m
//  Jumia
//
//  Created by Jose Mota on 15/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAMyAccountViewController.h"
#import "RITarget.h"
#import "JAUtils.h"
#import "IconTableViewCell.h"
#import "NotificationTableViewCell.h"
#import "RICustomer.h"

@interface JAMyAccountViewController ()


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray* tableViewListItems;


@end

@implementation JAMyAccountViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"CustomerAccount";
    
    self.navBarLayout.title = STRING_MY_ACCOUNT;
    self.navBarLayout.showCartButton = NO;
    self.navBarLayout.showSeparatorView = NO;
    self.searchBarIsVisible = YES;
    self.tabBarIsVisible = YES;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    
#pragma mark - nib registration 
    
    [self.tableView registerNib:[UINib nibWithNibName:[IconTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [IconTableViewCell nibName]];
    [self.tableView registerNib:[UINib nibWithNibName:[NotificationTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [NotificationTableViewCell nibName]];

    self.tableViewListItems = [NSMutableArray arrayWithArray: @[
                                @{
                                    @"title": STRING_PROFILE,
                                    @"icon": @"user-information-icons",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"notification" : kShowUserDataScreenNotification,
                                    @"animated" : @YES
                                    },
                                @{
                                    @"title": STRING_MY_ADDRESSES,
                                    @"icon": @"my-address-icon",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"notification": kShowCheckoutAddressesScreenNotification,
                                    @"animated" : @NO
                                    },
                                @{
                                    @"title": STRING_TRACK_MY_ORDER,
                                    @"icon": @"OrderTracking",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"notification" : kShowMyOrdersScreenNotification,
                                    @"animated": @YES,
                                    },
                                @{
                                    @"title": STRING_RECENTLY_VIEWED,
                                    @"icon": @"LastViews",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"notification" : kShowRecentlyViewedScreenNotification,
                                    @"animated": @YES,
                                    },
                                @{
                                    @"title": STRING_NOTIFICATIONS,
                                    @"icon": @"announcements-icon",
                                    @"cellType": NotificationTableViewCell.nibName
                                    },
                                @{
                                    @"title": STRING_NEWSLETTER,
                                    @"icon": @"newsletter-icons",
                                    @"cellType": IconTableViewCell.nibName,
                                    @"notification": kShowEmailNotificationsScreenNotification,
                                    @"animated": @YES
                                    },
                                ]];
    
    NSObject * loginOrLoginCell = @{
          @"title":[RICustomer checkIfUserIsLogged] ? STRING_LOGOUT : STRING_LOGIN,
          @"icon": [RICustomer checkIfUserIsLogged] ? @"Logout" : @"HappyFace",
          @"cellType": IconTableViewCell.nibName,
          @"selector": [NSValue valueWithPointer:@selector(loginOrLogoutBtnTouchUpInside)]
          };
    
    [self.tableViewListItems insertObject: loginOrLoginCell atIndex:[RICustomer checkIfUserIsLogged] ? self.tableViewListItems.count : 0];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //Must be refactored later
    self.tableView.frame = self.viewBounds;
}


- (void)loginOrLogoutBtnTouchUpInside {
    if ([RICustomer checkIfUserIsLogged]) {
        [self logout];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification object:nil userInfo: @{@"from_side_menu":@YES}];
}

- (void)logout {
    [self showLoading];
    
    __block NSString *custumerId = [RICustomer getCustomerId];
    
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

#pragma mark - TableView delegates

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellID = [self.tableViewListItems[indexPath.row] objectForKey:@"cellType"];
    IconTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.title = [self.tableViewListItems[indexPath.row] objectForKey:@"title"];
    cell.imageName = [self.tableViewListItems[indexPath.row] objectForKey:@"icon"];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewListItems.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return IconTableViewCell.heightSize;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
    
    NSDictionary *selectedObjItem = self.tableViewListItems[indexPath.row];
    
    if ([[selectedObjItem objectForKey:@"selector"] pointerValue]) {
        SEL customSelector = [[selectedObjItem objectForKey:@"selector"] pointerValue];
        //[self performSelector:customSelector withObject: 0];
        [self performSelector:customSelector];
        return;
    }
    
    if ([selectedObjItem objectForKey:@"notification"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:[selectedObjItem objectForKey:@"notification"]
                                                            object:@{@"animated":[selectedObjItem objectForKey:@"animated"]}
                                                          userInfo:@{@"from_checkout":@NO}];
    }
}


@end
