//
//  JACampaignsViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 25/09/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JACampaignsViewController.h"
#import "RITeaser.h"
#import "RITeaserText.h"
#import "RICart.h"
#import "RICampaign.h"
#import "RICustomer.h"
#import "JAUtils.h"

@interface JACampaignsViewController ()

@property (nonatomic, strong)NSMutableArray* campaignPages;
@property (nonatomic, strong)JAPickerScrollView* pickerScrollView;
@property (nonatomic, strong)UIScrollView* scrollView;
@property (nonatomic, assign)NSInteger elapsedTimeInSeconds;

// size picker view
@property (strong, nonatomic) UIView *sizePickerBackgroundView;
@property (strong, nonatomic) UIToolbar *sizePickerToolbar;
@property (strong, nonatomic) UIPickerView *sizePicker;

// for the retry connection, is necessary to store this stuff
@property (nonatomic, strong)RICampaign* backupCampaign;
@property (nonatomic, strong)NSString* backupSimpleSku;

@property (nonatomic, strong)JACampaignSingleView* lastPressedCampaignSingleView;

@property (nonatomic, assign)BOOL shouldPushPDV;

@end

@implementation JACampaignsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navBarLayout.title = STRING_CAMPAIGNS;
    self.navBarLayout.backButtonTitle = STRING_HOME;
    
    self.pickerScrollView = [[JAPickerScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                                 self.view.bounds.origin.y,
                                                                                 self.view.bounds.size.width,
                                                                                 44.0f)];
    self.pickerScrollView.delegate = self;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                     CGRectGetMaxY(self.pickerScrollView.frame),
                                                                     self.view.bounds.size.width,
                                                                     self.view.bounds.size.height - self.pickerScrollView.frame.size.height - 64.0f)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.delegate = self;

    
    [self loadCampaignPages];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"Campaigns" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
    
    self.elapsedTimeInSeconds = 0;
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self
                                   selector:@selector(updateSeconds)
                                   userInfo:nil
                                    repeats:YES];
    
    self.shouldPushPDV = YES;
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewCampaign] data:trackingDictionary];
}

- (void)loadCampaignPages
{
    [self.view addSubview:self.pickerScrollView];
    
    [self.view addSubview:self.scrollView];
    
    CGFloat currentX = 0.0f;
    
    NSInteger startingIndex = 0;
    self.campaignPages = [NSMutableArray new];
    NSMutableArray* optionList = [NSMutableArray new];
    if (VALID_NOTEMPTY(self.campaignTeasers, NSArray)) {
        for (int i = 0; i < self.campaignTeasers.count; i++) {
            RITeaser* teaser = [self.campaignTeasers objectAtIndex:i];
            if (VALID_NOTEMPTY(teaser.teaserTexts, NSOrderedSet)) {
                RITeaserText* teaserText = [teaser.teaserTexts firstObject];
                if (VALID_NOTEMPTY(teaserText, RITeaserText)) {
                    
                    [optionList addObject:teaserText.name];
                    
                    if ([teaserText.name isEqualToString:self.startingTitle]) {
                        startingIndex = i;
                    }
                    
                    JACampaignPageView* campaignPage = [[JACampaignPageView alloc] initWithFrame:CGRectMake(currentX,
                                                                                                            self.scrollView.bounds.origin.y,
                                                                                                            self.scrollView.bounds.size.width,
                                                                                                            self.scrollView.bounds.size.height)];
                    campaignPage.singleViewDelegate = self;
                    campaignPage.delegate = self;
                    [self.campaignPages addObject:campaignPage];
                    [self.scrollView addSubview:campaignPage];
                    [campaignPage loadWithCampaignUrl:teaserText.url];
                    currentX += campaignPage.frame.size.width;
                }
            }
        }
    }
    
    self.pickerScrollView.startingIndex = startingIndex;
    
    //this will trigger load methods
    [self.pickerScrollView setOptions:optionList];
    
    [self.scrollView setContentSize:CGSizeMake(currentX, self.scrollView.frame.size.height)];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                        object:nil];
}

#pragma mark - JAPickerScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{
    JACampaignPageView* campaignPageView = [self.campaignPages objectAtIndex:index];
    [self.scrollView scrollRectToVisible:campaignPageView.frame animated:YES];
}

- (IBAction)swipeLeft:(id)sender
{
    self.shouldPushPDV = NO;
    [self.pickerScrollView scrollLeftAnimated:YES];
}

- (IBAction)swipeRight:(id)sender
{
    self.shouldPushPDV = NO;
    [self.pickerScrollView scrollRight];
}

#pragma mark - JACampaignPageViewDelegate

- (void)loadFailedWithResponse:(RIApiResponse)apiResponse
{
    BOOL noConnection = NO;
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        noConnection = YES;
    }
    [self showErrorView:noConnection startingY:0.0f selector:@selector(loadCampaignPages) objects:nil];
    
}

#pragma mark - JACampaignSingleViewDelegate

- (void)updateSeconds
{
    self.elapsedTimeInSeconds++;
    for (JACampaignPageView* campaignPage in self.campaignPages) {
        [campaignPage updateTimerOnAllCampaigns:self.elapsedTimeInSeconds];
    }
}

- (void)addToCartForProduct:(RICampaign*)campaign
          withProductSimple:(NSString*)simpleSku;
{
    self.backupCampaign = campaign;
    self.backupSimpleSku = simpleSku;

    [self finishAddToCart];
}

- (void)pressedCampaignWithSku:(NSString*)sku;
{
    if (self.shouldPushPDV) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                            object:nil
                                                          userInfo:@{ @"sku" : sku ,
                                                                      @"show_back_button" : [NSNumber numberWithBool:YES]}];
    }
}

