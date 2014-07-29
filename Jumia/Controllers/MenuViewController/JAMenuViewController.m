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

@interface JAMenuViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate
>

@property (strong, nonatomic) NSArray *sourceArray;
@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) JAMenuNavigationBar *customNavBar;
@property (strong, nonatomic) UIImageView *loadingImageView;
@property (strong, nonatomic) UIActivityIndicatorView *loadingSpinner;
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
    
    self.title = @"";
    
    [self initLoadingScreen];
    [self showLoading];
    [self initSourceArray];
    
    self.customNavBar = [[JAMenuNavigationBar alloc] init];
    [self.navigationController setValue:self.customNavBar forKeyPath:@"navigationBar"];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didPressedBackButton)
                                                 name:@"PRESSED_BACK_BUTTON"
                                               object:nil];
    
    self.cartLabelTitle.text = @"Shopping Cart";
    self.cartLabelTotalCost.text = @"RM 893.00";
    self.cartLabelDetails.text = @"10% VAT and Shipping costs included";
    
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
    
    [self.customNavBar resignFirstResponder];
    
    if (1 == indexPath.row) {
        
        [self.customNavBar addBackButtonToNavBar];
        
        [self performSegueWithIdentifier:@"showSubCategories"
                                  sender:self.categories];
    }
}

#pragma mark - Navigation bar custom delegate

- (void)didPressedBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
    
    if (self.navigationController.viewControllers.count == 1) {
        [self.customNavBar removeBackButtonFromNavBar];
    }
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

#pragma mark - Loading screen

- (void)initLoadingScreen
{
    self.loadingImageView = [[UIImageView alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].rootViewController.view.frame];
    self.loadingImageView.backgroundColor = [UIColor blackColor];
    self.loadingImageView.alpha = 0.0f;
    self.loadingImageView.userInteractionEnabled = YES;
    
    self.loadingSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.loadingSpinner.center = self.loadingImageView.center;
    self.loadingImageView.alpha = 0.0f;
}

- (void)showLoading
{
    [[[[UIApplication sharedApplication] delegate] window].rootViewController.view addSubview:self.loadingImageView];
    [[[[UIApplication sharedApplication] delegate] window].rootViewController.view addSubview:self.loadingSpinner];
    
    [self.loadingSpinner startAnimating];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.loadingImageView.alpha = 0.6f;
                         self.loadingSpinner.alpha = 0.6f;
                     }];
}

- (void)hideLoading
{
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.loadingImageView.alpha = 0.0f;
                         self.loadingSpinner.alpha = 0.0f;
                     } completion:^(BOOL finished) {
                         [self.loadingImageView removeFromSuperview];
                         [self.loadingSpinner removeFromSuperview];
                     }];
}

@end
