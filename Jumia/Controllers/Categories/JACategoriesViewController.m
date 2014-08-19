//
//  JACategoriesViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 19/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACategoriesViewController.h"
#import "RICategory.h"

@interface JACategoriesViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray* categories;

@end

@implementation JACategoriesViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self showLoading];
    [RICategory getCategoriesWithSuccessBlock:^(id categories) {
        self.categories = categories;
        [self hideLoading];
        [self.tableView reloadData];
    } andFailureBlock:^(NSArray *errorMessage) {
        [self hideLoading];
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categories.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"categoryCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    RICategory* category = [self.categories objectAtIndex:indexPath.row];
    
    cell.textLabel.text = category.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RICategory* category = [self.categories objectAtIndex:indexPath.row];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectCategoryFromCenterPanelNotification
                                                        object:@{@"category":category}];
}


@end
