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

@interface JAMenuViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate
>

@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSArray *sourceArray;
@property (strong, nonatomic) NSArray *categories;
@property (weak, nonatomic) IBOutlet UITableView *tableViewMenu;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCart;
@property (weak, nonatomic) IBOutlet UILabel *cartLabelTitle;
@property (weak, nonatomic) IBOutlet UILabel *cartLabelTotalCost;
@property (weak, nonatomic) IBOutlet UILabel *cartLabelDetails;
@property (weak, nonatomic) IBOutlet UILabel *cartItensNumber;

@end

@implementation JAMenuViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSourceArray];
    
    NSArray *leftBarButtons = [[NSArray alloc] initWithObjects:[self createSearchBarHolder], nil];
    self.navigationItem.leftBarButtonItems = leftBarButtons;

    self.cartLabelTitle.text = @"Shopping Cart";
    self.cartLabelTotalCost.text = @"RM 893.00";
    self.cartLabelDetails.text = @"10% VAT and Shipping costs included";
    
    [RICategory getCategoriesWithSuccessBlock:^(id categories) {
        
        self.categories = [NSArray arrayWithArray:(NSArray *)categories];
        
    } andFailureBlock:^(NSArray *errorMessage) {
        
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showSubCategories"]) {
        [segue.destinationViewController setSourceCategoriesArray:sender];
        [segue.destinationViewController setSubCategoriesTitle:@"Categories"];
    }
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
    
    cell.textLabel.text = [[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    cell.imageView.image = [UIImage imageNamed:[[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"image"]];
    cell.imageView.highlightedImage = [UIImage imageNamed:[[self.sourceArray objectAtIndex:indexPath.row] objectForKey:@"selected"]];
    
    if (1 == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    
    [self.searchBar resignFirstResponder];
    
    if (1 == indexPath.row) {
        [self performSegueWithIdentifier:@"showSubCategories"
                                  sender:self.categories];
    }
}

#pragma mark - Auxiliar methods

- (UIBarButtonItem *)createSearchBarHolder
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5, 0, (self.view.frame.size.width * 0.74), 44)];
    self.searchBar.barTintColor = [UIColor whiteColor];
    self.searchBar.placeholder = @"Search";
    
    UITextField *textFieldSearch = [self.searchBar valueForKey:@"_searchField"];
    textFieldSearch.backgroundColor = [UIColor colorWithRed:242.0/255.0 green:242.0/255.0 blue:242.0/255.0 alpha:1.0f];
    
    self.searchBar.layer.borderWidth = 1;
    self.searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
    
    UIView *searchBarContainer = [[UIView alloc] initWithFrame:self.searchBar.frame];
    searchBarContainer.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
    [searchBarContainer addSubview:self.searchBar];
    self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    UIBarButtonItem *searchBarHolder = [[UIBarButtonItem alloc] initWithCustomView:searchBarContainer];
    return searchBarHolder;
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
