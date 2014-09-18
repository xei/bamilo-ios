//
//  JASubCategoriesViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 29/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASubCategoriesViewController.h"
#import "RICategory.h"
#import "RICustomer.h"

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
    return self.sourceCategoriesArray.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (0 == indexPath.row) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"parentCategoryCell"];
        
        cell.backgroundColor = UIColorFromRGB(0xf2f2f2);
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        if (VALID_NOTEMPTY(self.parentCategory, RICategory)) {
            
            cell.textLabel.text = [self.parentCategory.name uppercaseString];
            cell.textLabel.textColor = UIColorFromRGB(0x4e4e4e);
        } else {
            
            cell.textLabel.text = [STRING_CATEGORIES uppercaseString];
            cell.textLabel.textColor = UIColorFromRGB(0xc8c8c8);
        }
    } else {
    
        NSInteger realIndex = indexPath.row - 1;
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        
        RICategory *category = [self.sourceCategoriesArray objectAtIndex:realIndex];
        
        cell.textLabel.text = category.name;
        
        if (category.children.count > 0) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    if (0 == indexPath.row) {
        
        if (VALID_NOTEMPTY(self.parentCategory, RICategory)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification
                                                                object:@{@"category":self.parentCategory}];
        }
    } else {
        NSInteger realIndex = indexPath.row - 1;
        
        RICategory *category = [self.sourceCategoriesArray objectAtIndex:realIndex];

        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:category.name forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"Categories" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCategories]
                                                  data:[trackingDictionary copy]];
        
        if (VALID(category, RICategory) && category.children.count > 0) {
            
            UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main"
                                                            bundle:nil];
            
            JASubCategoriesViewController *newSubCategories = [story instantiateViewControllerWithIdentifier:@"subCategoriesViewController"];
            newSubCategories.sourceCategoriesArray = category.children.array;
            newSubCategories.parentCategory = category;
            
            [self.navigationController pushViewController:newSubCategories
                                                 animated:YES];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectLeafCategoryNotification
                                                                object:@{@"category":category}];
        }
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 30.0f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sectionHeader"];
//    
//    cell.textLabel.text = self.subCategoriesTitle;
//    
//    return cell;
//}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

@end
