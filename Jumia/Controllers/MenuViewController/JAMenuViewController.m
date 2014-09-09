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
#import "RISearchSuggestion.h"
#import "RICustomer.h"
#import <FacebookSDK/FacebookSDK.h>
#import <FacebookSDK/FBSession.h>
#import "RISearchSuggestion.h"
#import "RICart.h"

@interface JAMenuViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate
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
@property (weak, nonatomic) IBOutlet UIView *cartView;

@end

@implementation JAMenuViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"";
    
    [self showLoading];
    
    [self initSourceArray];
    
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
                                             selector:@selector(updateCart:)
                                                 name:kUpdateCartNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:nil
                                                 name:kUserLoggedOutNotification
                                               object:nil];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cartViewPressed:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.cartView addGestureRecognizer:tapRecognizer];
    self.cartLabelTitle.text = @"Shopping Cart";
    self.cartLabelTotalCost.text = @"Your cart is empty";
    self.cartLabelDetails.text = @"";
    self.cartItensNumber.text = @"";
    
    [self.customNavBar setSearchBarDelegate:self];
    
    // Added because of the footer space
    self.tableViewMenu.contentInset = UIEdgeInsetsMake(0, 0, -20, 0);
    
    [RICategory getCategoriesWithSuccessBlock:^(id categories) {
        
        self.categories = [NSArray arrayWithArray:(NSArray *)categories];
        
        [self hideLoading];
        
    } andFailureBlock:^(NSArray *errorMessage) {
        
        [self hideLoading];
        
        [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                    message:@"Error getting the categories."
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil] show];
        
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    //this is here to override super DO NOT CALL SUPER
}

- (void)updateCart:(NSNotification*) notification
{
    if ([kUpdateCartNotification isEqualToString:notification.name])
    {
        NSDictionary* userInfo = notification.userInfo;
        RICart *cart = [userInfo objectForKey:kUpdateCartNotificationValue];
        
        if(0 == [[cart cartCount] integerValue])
        {
            self.cartLabelTotalCost.text = @"Your cart is empty";
            self.cartLabelDetails.text = @"";
            self.cartItensNumber.text = @"";
        }
        else
        {
            self.cartLabelTotalCost.text =  [cart cartValueFormatted];
            self.cartLabelDetails.text = @"VAT and Shipping costs included";
            self.cartItensNumber.text = [[cart cartCount] stringValue];
        }
    }
}

