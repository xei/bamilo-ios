////
////  JAMyAccountViewController.m
////  Jumia
////
////  Created by Jose Mota on 15/12/15.
////  Copyright © 2015 Rocket Internet. All rights reserved.
////
//
//#import "JAMyAccountViewController.h"
//#import "RITarget.h"
//#import "JAUtils.h"
//#import "IconTableViewCell.h"
//#import "NotificationTableViewCell.h"
//#import "RICustomer.h"
//#import "ViewControllerManager.h"
//#import "IconTableViewHeaderCell.h"
//#import "AuthenticationDataManager.h"
//#import "EmarsysPredictManager.h"
//
//@interface JAMyAccountViewController() <DataServiceProtocol>
//
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic, strong) NSMutableArray* tableViewListItems;
//@property (assign, nonatomic) BOOL viewWillApearedOnceOrMore;
//@end
//
//@implementation JAMyAccountViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//
//    self.navBarLayout.title = STRING_MY_ACCOUNT;
//    self.navBarLayout.showCartButton = NO;
//    self.navBarLayout.showSeparatorView = NO;
//    self.searchBarIsVisible = YES;
//    self.tabBarIsVisible = YES;
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//
//    //Table View Headers
//    [self.tableView registerNib:[UINib nibWithNibName:[IconTableViewHeaderCell nibName] bundle:nil]
//         forCellReuseIdentifier:[IconTableViewHeaderCell nibName]];
//
//    //Table View Cells
//    [self.tableView registerNib:[UINib nibWithNibName:[IconTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [IconTableViewCell nibName]];
//    [self.tableView registerNib:[UINib nibWithNibName:[NotificationTableViewCell nibName] bundle:nil] forCellReuseIdentifier: [NotificationTableViewCell nibName]];
//    
//
//    [self updateTableViewListItemsModel];
//    self.tableView.dataSource = self;
//    self.tableView.delegate = self;
//    
//    // This will remove extra separators from tableview
//    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
//}
//
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    if (self.viewWillApearedOnceOrMore) {
//        [self updateTableViewListItemsModel];
//        [self.tableView reloadData];
//    }
//    self.viewWillApearedOnceOrMore = YES;
//}
//
//- (void)updateTableViewListItemsModel {
//    self.tableViewListItems = [NSMutableArray arrayWithArray: @[
//                                                                @{
//                                                                    @"title": STRING_PROFILE,
//                                                                    @"icon": @"user-information-icons",
//                                                                    @"cellType": IconTableViewCell.nibName,
//                                                                    @"notification" : kShowUserDataScreenNotification,
//                                                                    @"animated" : @YES,
//                                                                    @"CLASS": @"JAUserDataViewController"
//                                                                    },
//                                                                @{
//                                                                    @"title": STRING_MY_ADDRESSES,
//                                                                    @"icon": @"my-address-icon",
//                                                                    @"cellType": IconTableViewCell.nibName,
//                                                                    @"notification": kShowCheckoutAddressesScreenNotification,
//                                                                    @"animated" : @NO,
//                                                                    @"NIB": @"AddressViewController"
//                                                                    },
//                                                                @{
//                                                                    @"title": STRING_TRACK_MY_ORDER,
//                                                                    @"icon": @"OrderTracking",
//                                                                    @"cellType": IconTableViewCell.nibName,
//                                                                    @"notification" : kShowMyOrdersScreenNotification,
//                                                                    @"animated": @YES,
//                                                                    },
//                                                                @{
//                                                                    @"title": STRING_RECENTLY_VIEWED,
//                                                                    @"icon": @"LastViews",
//                                                                    @"cellType": IconTableViewCell.nibName,
//                                                                    @"notification" : kShowRecentlyViewedScreenNotification,
//                                                                    @"animated": @YES,
//                                                                    },
//                                                                @{
//                                                                    @"title": STRING_NOTIFICATIONS,
//                                                                    @"icon": @"announcements-icon",
//                                                                    @"cellType": NotificationTableViewCell.nibName
//                                                                    },
//                                                                @{
//                                                                    @"title": STRING_NEWSLETTER,
//                                                                    @"icon": @"newsletter-icons",
//                                                                    @"cellType": IconTableViewCell.nibName,
//                                                                    @"notification": kShowEmailNotificationsScreenNotification,
//                                                                    @"animated": @YES
//                                                                    },
//                                                                ]];
//
//    NSObject * loginOrLoginCell = @{
//                                    @"title":[RICustomer checkIfUserIsLogged] ? STRING_LOGOUT : STRING_LOGIN_OR_SIGNUP,
//                                    @"icon": [RICustomer checkIfUserIsLogged] ? @"Logout" : @"HappyFace",
//                                    @"cellType": IconTableViewCell.nibName,
//                                    @"selector": [NSValue valueWithPointer:@selector(loginOrLogoutBtnTouchUpInside)]
//                                    };
//
//    [self.tableViewListItems insertObject: loginOrLoginCell atIndex:[RICustomer checkIfUserIsLogged] ? self.tableViewListItems.count : 0];
//}
//
//
//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    //Must be refactored later
//    self.tableView.frame = self.viewBounds;
//}
//
//
//- (void)loginOrLogoutBtnTouchUpInside {
//    if ([RICustomer checkIfUserIsLogged]) {
//        [self logout];
//        return;
//    }
//    [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification object:nil userInfo: @{@"from_side_menu":@YES}];
//}
//
//- (void)logout {
//    [self showLoading];
//    [[AuthenticationDataManager sharedInstance] logoutUser:self completion:^(id data, NSError *error) {
//        [self bind:data forRequestId:0];
//        
//        //EVENT: LOGOUT
//        [TrackerManager postEvent:[EventFactory logout:(error == nil)] forName:[LogoutEvent name]];
//        
//        [EmarsysPredictManager userLoggedOut];
//    }];
//}
//
//#pragma mark - UITableViewDelegate
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    NSString *cellID = [self.tableViewListItems[indexPath.row] objectForKey:@"cellType"];
//    IconTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
//    cell.titleLabel.text = [self.tableViewListItems[indexPath.row] objectForKey:@"title"];
//    cell.imageName = [self.tableViewListItems[indexPath.row] objectForKey:@"icon"];
//
//    return cell;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return self.tableViewListItems.count;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return IconTableViewCell.heightSize;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [self.tableView deselectRowAtIndexPath:indexPath animated:true];
//
//    NSDictionary *selectedObjItem = self.tableViewListItems[indexPath.row];
//
//    NSString *nib = [selectedObjItem objectForKey:@"NIB"];
//    NSString *class = [selectedObjItem objectForKey:@"CLASS"];
//
//    if(nib) {
//        [[ViewControllerManager centerViewController] requestNavigateToNib:nib args:nil];
//    } else if(class) {
//        [[ViewControllerManager centerViewController] requestNavigateToClass:class args:nil];
//    } else {
//        if ([[selectedObjItem objectForKey:@"selector"] pointerValue]) {
//            __unused SEL customSelector = [[selectedObjItem objectForKey:@"selector"] pointerValue];
//            
//            IMP implementation = [self methodForSelector:customSelector];
//            void (*function)(id, SEL) = (void *)implementation;
//            function(self, customSelector);
//            return;
//        }
//        if ([selectedObjItem objectForKey:@"notification"]) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:[selectedObjItem objectForKey:@"notification"] object:@{@"animated":[selectedObjItem objectForKey:@"animated"]} userInfo:@{@"from_checkout":@NO}];
//        }
//    }
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if([RICustomer checkIfUserIsLogged]) {
//        return [IconTableViewHeaderCell cellHeight];
//    } else {
//        return 0.0f;
//    }
//}
//
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    IconTableViewHeaderCell *userGreetingTableViewHeaderCell = [self.tableView dequeueReusableCellWithIdentifier:[IconTableViewHeaderCell nibName]];
//    [userGreetingTableViewHeaderCell setImageName:@"HappyFace"];
//    userGreetingTableViewHeaderCell.titleString = [NSString stringWithFormat:@"%@ %@!", STRING_HELLO, [RICustomer getCurrentCustomer].firstName];
//    return userGreetingTableViewHeaderCell;
//}
//
//#pragma mark - PerformanceTrackerProtocol
//-(NSString *)getPerformanceTrackerScreenName {
//    return @"CustomerAccount";
//}
//
//
//- (void)bind:(id)data forRequestId:(int)rid {
//    [self hideLoading];
//    // --- Legacy Codes ----
//    NSString *custumerId = [RICustomer getCustomerId];
//    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
//    [trackingDictionary setValue:custumerId forKey:kRIEventLabelKey];
//    [trackingDictionary setValue:@"LogoutSuccess" forKey:kRIEventActionKey];
//    [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
//    [trackingDictionary setValue:custumerId forKey:kRIEventUserIdKey];
//    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
//    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
//    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
//    [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
//    [[RITrackingWrapper sharedInstance] trackEvent:@(RIEventLogout) data:[trackingDictionary copy]];
//    
//    [RICommunicationWrapper deleteSessionCookie];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedOutNotification object:nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
//    
//    [RICustomer cleanCustomerFromDB];
//    [[ViewControllerManager sharedInstance] clearCache];
//}
//@end
