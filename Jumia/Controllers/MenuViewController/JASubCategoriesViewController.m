//
//  JASubCategoriesViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 29/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASubCategoriesViewController.h"
#import "RICategory.h"

@interface JASubCategoriesViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate
>

@property (weak, nonatomic) IBOutlet UITableView *tableViewCategories;
@property (weak, nonatomic) IBOutlet UILabel *cartTitle;
@property (weak, nonatomic) IBOutlet UILabel *cartCost;
@property (weak, nonatomic) IBOutlet UILabel *cartDetails;
@property (weak, nonatomic) IBOutlet UILabel *cartCount;

@end

@implementation JASubCategoriesViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = NO;
    
    self.cartTitle.text = self.subCategoriesCartTitle;
    self.cartCost.text = self.subCategoriesCartPrice;
    self.cartDetails.text = self.subCategoriesCartDetails;
    self.cartCount.text = self.subCategoriesCarCount;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Tableview delegates and datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sourceCategoriesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    RICategory *category = [self.sourceCategoriesArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = category.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    RICategory *category = [self.sourceCategoriesArray objectAtIndex:indexPath.row];
    
    if (category.children.count > 0) {
        
        UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main"
                                                        bundle:nil];
        
        JASubCategoriesViewController *newSubCategories = [story instantiateViewControllerWithIdentifier:@"subCategoriesViewController"];
        newSubCategories.sourceCategoriesArray = category.children.array;
        newSubCategories.subCategoriesCartTitle = self.cartTitle.text;
        newSubCategories.subCategoriesCartPrice = self.cartCost.text;
        newSubCategories.subCategoriesCartDetails = self.cartDetails.text;
        newSubCategories.subCategoriesCarCount = self.cartCount.text;
        
        [self.navigationController showViewController:newSubCategories
                                               sender:nil];
    } else {
        
    }
    
#warning implement when it's the tail subcategory
}

@end
