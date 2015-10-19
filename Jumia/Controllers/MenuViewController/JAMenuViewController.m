//
//  JAMenuViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMenuViewController.h"
#import "JACategoriesSideMenuViewController.h"
#import "RICategory.h"
#import "JAUtils.h"
#import "RISearchSuggestion.h"
#import "RICustomer.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "RISearchSuggestion.h"
#import "RICart.h"
#import "JAClickableView.h"

typedef NS_ENUM(NSUInteger, JAMenuViewControllerAction) {
    JAMenuViewControllerOpenCart = 0,
    JAMenuViewControllerOpenSideMenuItem = 1
};

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
    ScrollDirectionUp,
    ScrollDirectionDown,
    ScrollDirectionCrazy,
} ScrollDirection;

@interface JAMenuViewController ()
<
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate
>

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSArray *categories;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMenu;
@property (weak, nonatomic) IBOutlet JAClickableView *cartView;
@property (nonatomic, assign) CGFloat yOffset;
@property (nonatomic, strong) UIStoryboard *mainStoryboard;

// Handle external payment actions
@property (assign, nonatomic) JAMenuViewControllerAction nextAction;
@property (strong, nonatomic) NSIndexPath *nextActionIndexPath;

@end

@implementation JAMenuViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.screenName = @"LeftMenu";
    
    self.title = @"";
    
    self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
    {
        self.mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
    }
    
    [self showLoading];
    
    [self initSourceArray];
    
    self.yOffset = 0.0;
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogin)
                                                 name:kUserLoggedInNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:nil
                                                 name:kUserLoggedOutNotification
                                               object:nil];
    
    
    // this triggers the constraints error output
    self.tableViewMenu.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.tableViewMenu.separatorColor = [UIColor whiteColor];
    
    // Added because of the footer space
    self.tableViewMenu.contentInset = UIEdgeInsetsMake(0, 0, -20, 0);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadCategories) name:kSideMenuShouldReload object:nil];
    
    [self reloadCategories];
}

