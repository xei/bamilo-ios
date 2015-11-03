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
#import "JAPicker.h"
#import "RILanguage.h"

@interface JAChooseCountryViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
JAPickerDelegate
>

@property (strong, nonatomic) NSArray *countriesArray;
@property (strong, nonatomic) NSString *requestId;
@property (weak, nonatomic) IBOutlet UITableView *tableViewContries;
@property (strong, nonatomic) NSIndexPath *selectedIndex;
@property (assign, nonatomic) RIApiResponse apiResponse;

@property (nonatomic, strong) JAPicker* languagePicker;
@property (nonatomic, strong) NSIndexPath* pickerIndexPath;

@end

@implementation JAChooseCountryViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.apiResponse = RIApiResponseSuccess;
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffMenuSwipePanelNotification
                                                            object:nil];
    }

    [self loadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance]trackScreenWithName:@"ChangeCountry"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideLoading];
}

#pragma mark - Load data

- (void)loadData
{
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    
    NSString *countryUrl = [RIApi getCountryUrlInUse];
    
    self.requestId = [RICountry getCountriesWithSuccessBlock:^(id countries) {
        
        self.countriesArray = [NSArray arrayWithArray:countries];
        
        [self removeErrorView];
        
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
        self.apiResponse = apiResponse;
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
        else if(RIApiResponseKickoutView == apiResponse)
        {
            [self showKickoutView:@selector(loadData) objects:nil];
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
    if(VALID(self.languagePicker, JAPicker))
    {
        [self.languagePicker removeFromSuperview];
    }
    
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
        if (ISEMPTY(country.selectedLanguage)) {
            country.selectedLanguage = [country.languages objectAtIndex:0];
        }
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
    RICountry* selectedCountry = [self.countriesArray objectAtIndex:indexPath.row];
    if (VALID_NOTEMPTY(selectedCountry.languages, NSArray) && selectedCountry.languages.count > 1) {
        self.pickerIndexPath = indexPath;
        [self openLanguagePicker];
    } else {
        [self selectCellAtIndexPath:indexPath];
    }
}

- (void)selectCellAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.selectedIndex)
    {
        JACountryCell *previousCell = (JACountryCell *)[self.tableViewContries cellForRowAtIndexPath:self.selectedIndex];
        previousCell.checkImage.hidden = YES;
        
        JACountryCell *cell = (JACountryCell *)[self.tableViewContries cellForRowAtIndexPath:indexPath];
        cell.checkImage.hidden = NO;
        
        self.selectedIndex = indexPath;
    }
    else
    {
        JACountryCell *cell = (JACountryCell *)[self.tableViewContries cellForRowAtIndexPath:indexPath];
        cell.checkImage.hidden = NO;
        
        self.selectedIndex = indexPath;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDoneShouldChangeStateNotification object:nil userInfo:@{@"enabled":[NSNumber numberWithBool:YES]}];
    
    [self.tableViewContries deselectRowAtIndexPath:indexPath
                                          animated:YES];
}


#pragma mark - Picker

-(void)removePickerView
{
    if(VALID_NOTEMPTY(self.languagePicker, JAPicker))
    {
        [self.languagePicker removeFromSuperview];
        self.languagePicker = nil;
    }
}

- (void)openLanguagePicker
{
    [self removePickerView];
    
    RICountry* country = [self.countriesArray objectAtIndex:self.pickerIndexPath.row];
    
    self.languagePicker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.languagePicker setDelegate:self];
    
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    NSString* autoSelected;
    for (RILanguage* language in country.languages) {
        if (VALID_NOTEMPTY(language, RILanguage)) {
            [dataSource addObject:language.langName];
            if ([language.langDefault boolValue]) {
                autoSelected = language.langName;
            }
        }
    }
    
    [self.languagePicker setDataSourceArray:[dataSource copy]
                               previousText:autoSelected
                            leftButtonTitle:nil];
    
    CGFloat pickerViewHeight = self.view.frame.size.height;
    CGFloat pickerViewWidth = self.view.frame.size.width;
    [self.languagePicker setFrame:CGRectMake(0.0f,
                                             pickerViewHeight,
                                             pickerViewWidth,
                                             pickerViewHeight)];
    [self.view addSubview:self.languagePicker];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.languagePicker setFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  pickerViewWidth,
                                                                  pickerViewHeight)];
                     }];
}

- (void)selectedRow:(NSInteger)selectedRow
{
    RICountry* country = [self.countriesArray objectAtIndex:self.pickerIndexPath.row];
    if (VALID_NOTEMPTY(country, RICountry)) {
        if (VALID_NOTEMPTY(country.languages, NSArray)) {
            country.selectedLanguage = [country.languages objectAtIndex:selectedRow];
            [self selectCellAtIndexPath:self.pickerIndexPath];
            self.pickerIndexPath = nil;
        }
    }
    
    [self removePickerView];
}




@end
