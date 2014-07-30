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

@interface JAMenuViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    UISearchBarDelegate
>

@property (strong, nonatomic) NSArray *sourceArray;
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
    
    self.cartLabelTitle.text = @"Shopping Cart";
    self.cartLabelTotalCost.text = @"RM 893.00";
    self.cartLabelDetails.text = @"10% VAT and Shipping costs included";
    
    [self.customNavBar setSearchBarDelegate:self];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue.identifier isEqualToString:@"showSubCategories"]) {
//        [segue.destinationViewController setSourceCategoriesArray:sender];
//        [segue.destinationViewController setSubCategoriesTitle:@"Categories"];
//    }
//}

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
#warning implement the missing code
    } else {
        
        if (1 == indexPath.row) {
            
            [self.customNavBar addBackButtonToNavBar];
            
            JASubCategoriesViewController *subCategories = [[UIStoryboard storyboardWithName:@"Main"
                                                                                      bundle:nil] instantiateViewControllerWithIdentifier:@"subCategoriesViewController"];
            subCategories.sourceCategoriesArray = self.categories;
            subCategories.subCategoriesTitle = @"Categories";
            
            [self.navigationController pushViewController:subCategories
                                                 animated:YES];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                object:@{@"index": @(indexPath.row),
                                                                         @"name": [[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"name"]}];
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
        
        if (self.navigationController.viewControllers.count > 1) {
            if (self.navigationController.viewControllers.count == 2) {
                [self.customNavBar removeBackButtonFromNavBar];
            }
            
            [self.navigationController popViewControllerAnimated:NO];
        } else {
            [self.customNavBar removeBackButtonFromNavBar];
        }
    }
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
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    
    [self removeResultsTableViewFromView];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
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
    self.sourceArray = @[@{ @"name": @"Home",
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
                            @"selected": @"ico_signpressed" } ];
}

@end
