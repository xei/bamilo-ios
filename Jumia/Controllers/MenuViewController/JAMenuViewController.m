//
//  JAMenuViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMenuViewController.h"
#import "JASubCategoriesViewController.h"
#import "RICategory.h"
#import "JAMenuNavigationBar.h"
#import "JAUtils.h"
#import "RISearchSuggestion.h"
#import "RICustomer.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBSession.h>
#import "RISearchSuggestion.h"
#import "RICart.h"
#import "JAClickableView.h"

typedef NS_ENUM(NSUInteger, JAMenuViewControllerAction) {
    JAMenuViewControllerOpenSearchBar = 0,
    JAMenuViewControllerOpenCart = 1,
    JAMenuViewControllerOpenSideMenuItem = 2
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
UISearchBarDelegate,
UIAlertViewDelegate
>

@property (strong, nonatomic) NSMutableArray *sourceArray;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) JAMenuNavigationBar *customNavBar;
@property (strong, nonatomic) NSMutableArray *resultsArray;
@property (strong, nonatomic) UITableView *resultsTableView;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMenu;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCart;
@property (weak, nonatomic) IBOutlet UILabel *cartLabelTitle;
@property (weak, nonatomic) IBOutlet UILabel *cartLabelTotalCost;
@property (weak, nonatomic) IBOutlet UILabel *cartLabelDetails;
@property (weak, nonatomic) IBOutlet UILabel *cartItensNumber;
@property (weak, nonatomic) IBOutlet JAClickableView *cartView;
@property (nonatomic, assign) CGFloat yOffset;

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
    
    [self showLoading];
    
    [self initSourceArray];
    
    self.yOffset = 0.0;
    
    self.customNavBar = [[JAMenuNavigationBar alloc] init];
    [self.navigationController setValue:self.customNavBar
                             forKeyPath:@"navigationBar"];
    
    [self.customNavBar.backButton addTarget:self
                                     action:@selector(didPressedBackButton)
                           forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didPressedBackButton)
                                                 name:kCancelButtonPressedInMenuSearchBar
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDidLogin)
                                                 name:kUserLoggedInNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:nil
                                                 name:kUserLoggedOutNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateCart:)
                                                 name:kUpdateSideMenuCartNotification
                                               object:nil];
    
    [self.cartView addTarget:self
                      action:@selector(cartViewPressed:)
            forControlEvents:UIControlEventTouchUpInside];
    self.cartLabelTitle.text = STRING_SHOPPING_CART;
    
    if(!VALID_NOTEMPTY(self.cart, RICart) || 0 == [[self.cart cartCount] integerValue])
    {
        self.cartLabelTotalCost.text = STRING_YOUR_CART_IS_EMPTY;
        self.cartLabelDetails.text = @"";
        self.cartItensNumber.text = @"";
    }
    else
    {
        self.cartLabelTotalCost.text =  [self.cart cartValueFormatted];
        self.cartLabelDetails.text = STRING_VAT_SHIPPING_INCLUDED;
        self.cartItensNumber.text = [[self.cart cartCount] stringValue];
    }
    
    [self.customNavBar setSearchBarDelegate:self];
    
    // Added because of the footer space
    self.tableViewMenu.contentInset = UIEdgeInsetsMake(0, 0, -20, 0);
    
    [RICategory getCategoriesWithSuccessBlock:^(id categories) {
        
        self.categories = [NSArray arrayWithArray:(NSArray *)categories];
        
        [self hideLoading];
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
        
        [self hideLoading];
        
        [self showMessage:STRING_ERROR success:NO];
    }];
}

-(void)updateCart:(NSNotification*)notification
{
    self.cart = nil;

    if(VALID_NOTEMPTY(notification, NSNotification))
    {
        NSDictionary *userInfo = notification.userInfo;
        if([userInfo objectForKey:kUpdateCartNotificationValue])
        {
            self.cart = [userInfo objectForKey:kUpdateCartNotificationValue];
        }
    }
    
    if(!VALID_NOTEMPTY(self.cart, RICart) || 0 == [[self.cart cartCount] integerValue])
    {
        self.cartLabelTotalCost.text = STRING_YOUR_CART_IS_EMPTY;
        self.cartLabelDetails.text = @"";
        self.cartItensNumber.text = @"";
    }
    else
    {
        self.cartLabelTotalCost.text =  [self.cart cartValueFormatted];
        self.cartLabelDetails.text = STRING_VAT_SHIPPING_INCLUDED;
        self.cartItensNumber.text = [[self.cart cartCount] stringValue];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    //this is here to override super DO NOT CALL SUPER
}

- (void)cartViewPressed:(UIGestureRecognizer*)sender
{
    self.nextAction = JAMenuViewControllerOpenCart;
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCartNotification object:nil userInfo:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSubCategories"]) {
        [segue.destinationViewController setSourceCategoriesArray:self.categories];
    }
}

