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

@end

@implementation JASubCategoriesViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"";
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.hidesBackButton = YES;
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
    
    if (category.children.count > 0) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
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
        newSubCategories.subCategoriesTitle = category.name;
        
        [self.navigationController pushViewController:newSubCategories
                                             animated:YES];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification
                                                            object:@{@"categoryName":category.name, @"categoryUrl":category.urlKey}];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sectionHeader"];
    
    cell.textLabel.text = self.subCategoriesTitle;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

@end
