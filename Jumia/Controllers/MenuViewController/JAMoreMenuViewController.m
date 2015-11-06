//
//  JAMoreMenuViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 22/10/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAMoreMenuViewController.h"
#import "JAGenericMenuCell.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#define kCellTextArray @[STRING_MORE, STRING_LOGIN, STRING_RECENTLY_VIEWED, STRING_TRACK_MY_ORDER]

@interface JAMoreMenuViewController ()

@property (nonatomic, strong) UITableView* tableView;

@end

@implementation JAMoreMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.showCartButton = NO;
    self.tabBarIsVisible = YES;
    self.searchBarIsVisible = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tableView setFrame:[self viewBounds]];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self.tableView setFrame:[self viewBounds]];
    [self.tableView reloadData];
}

#pragma UITableView

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kCellTextArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    JAGenericMenuCellStyle style;
    if (0 == indexPath.row) {
        style = JAGenericMenuCellStyleHeader;
    }
    return [JAGenericMenuCell heightForStyle:style];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"cell";
    
    JAGenericMenuCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[JAGenericMenuCell alloc] initWithReuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.backgroundClickableView addTarget:self action:@selector(cellWasClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    NSString* text = [kCellTextArray objectAtIndex:indexPath.row];
    JAGenericMenuCellStyle style;
    BOOL hasSeparator = YES;
    if (0 == indexPath.row) {
        style = JAGenericMenuCellStyleHeader;
        hasSeparator = NO;
    } else if (1 == indexPath.row && [RICustomer checkIfUserIsLogged]) {
        text = STRING_LOGOUT;
    }
    
    [cell setupWithStyle:style
                   width:self.view.frame.size.width
                cellText:text
            iconImageURL:nil
      accessoryImageName:@"sideMenuCell_arrow"
            hasSeparator:hasSeparator];
    cell.backgroundClickableView.tag = indexPath.row;
    
    return cell;
}

- (void)cellWasClicked:(UIControl*)sender
{
    NSInteger index = sender.tag;
    switch (index) {
        case 1:
        {
            if ([RICustomer checkIfUserIsLogged]) {
                [self logout];
            } else {
                NSDictionary* userInfo = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"from_side_menu"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification object:nil userInfo:userInfo];
            }
            break;
        }
        case 2:
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowRecentlyViewedScreenNotification object:nil];
            break;
        case 3:
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowMyOrdersScreenNotification object:nil];
            break;
        default:
            break;
    }
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
    [RICommunicationWrapper deleteSessionCookie];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
}


@end
