//
//  JAChooseCountryViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAChooseCountryViewController.h"
#import "UIImageView+WebCache.h"
#import "RICountry.h"

@interface JAChooseCountryViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource
>

@property (strong, nonatomic) NSArray *countriesArray;
@property (strong, nonatomic) NSString *requestId;
@property (weak, nonatomic) IBOutlet UITableView *tableViewContries;

@end

@implementation JAChooseCountryViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableViewContries.layer.cornerRadius = 5.0f;
    
    [self showLoading];
    
    self.requestId = [RICountry getCountriesWithSuccessBlock:^(id countries) {
        
        self.countriesArray = [NSArray arrayWithArray:countries];
        
        [self hideLoading];
        
        [self.tableViewContries reloadData];
        
    } andFailureBlock:^(NSArray *errorMessages) {
        
        [self hideLoading];
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Tableview delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.countriesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"countryCell"];
    
    RICountry *country = [self.countriesArray objectAtIndex:indexPath.row];
    
    cell.textLabel.text = country.name;
    
    [cell.imageView setImageWithURL:[NSURL URLWithString:country.flag]];
    
    return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