- (void)reloadCategories
{
    [RICategory getCategoriesWithSuccessBlock:^(id categories) {
        
        self.categories = [NSArray arrayWithArray:(NSArray *)categories];
        
        [self hideLoading];
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
        
        [self hideLoading];
        
        [self showMessage:STRING_ERROR success:NO];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    //this is here to override super DO NOT CALL SUPER
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Tableview datasource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    //remove the clickable view
    for (UIView* view in cell.subviews) {
        if ([view isKindOfClass:[JAClickableView class]]) { //remove the clickable view
            [view removeFromSuperview];
        } else {
            for (UIView* subview in view.subviews) {
                if ([subview isKindOfClass:[JAClickableView class]]) { //remove the clickable view
                    [subview removeFromSuperview];
                }
            }
        }
    }
    //add the new clickable view
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, cellHeight)];
    clickView.tag = indexPath.row;
    [cell addSubview:clickView];
    
    [clickView addTarget:self action:@selector(menuCellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    CGFloat fontSize = 17.0f;
    if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"]) {
        fontSize = 14.0f;
    }
    
    CGFloat margin = 13.0f;
    
    UIImage* cellImage = [UIImage imageNamed:[[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
    CGFloat cellImageX = margin;
    
    CGFloat textLabelX = cellImageX*2 + cellImage.size.width;
    CGFloat textLabelWidth = self.view.frame.size.width - margin*2 - cellImage.size.width;
    
    UIImageView* cellImageView = [[UIImageView alloc] initWithImage:cellImage];
    [clickView addSubview:cellImageView];
    
    UILabel* customTextLabel = [UILabel new];
    customTextLabel.font = [UIFont fontWithName:kFontLightName size:fontSize];
    customTextLabel.text = [[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    [clickView addSubview:customTextLabel];
    
    if (RI_IS_RTL) {
        cellImageX = textLabelWidth + margin;
        textLabelX = 0.0f;
        customTextLabel.textAlignment = NSTextAlignmentRight;
        [cellImageView flipViewImage];
    }

    [cellImageView setFrame:CGRectMake(cellImageX,
                                       (cellHeight - cellImage.size.height) / 2,
                                       cellImage.size.width,
                                       cellImage.size.height)];
    [customTextLabel setFrame:CGRectMake(textLabelX,
                                         0.0,
                                         textLabelWidth,
                                         cellHeight)];
    
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(customTextLabel.frame.origin.x,
                                                                 cellHeight - 1,
                                                                 customTextLabel.frame.size.width,
                                                                 1)];
    separator.backgroundColor = JALabelGrey;
    [clickView addSubview:separator];
    
    if (1 == indexPath.row)
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)menuCellWasPressed:(UIControl*)sender
{
    [self tableView:self.tableViewMenu didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    self.nextAction = JAMenuViewControllerOpenSideMenuItem;
    self.nextActionIndexPath = indexPath;
    
    if(self.needsExternalPaymentMethod)
    {
        [[[UIAlertView alloc] initWithTitle:STRING_LOOSING_ORDER_TITLE
                                    message:STRING_LOOSING_ORDER_MESSAGE
                                   delegate:self
                          cancelButtonTitle:STRING_CANCEL
                          otherButtonTitles:STRING_OK, nil] show];
    }
    else
    {
        if (1 == indexPath.row)
        {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            
            if(VALID_NOTEMPTY(self.categories, NSArray))
            {
                [userInfo setObject:self.categories forKey:@"categories"];
            }
            
            [self showSubCategory];
        }
        else
        {
            BOOL hasOneLessIndex = ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"] || [[APP_NAME uppercaseString] isEqualToString:@"بامیلو"]);
            if (8 == indexPath.row ||
                (hasOneLessIndex && 7 == indexPath.row))
            {
                if ([RICustomer checkIfUserIsLogged])
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
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
                         
                     } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorObject)
                     {
                         [self hideLoading];
                         
                         [self userDidLogout];
                         
                         [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
                         
                     }];
                }
                else
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                        object:@{@"index": @(indexPath.row),
                                                                                 @"name": [[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"name"]}];
                }
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                    object:@{@"index": @(indexPath.row),
                                                                             @"name": [[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"name"]}];
            }
        }
    }
}

- (void)showSubCategory
{
    JACategoriesSideMenuViewController* categoriesViewController = [[JACategoriesSideMenuViewController alloc] init];
    categoriesViewController.categoriesArray = self.categories;
    [self.navigationController pushViewController:categoriesViewController animated:YES];
    
}

#pragma mark - Init souce array

- (void)initSourceArray
{
    self.sourceArray = [@[@{ @"name": STRING_HOME,
                             @"image": @"ico_home",
                             @"selected": @"ico_home_pressed" },
                          @{ @"name": STRING_CATEGORIES,
                             @"image": @"ico_categories",
                             @"selected": @"ico_categories_pressed" },
                          @{ @"name": STRING_MY_FAVOURITES,
                             @"image": @"ico_favourites",
                             @"selected": @"ico_favourites_pressed" },
                          @{ @"name": STRING_RECENT_SEARCHES,
                             @"image": @"ico_recentsearches",
                             @"selected": @"ico_recentsearches_pressed" },
                          @{ @"name": STRING_RECENTLY_VIEWED,
                             @"image": @"ico_recentlyviewed",
                             @"selected": @"ico_recentlyviewed_pressed" },
                          @{ @"name": STRING_MY_ACCOUNT,
                             @"image": @"ico_myaccount",
                             @"selected": @"ico_myaccount_pressed" },
                          @{ @"name": STRING_MY_ORDERS,
                             @"image": @"ico_trackorder",
                             @"selected": @"ico_trackorder_pressed" }
                          ] mutableCopy];
    
    
    if(NO == [[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"] &&
       NO == [[APP_NAME uppercaseString] isEqualToString:@"بامیلو"])
    {
        NSDictionary* chooseCountry = @{ @"name": STRING_CHOOSE_COUNTRY,
                                        @"image": @"ico_choosecountry",
                                        @"selected": @"ico_choosecountry_pressed" };
        [self.sourceArray addObject:chooseCountry];
    }

    NSDictionary* loginDic;
    if ([RICustomer checkIfUserIsLogged])
    {
        loginDic = @{ @"name": STRING_LOGOUT,
                      @"image": @"ico_sign",
                      @"selected": @"ico_signpressed" };
    }
    else
    {
        loginDic = @{ @"name": STRING_LOGIN,
                      @"image": @"ico_sign",
                      @"selected": @"ico_signpressed" };
    }
    [self.sourceArray addObject:loginDic];
    [self.tableViewMenu reloadData];
}

#pragma mark - Login and Logout

- (void)userDidLogin
{
    NSDictionary *dic = @{ @"name": STRING_LOGOUT,
                           @"image": @"ico_sign",
                           @"selected": @"ico_signpressed" };
    
    [self.sourceArray removeLastObject];
    [self.sourceArray addObject:dic];
    [self.tableViewMenu reloadData];
}

- (void)userDidLogout
{
    [RICommunicationWrapper deleteSessionCookie];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
    
    NSDictionary *dic = @{ @"name": STRING_LOGIN,
                           @"image": @"ico_sign",
                           @"selected": @"ico_signpressed" };
    
    [self.sourceArray removeLastObject];
    [self.sourceArray addObject:dic];
    [self.tableViewMenu reloadData];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(1 == buttonIndex)
    {
        self.needsExternalPaymentMethod = NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeactivateExternalPaymentNotification object:nil userInfo:nil];
        
        switch (self.nextAction) {
            case JAMenuViewControllerOpenCart:
                [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCartNotification object:nil userInfo:nil];
                break;
            case JAMenuViewControllerOpenSideMenuItem:
                if(VALID_NOTEMPTY(self.nextActionIndexPath, NSIndexPath))
                {
                    [self tableView:self.tableViewMenu didSelectRowAtIndexPath:self.nextActionIndexPath];
                }
                break;
            default:
                break;
        }
    }
}

#pragma mark - Scrollview delegate (For results table)

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < self.yOffset) {
        
        // scrolls down.
        self.yOffset = scrollView.contentOffset.y;
    }
    else
    {
        // scrolls up.
        self.yOffset = scrollView.contentOffset.y;
    }
}

@end