- (void)cartViewPressed:(UIGestureRecognizer*)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCartNotification object:nil userInfo:nil];
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
        [segue.destinationViewController setSubCategoriesTitle:@"Categories"];
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
    
    if (self.resultsTableView == tableView) {
        
        RISearchSuggestion *sugestion = [self.resultsArray objectAtIndex:indexPath.row];
        cell.textLabel.text = sugestion.item;
        
        if (1 == sugestion.isRecentSearch) {
            cell.imageView.image = [UIImage imageNamed:@"FavButtonPressed"];
        } else {
            [cell.imageView removeFromSuperview];
        }
        
    } else {
        
        cell.textLabel.text = [[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"name"];
        
        cell.imageView.image = [UIImage imageNamed:[[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
        cell.imageView.highlightedImage = [UIImage imageNamed:[[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"selected"]];
        
        if (1 == indexPath.row) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    [self.customNavBar resignFirstResponder];
    
    if (self.resultsTableView == tableView) {

        RISearchSuggestion *suggestion = [self.resultsArray objectAtIndex:indexPath.row];
    
        [RISearchSuggestion saveSearchSuggestionOnDB:suggestion.item
                                      isRecentSearch:YES];
        
        // I changed the index to 99 to know that it's to display a search result
        [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                            object:@{@"index": @(99),
                                                                     @"name": @"Search",
                                                                     @"text": suggestion.item }];
        
    } else {
        
        if (1 == indexPath.row) {
            
            [self.customNavBar addBackButtonToNavBar];
            
            [self performSegueWithIdentifier:@"showSubCategories"
                                      sender:nil];
        } else {
            
            if (8 == indexPath.row) {
                if ([RICustomer checkIfUserIsLogged])
                {
                    [RICustomer logoutCustomerWithSuccessBlock:^{
                        
                        [[FBSession activeSession] closeAndClearTokenInformation];
                        
                        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                        
                        for (NSHTTPCookie* cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
                            [cookies deleteCookie:cookie];
                        }
                        
                        [self userDidLogout];
                        
                    } andFailureBlock:^(NSArray *errorObject) {
                        
                        [[FBSession activeSession] closeAndClearTokenInformation];
                        
                        NSHTTPCookieStorage* cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                        
                        for (NSHTTPCookie* cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
                            [cookies deleteCookie:cookie];
                        }
                        
                        [self userDidLogout];
                        
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

#pragma mark - Navigation bar custom delegate

- (void)didPressedBackButton
{
    if (self.resultsTableView != nil) {
        [self.customNavBar.searchBar resignFirstResponder];
        self.customNavBar.searchBar.text = @"";
        [self.customNavBar removeBackButtonFromNavBar];
        [self removeResultsTableViewFromView];
    } else {
        
        self.customNavBar.backButton.userInteractionEnabled = NO;
        
        if (self.navigationController.viewControllers.count > 1) {
            if (self.navigationController.viewControllers.count == 2) {
                [self.customNavBar removeBackButtonFromNavBar];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        } else {
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
    [self.customNavBar addBackButtonToNavBar];
    
    [self addResultsTableViewToView];
    
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
                                                                 @"name": @"Search",
                                                                 @"text": searchBar.text }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    
    [self removeResultsTableViewFromView];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 1)
    {
        [RISearchSuggestion getSuggestionsForQuery:searchText
                                      successBlock:^(NSArray *suggestions) {
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              self.resultsArray = [suggestions mutableCopy];
                                              
                                              [self.resultsTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                                                   withRowAnimation:UITableViewRowAnimationFade];
                                          });
                                      } andFailureBlock:^(NSArray *errorMessages) {
                                          
                                      }];
    }
}

#pragma mark - Results table view methods

- (void)addResultsTableViewToView
{
    if (self.resultsTableView == nil) {
        
        self.resultsArray = [NSMutableArray new];
        
        CGRect resultsTableFrame = CGRectMake(self.cartView.frame.origin.x,
                                              self.cartView.frame.origin.y,
                                              self.cartView.frame.size.width,
                                              self.navigationController.view.frame.size.height);
        
        resultsTableFrame.origin.y += resultsTableFrame.size.height;
        
        self.resultsTableView = [[UITableView alloc] initWithFrame:resultsTableFrame
                                                             style:UITableViewStyleGrouped];
        
        self.resultsTableView.backgroundColor = [UIColor colorWithRed:1.0f
                                                                green:1.0f
                                                                 blue:1.0f
                                                                alpha:0.78f];
        self.resultsTableView.delegate = self;
        self.resultsTableView.dataSource = self;
        
        self.resultsTableView.contentInset = UIEdgeInsetsMake(-35.0f, 0.f, 0.f, 0.f);
        
        [self.resultsTableView registerClass:[UITableViewCell class]
                      forCellReuseIdentifier:@"cell"];
        
        [self.view addSubview:self.resultsTableView];
        
        [UIView animateWithDuration:0.4f
                         animations:^{
                             CGRect newFrame = self.resultsTableView.frame;
                             newFrame.origin.y = self.cartView.frame.origin.y;
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
    self.sourceArray = [@[@{ @"name": @"Home",
                             @"image": @"ico_home",
                             @"selected": @"ico_home_pressed" },
                          @{ @"name": @"Categories",
                             @"image": @"ico_categories",
                             @"selected": @"ico_categories_pressed" },
                          @{ @"name": @"My Favourites",
                             @"image": @"ico_favourites",
                             @"selected": @"ico_favourites_pressed" },
                          @{ @"name": @"Recent Searches",
                             @"image": @"ico_recentsearches",
                             @"selected": @"ico_recentsearches_pressed" },
                          @{ @"name": @"Recently Viewed",
                             @"image": @"ico_recentlyviewed",
                             @"selected": @"ico_recentlyviewed_pressed" },
                          @{ @"name": @"My Account",
                             @"image": @"ico_myaccount",
                             @"selected": @"ico_myaccount_pressed" },
                          @{ @"name": @"Track my Order",
                             @"image": @"ico_trackorder",
                             @"selected": @"ico_trackorder_pressed" },
                          @{ @"name": @"Choose Country",
                             @"image": @"ico_choosecountry",
                             @"selected": @"ico_choosecountry_pressed" },
                          @{ @"name": @"Sign In",
                             @"image": @"ico_sign",
                             @"selected": @"ico_signpressed" }] mutableCopy];
    
    if ([RICustomer checkIfUserIsLogged])
    {
        NSDictionary *dic = @{ @"name": @"Sign Out",
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
    NSDictionary *dic = @{ @"name": @"Sign Out",
                           @"image": @"ico_sign",
                           @"selected": @"ico_signpressed" };
    
    [self.sourceArray removeLastObject];
    [self.sourceArray addObject:dic];
    [self.tableViewMenu reloadData];
}

- (void)userDidLogout
{
    NSDictionary *dic = @{ @"name": @"Sign In",
                           @"image": @"ico_sign",
                           @"selected": @"ico_signpressed" };
    
    [self.sourceArray removeLastObject];
    [self.sourceArray addObject:dic];
    [self.tableViewMenu reloadData];
}

@end