#pragma mark - Tableview datasource and delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.resultsTableView == tableView) {
        return self.resultsArray.count;
    } else {
        return self.sourceArray.count;
    }
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
        if ([view isKindOfClass:[JAClickableView class]]) {
            [view removeFromSuperview];
        }
    }
    //add the new clickable view
    CGFloat cellHeight = [self tableView:tableView heightForRowAtIndexPath:indexPath];
    JAClickableView* clickView = [[JAClickableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, cellHeight)];
    clickView.tag = indexPath.row;
    [cell addSubview:clickView];
    
    if (self.resultsTableView == tableView)
    {
        RISearchSuggestion *sugestion = [self.resultsArray objectAtIndex:indexPath.row];
        
        NSString *text = sugestion.item;
        NSString *searchedText = self.customNavBar.searchBar.text;
        
        if (text.length == 0)
        {
            text = STRING_ERROR;
        }
        
        NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:text];
        NSInteger stringTextLenght = text.length;
        
        UIFont *stringTextFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
        UIFont *subStringTextFont = [UIFont fontWithName:@"HelveticaNeue" size:17.0f];
        UIColor *stringTextColor = UIColorFromRGB(0x4e4e4e);
        
        
        [stringText addAttribute:NSFontAttributeName
                           value:stringTextFont
                           range:NSMakeRange(0, stringTextLenght)];
        
        [stringText addAttribute:NSStrokeColorAttributeName
                           value:stringTextColor
                           range:NSMakeRange(0, stringTextLenght)];
        
        NSRange range = [text rangeOfString:searchedText];
        
        [stringText addAttribute:NSFontAttributeName
                           value:subStringTextFont
                           range:range];
        
        cell.textLabel.attributedText = stringText;
        
        if (1 == sugestion.isRecentSearch)
        {
            cell.imageView.image = [UIImage imageNamed:@"ico_recentsearchsuggestion"];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"ico_searchsuggestion"];
        }
        
        if (0 == indexPath.row)
        {
            UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 1)];
            line.backgroundColor = UIColorFromRGB(0xcccccc);
            line.tag = 99;
            [cell.viewForBaselineLayout addSubview:line];
        }
        
        UIImageView *line2 = [[UIImageView alloc] initWithFrame:CGRectMake(45, cell.frame.size.height-1, cell.frame.size.width-20, 1)];
        line2.backgroundColor = UIColorFromRGB(0xcccccc);
        [cell.viewForBaselineLayout addSubview:line2];
        
        [clickView addTarget:self action:@selector(resultCellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        
    } else
    {
        [clickView addTarget:self action:@selector(menuCellWasPressed:) forControlEvents:UIControlEventTouchUpInside];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f];
        cell.textLabel.text = [[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        
        cell.imageView.image = [UIImage imageNamed:[[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
        cell.imageView.highlightedImage = [UIImage imageNamed:[[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"selected"]];
        
        if (1 == indexPath.row)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)resultCellWasPressed:(UIControl*)sender
{
    [self tableView:self.resultsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
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

    [self.customNavBar resignFirstResponder];
    
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
        if (self.resultsTableView == tableView)
        {
            [self.customNavBar.searchBar resignFirstResponder];
            
            RISearchSuggestion *suggestion = [self.resultsArray objectAtIndex:indexPath.row];
            NSString *item = suggestion.item;
            
            if(!suggestion.isRecentSearch)
            {
                [RISearchSuggestion saveSearchSuggestionOnDB:suggestion.item
                                              isRecentSearch:YES];
            }
            
            // I changed the index to 99 to know that it's to display a search result
            [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                object:@{@"index": @(99),
                                                                         @"name": STRING_SEARCH,
                                                                         @"text": item }];
        }
        else
        {
            if (1 == indexPath.row)
            {
                [self.customNavBar addBackButtonToNavBar];
                [self performSegueWithIdentifier:@"showSubCategories"
                                          sender:nil];
            }
            else
            {
                if (8 == indexPath.row)
                {
                    if ([RICustomer checkIfUserIsLogged])
                    {
                        __block NSString *custumerId = [RICustomer getCustomerId];
                        [[FBSession activeSession] closeAndClearTokenInformation];
                        
                        [RICustomer logoutCustomerWithSuccessBlock:^
                         {
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
}

#pragma mark - Navigation bar custom delegate

- (void)didPressedBackButton
{
    if (VALID_NOTEMPTY(self.resultsTableView, UITableView))
    {
        [self.customNavBar.searchBar resignFirstResponder];
        self.customNavBar.searchBar.text = @"";
        [self.customNavBar removeBackButtonFromNavBar];
        [self removeResultsTableViewFromView];
    } else
    {
        
        self.customNavBar.backButton.userInteractionEnabled = NO;
        
        if (self.navigationController.viewControllers.count > 1)
        {
            if (self.navigationController.viewControllers.count == 2)
            {
                [self.customNavBar removeBackButtonFromNavBar];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        } else
        {
            [self.customNavBar removeBackButtonFromNavBar];
        }
        
        [NSTimer scheduledTimerWithTimeInterval:0.5f
                                         target:self
                                       selector:@selector(activateBackButton)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)activateBackButton
{
    self.customNavBar.backButton.userInteractionEnabled = YES;
}

#pragma mark - SearchBar delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.nextAction = JAMenuViewControllerOpenSearchBar;
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
        if (self.customNavBar.isBackVisible) {
            [self.customNavBar removeBackButtonFromNavBarNoResetVariable];
        } else {
            [self.customNavBar removeBackButtonFromNavBar];
        }
        
        searchBar.showsCancelButton = YES;
        
        [self addResultsTableViewToView];
    }
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    [RISearchSuggestion saveSearchSuggestionOnDB:searchBar.text
                                  isRecentSearch:YES];
    
    // I changed the index to 99 to know that it's to display a search result
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                        object:@{@"index": @(99),
                                                                 @"name": STRING_SEARCH,
                                                                 @"text": searchBar.text }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    
    searchBar.showsCancelButton = NO;
    
    [self removeResultsTableViewFromView];
    
    if (self.customNavBar.isBackVisible) {
        [self.customNavBar addBackButtonToNavBar];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 1)
    {
        [RISearchSuggestion getSuggestionsForQuery:searchText
                                      successBlock:^(NSArray *suggestions) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [self.resultsArray removeAllObjects];
                                              [self.resultsTableView reloadData];
                                              
                                              self.resultsArray = [suggestions mutableCopy];
                                              
                                              [self.resultsTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                                                   withRowAnimation:UITableViewRowAnimationFade];
                                          });
                                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
                                          
                                      }];
    }
}

#pragma mark - Results table view methods

- (void)addResultsTableViewToView
{
    if (self.resultsTableView == nil) {
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        UIView *tempView = ((UIViewController *)[viewControllers lastObject]).view;
        
        self.resultsArray = [NSMutableArray new];
        
        CGRect resultsTableFrame = CGRectMake(self.cartView.frame.origin.x,
                                              self.cartView.frame.origin.y,
                                              self.cartView.frame.size.width,
                                              self.navigationController.view.frame.size.height - 35);
        
        resultsTableFrame.origin.y += resultsTableFrame.size.height;
        
        self.resultsTableView = [[UITableView alloc] initWithFrame:resultsTableFrame
                                                             style:UITableViewStyleGrouped];
        
        self.resultsTableView.backgroundColor = UIColorFromRGB(0xffffff);
        self.resultsTableView.delegate = self;
        self.resultsTableView.dataSource = self;
        
        self.resultsTableView.contentInset = UIEdgeInsetsMake(-35.0f, 0.f, 0.f, 0.f);
        
        [self.resultsTableView registerClass:[UITableViewCell class]
                      forCellReuseIdentifier:@"cell"];
        
        self.resultsTableView.separatorColor = [UIColor clearColor];
        
        [tempView addSubview:self.resultsTableView];
        
        [UIView animateWithDuration:0.4f
                         animations:^{
                             CGRect newFrame = self.resultsTableView.frame;
                             newFrame.origin.y = self.cartView.frame.origin.y + 1;
                             
                             if ([[viewControllers lastObject] isKindOfClass:[JASubCategoriesViewController class]]) {
                                 newFrame.origin.y -= 64;
                             }
                             
                             self.resultsTableView.frame = newFrame;
                         }];
    }
}

- (void)removeResultsTableViewFromView
{
    CGRect newFrame = self.resultsTableView.frame;
    newFrame.origin.y = newFrame.size.height + 242;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.resultsTableView.frame = newFrame;
                     } completion:^(BOOL finished) {
                         [self.resultsTableView removeFromSuperview];
                         self.resultsArray = nil;
                         self.resultsTableView = nil;
                     }];
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
                          @{ @"name": STRING_TRACK_MY_ORDER,
                             @"image": @"ico_trackorder",
                             @"selected": @"ico_trackorder_pressed" },
                          @{ @"name": STRING_CHOOSE_COUNTRY,
                             @"image": @"ico_choosecountry",
                             @"selected": @"ico_choosecountry_pressed" },
                          @{ @"name": STRING_LOGIN,
                             @"image": @"ico_sign",
                             @"selected": @"ico_signpressed" }] mutableCopy];
    
    if ([RICustomer checkIfUserIsLogged])
    {
        NSDictionary *dic = @{ @"name": STRING_LOGOUT,
                               @"image": @"ico_sign",
                               @"selected": @"ico_signpressed" };
        
        [self.sourceArray removeLastObject];
        [self.sourceArray addObject:dic];
        [self.tableViewMenu reloadData];
    }
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
            case JAMenuViewControllerOpenSearchBar:
                [self.customNavBar becomeFirstResponder];
                break;
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
    else
    {
        switch (self.nextAction) {
            case JAMenuViewControllerOpenSearchBar:
                [self.customNavBar resignFirstResponder];
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
        
        [self.customNavBar.searchBar resignFirstResponder];
    }
}

@end
