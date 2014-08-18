//
//  JAChooseCountryViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "JAChooseCountryViewController.h"
#import "UIImageView+WebCache.h"
#import "RICountry.h"
#import "JACountryCell.h"

@interface JAChooseCountryViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource
>

@property (strong, nonatomic) NSArray *countriesArray;
@property (strong, nonatomic) NSString *requestId;
@property (weak, nonatomic) IBOutlet UITableView *tableViewContries;
@property (strong, nonatomic) NSIndexPath *selectedIndex;

@end

@implementation JAChooseCountryViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyButtonPressed)
                                                 name:kDidPressApplyNotification
                                               object:nil];
    
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Selected apply

- (void)applyButtonPressed
{
    if (self.selectedIndex)
    {
        RICountry *country = [self.countriesArray objectAtIndex:self.selectedIndex.row];
        
        [self.delegate didSelectedCountry:country];
    }
}

#pragma mark - Tableview delegates

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.countriesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JACountryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"countryCell"];
    
    RICountry *country = [self.countriesArray objectAtIndex:indexPath.row];
    
    cell.countryName.text = country.name;
    
    [cell.countryImage setImageWithURL:[NSURL URLWithString:country.flag]];
    
    cell.countryImage.layer.cornerRadius = cell.countryImage.frame.size.height /2;
    cell.countryImage.layer.masksToBounds = YES;
    cell.countryImage.layer.borderWidth = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.selectedIndex)
    {
        JACountryCell *previousCell = (JACountryCell *)[tableView cellForRowAtIndexPath:self.selectedIndex];
        previousCell.checkImage.hidden = YES;
        
        JACountryCell *cell = (JACountryCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.checkImage.hidden = NO;
        
        self.selectedIndex = indexPath;
    }
    else
    {
        JACountryCell *cell = (JACountryCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.checkImage.hidden = NO;
        
        self.selectedIndex = indexPath;
    }
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