- (void)sizePressedOnView:(JACampaignSingleView*)campaignSingleView;
{
    self.lastPressedCampaignSingleView = campaignSingleView;
    
    self.sizePickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                             0.0f,
                                                                             self.view.frame.size.width,
                                                                             self.view.frame.size.height)];
    [self.sizePickerBackgroundView setBackgroundColor:[UIColor clearColor]];
    
    UITapGestureRecognizer *removePickerViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(removePickerView)];
    [self.sizePickerBackgroundView addGestureRecognizer:removePickerViewTap];
    
    self.sizePicker = [[UIPickerView alloc] init];
    [self.sizePicker setFrame:CGRectMake(self.sizePickerBackgroundView.frame.origin.x,
                                         CGRectGetMaxY(self.sizePickerBackgroundView.frame) - self.sizePicker.frame.size.height,
                                         self.sizePicker.frame.size.width,
                                         self.sizePicker.frame.size.height)];
    [self.sizePicker setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.sizePicker setAlpha:0.9];
    [self.sizePicker setShowsSelectionIndicator:YES];
    [self.sizePicker setDataSource:self];
    [self.sizePicker setDelegate:self];
    
    self.sizePickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.sizePickerToolbar setTranslucent:NO];
    [self.sizePickerToolbar setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.sizePickerToolbar setAlpha:0.9];
    [self.sizePickerToolbar setFrame:CGRectMake(0.0f,
                                                CGRectGetMinY(self.sizePicker.frame) - self.sizePickerToolbar.frame.size.height,
                                                self.sizePickerToolbar.frame.size.width,
                                                self.sizePickerToolbar.frame.size.height)];
    
    UIButton *tmpbutton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tmpbutton setFrame:CGRectMake(0.0, 0.0f, 0.0f, 0.0f)];
    [tmpbutton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [tmpbutton setTitle:STRING_DONE forState:UIControlStateNormal];
    [tmpbutton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [tmpbutton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [tmpbutton addTarget:self action:@selector(selectSize:) forControlEvents:UIControlEventTouchUpInside];
    [tmpbutton sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithCustomView:tmpbutton];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.sizePickerToolbar setItems:[NSArray arrayWithObjects:flexibleItem, doneButton, nil]];
    
    //simple index
    NSInteger simpleIndex = 0;
    for (int i = 0; i < campaignSingleView.campaign.productSimples.count; i++) {
        RICampaignProductSimple* simple = [campaignSingleView.campaign.productSimples objectAtIndex:i];
        if ([simple.size isEqualToString:campaignSingleView.chosenSize]) {
            //found it
            simpleIndex = i;
        }
    }
    
    [self.sizePicker selectRow:simpleIndex inComponent:0 animated:NO];
    [self.sizePickerBackgroundView addSubview:self.sizePicker];
    [self.sizePickerBackgroundView addSubview:self.sizePickerToolbar];
    [self.view addSubview:self.sizePickerBackgroundView];
}

- (void)finishAddToCart
{
    [self showLoading];
    [RICart addProductWithQuantity:@"1"
                               sku:self.backupCampaign.sku
                            simple:self.backupSimpleSku
                  withSuccessBlock:^(RICart *cart) {
                      
                      NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                      [trackingDictionary setValue:self.backupCampaign.sku forKey:kRIEventLabelKey];
                      [trackingDictionary setValue:@"AddToCart" forKey:kRIEventActionKey];
                      [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                      [trackingDictionary setValue:self.backupCampaign.price forKey:kRIEventValueKey];
                      [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                      [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                      [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                      NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                      [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                      [trackingDictionary setValue:[self.backupCampaign.price stringValue] forKey:kRIEventPriceKey];
                      [trackingDictionary setValue:self.backupCampaign.sku forKey:kRIEventSkuKey];
                      [trackingDictionary setValue:[RICountryConfiguration getCurrentConfiguration].currencyIso forKey:kRIEventCurrencyCodeKey];
                      
                      [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAddToCart]
                                                                data:[trackingDictionary copy]];
                      
                      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cart forKey:kUpdateCartNotificationValue];
                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                      
                      [self showMessage:STRING_ITEM_WAS_ADDED_TO_CART success:YES];
                      [self hideLoading];
                      
                  } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *error) {
                      NSString *addToCartError = STRING_ERROR_ADDING_TO_CART;
                      if(RIApiResponseNoInternetConnection == apiResponse)
                      {
                          addToCartError = STRING_NO_NEWTORK;
                      }
                      
                      [self showMessage:addToCartError success:NO];
                      [self hideLoading];
                  }];
}

- (void)selectSize:(UIButton*)button
{
    NSInteger selectedIndex = [self.sizePicker selectedRowInComponent:0];
    
    RICampaignProductSimple* selectedSimple = [self.lastPressedCampaignSingleView.campaign.productSimples objectAtIndex:selectedIndex];
    self.lastPressedCampaignSingleView.chosenSize = selectedSimple.size;
    
    [self removePickerView];
}

- (void)removePickerView
{
    [self.sizePicker removeFromSuperview];
    self.sizePicker = nil;
    
    [self.sizePickerBackgroundView removeFromSuperview];
    self.sizePickerBackgroundView = nil;
}

#pragma mark - UIPickerView
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.lastPressedCampaignSingleView.campaign.productSimples.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    RICampaignProductSimple* productSimple = [self.lastPressedCampaignSingleView.campaign.productSimples objectAtIndex:row];
    return productSimple.size;
}

#pragma mark - UIScrollViewDelegate

//this depends on animation existing. if in the future there is a case where no animation
//happens on the scroll view, we have to move this to another scrollviewdelegate method
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.shouldPushPDV = YES;
}

@end
