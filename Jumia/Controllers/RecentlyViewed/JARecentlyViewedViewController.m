//
//  JARecentlyViewedViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARecentlyViewedViewController.h"
#import "RIProduct.h"

@interface JARecentlyViewedViewController ()

@property (weak, nonatomic) IBOutlet UIView *emptyListView;
@property (weak, nonatomic) IBOutlet UILabel *emptyListLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray* productsArray;

@end

@implementation JARecentlyViewedViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    self.view.backgroundColor = UIColorFromRGB(0xc8c8c8);
    
    self.emptyListView.layer.cornerRadius = 3.0f;
    
    self.emptyListLabel.textColor = UIColorFromRGB(0xcccccc);
    self.emptyListLabel.text = @"No recently viewed products here";
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self showLoading];
    [RIProduct getRecentlyViewedProductsWithSuccessBlock:^(NSArray *recentlyViewedProducts) {

        [self hideLoading];
        self.productsArray = recentlyViewedProducts;
        
        if (ISEMPTY(recentlyViewedProducts)) {
            self.emptyListView.hidden = NO;
            self.tableView.hidden = YES;
        } else {
            self.emptyListView.hidden = YES;
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        }
    } andFailureBlock:^(NSArray *error) {
        [self hideLoading];
    }];
}

#pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productsArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"recentlyViewedCell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (ISEMPTY(cell)) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    RIProduct* product = [self.productsArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = product.name;
    
    return cell;
}

@end
