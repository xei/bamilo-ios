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
    
    self.screenName = @"ChooseCountry";
    
    self.navBarLayout.title = STRING_CHOOSE_COUNTRY;
    self.navBarLayout.doneButtonTitle = STRING_APPLY;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyButtonPressed)
                                                 name:kDidPressDoneNotification
                                               object:nil];
    
    self.tableViewContries.layer.cornerRadius = 5.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if(!VALID_NOTEMPTY([RIApi getCountryUrlInUse], NSString))
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                            object:nil];
    }

    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideLoading];
}

#pragma mark - Load data

- (void)loadData
{
    [self showLoading];
    
    NSString *countryUrl = [RIApi getCountryUrlInUse];
    
    self.requestId = [RICountry getCountriesWithSuccessBlock:^(id countries) {
        
        self.countriesArray = [NSArray arrayWithArray:countries];
        
        [self hideLoading];
        
        NSIndexPath *tempIndex;
        
        if (VALID_NOTEMPTY(countryUrl, NSString))
        {
            NSInteger index = 0;
            
            for (RICountry *country in countries) {
                if ([country.url isEqualToString:countryUrl]) {
                    tempIndex = [NSIndexPath indexPathForItem:index
                                                    inSection:0];
                    break;
                }
                index++;
            }
            
            if(self.firstLoading)
            {
                NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                self.firstLoading = NO;
            }
        }
        
        if (VALID_NOTEMPTY(tempIndex, NSIndexPath)) {
            
            self.selectedIndex = tempIndex;
        }
        
        [self.tableViewContries reloadData];
        
        CGFloat finalHeight = MIN(self.tableViewContries.frame.size.height, self.tableViewContries.contentSize.height - 20.0f);
        [self.tableViewContries setFrame:CGRectMake(self.tableViewContries.frame.origin.x,
                                                    self.tableViewContries.frame.origin.y,
                                                    self.tableViewContries.frame.size.width,
                                                    finalHeight)];
        
    } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages) {
        
        if (VALID_NOTEMPTY(countryUrl, NSString))
        {
            if(self.firstLoading)
            {
                NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
                [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
                self.firstLoading = NO;
            }
        }

        if(RIApiResponseMaintenancePage == apiResponse)
        {
            [self showMaintenancePage:@selector(loadData) objects:nil];
        }
        else
        {
            BOOL noConnection = NO;
            if (RIApiResponseNoInternetConnection == apiResponse)
            {
                noConnection = YES;
            }
            [self showErrorView:noConnection startingY:0.0f selector:@selector(loadData) objects:nil];
        }
        
        [self hideLoading];
        
    }];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    self.tableViewContries.hidden = YES;
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self hideLoading];

    CGFloat finalHeight = MIN(self.tableViewContries.frame.size.height, self.tableViewContries.contentSize.height - 20.0f);
    [self.tableViewContries setFrame:CGRectMake(self.tableViewContries.frame.origin.x,
                                                self.tableViewContries.frame.origin.y,
                                                self.tableViewContries.frame.size.width,
                                                finalHeight)];
    self.tableViewContries.hidden = NO;
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
    
    
    if (VALID_NOTEMPTY(self.selectedIndex, NSIndexPath) && self.selectedIndex.row == indexPath.row) {
        cell.checkImage.hidden = NO;
    } else {
        cell.checkImage.hidden = YES;
    }
    
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDoneShouldChangeStateNotification object:nil userInfo:@{@"enabled":[NSNumber numberWithBool:YES]}];
    
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
}


@end
