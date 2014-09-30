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
#import "RIApi.h"

@interface JAChooseCountryViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource,
    JANoConnectionViewDelegate
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
    
    self.screenName = @"ChooseCountry";
    
    self.navBarLayout.title = STRING_CHOOSE_COUNTRY;
    self.navBarLayout.doneButtonTitle = STRING_APPLY;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyButtonPressed)
                                                 name:kDidPressDoneNotification
                                               object:nil];
    
    self.tableViewContries.layer.cornerRadius = 5.0f;
    
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self loadData];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self loadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideLoading];
}

#pragma mark - No connection delegate

- (void)retryConnection
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self loadData];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self loadData];
    }
}

#pragma mark - Load data

- (void)loadData
{
    [self showLoading];
    
    self.requestId = [RICountry getCountriesWithSuccessBlock:^(id countries) {
        
        self.countriesArray = [NSArray arrayWithArray:countries];
        
        [self hideLoading];
        
        [self.tableViewContries reloadData];
        
        NSString *countryUrl = [RIApi getCountryUrlInUse];
        
        NSIndexPath *tempIndex;
        
        if (0 != countryUrl.length) {
            NSInteger index = 0;
            
            for (RICountry *country in countries) {
                if ([country.url isEqualToString:countryUrl]) {
                    tempIndex = [NSIndexPath indexPathForItem:index
                                                    inSection:0];
                    break;
                }
                index++;
            }
        }
        
        if (VALID_NOTEMPTY(tempIndex, NSIndexPath)) {
            [self tableView:self.tableViewContries didSelectRowAtIndexPath:tempIndex];
        }
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
    } andFailureBlock:^(NSArray *errorMessages) {
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }

        [self hideLoading];
        
    }];
}

#pragma mark - Selected apply

- (void)applyButtonPressed
{
    if (self.selectedIndex)
    {
        RICountry *country = [self.countriesArray objectAtIndex:self.selectedIndex.row];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedCountryNotification object:country];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kEditShouldChangeStateNotification object:nil userInfo:@{@"enabled":[NSNumber numberWithBool:YES]}];
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

@end
