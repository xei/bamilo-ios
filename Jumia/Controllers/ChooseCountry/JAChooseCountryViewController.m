//
//  JAChooseCountryViewController.m
//  Jumia
//
//  Created by Jose Mota on 23/03/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JAChooseCountryViewController.h"
#import "JAPicker.h"
#import "JAChooseCountryTableViewCell.h"

@interface JAChooseCountryViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
JAPickerDelegate
>

@property (strong, nonatomic) NSArray *countriesArray;
@property (strong, nonatomic) NSString *requestId;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSIndexPath *selectedIndex;
@property (assign, nonatomic) RIApiResponse apiResponse;

@property (nonatomic, strong) JAPicker* languagePicker;
@property (nonatomic, strong) NSIndexPath* pickerIndexPath;

@end

@implementation JAChooseCountryViewController


#pragma mark - View Lifecycle

- (UITableView *)tableView
{
    if (!VALID(_tableView, UITableView)) {
        _tableView = [[UITableView alloc] initWithFrame:self.viewBounds];
        [_tableView setDataSource:self];
        [_tableView setDelegate:self];
        [_tableView registerClass:[JAChooseCountryTableViewCell class] forCellReuseIdentifier:@"countryCell"];
        [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return _tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.apiResponse = RIApiResponseSuccess;
    self.screenName = @"ChooseCountry";
    
    self.navBarLayout.title = STRING_CHOOSE_COUNTRY;
    self.navBarLayout.doneButtonTitle = STRING_APPLY;
    
    [self.view addSubview:self.tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applyButtonPressed)
                                                 name:kDidPressDoneNotification
                                               object:nil];
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
    [super viewWillDisappear:animated];
    [self hideLoading];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if(VALID(self.languagePicker, JAPicker))
    {
        [self.languagePicker removeFromSuperview];
    }
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)viewWillLayoutSubviews
{
    if (!CGRectEqualToRect(self.tableView.frame, self.viewBounds)) {
        [self.tableView setFrame:self.viewBounds];
        [self.tableView reloadData];
    }
    [super viewWillLayoutSubviews];
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
        
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        
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
        
        [self.tableView reloadData];
        
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
        
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(loadData) objects:nil];
        [self hideLoading];
        
    }];
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
    return kCountryCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.countriesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RICountry *country = [self.countriesArray objectAtIndex:indexPath.row];
    
    JAChooseCountryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"countryCell"];
    
    [cell setCountry:country];
    [cell setSelectedCountry:VALID_NOTEMPTY(self.selectedIndex, NSIndexPath) && self.selectedIndex.row == indexPath.row];
    
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
    self.selectedIndex = indexPath;
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDoneShouldChangeStateNotification object:nil userInfo:@{@"enabled":[NSNumber numberWithBool:YES]}];
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
