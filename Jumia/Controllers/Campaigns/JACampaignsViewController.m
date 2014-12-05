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
#import "RITeaserImage.h"
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
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) NSMutableArray *pickerDataSource;

// for the retry connection, is necessary to store this stuff
@property (nonatomic, strong)RICampaign* backupCampaign;
@property (nonatomic, strong)NSString* backupSimpleSku;

@property (nonatomic, strong)JACampaignSingleView* lastPressedCampaignSingleView;

@property (nonatomic, assign)BOOL shouldPerformButtonActions;

@property (nonatomic, assign)BOOL pickerNamesAlreadySet;

@property (nonatomic, assign)NSInteger campaignIndex;

@end

@implementation JACampaignsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.campaignIndex = -1;
    
    self.navBarLayout.title = STRING_CAMPAIGNS;
    self.navBarLayout.backButtonTitle = STRING_HOME;
    
    self.pickerNamesAlreadySet = NO;
    
    self.pickerScrollView = [[JAPickerScrollView alloc] initWithFrame:CGRectMake(self.view.bounds.origin.x,
                                                                                 self.view.bounds.origin.y,
                                                                                 self.view.bounds.size.width,
                                                                                 44.0f)];
    self.pickerScrollView.delegate = self;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.delegate = self;
    
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
    
    self.shouldPerformButtonActions = YES;
    
    [self loadCampaignPages];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventViewCampaign] data:trackingDictionary];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupCampaings:self.view.frame.size.width height:self.view.frame.size.height interfaceOrientation:self.interfaceOrientation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                        object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    [self.pickerScrollView setHidden:YES];
    [self.scrollView setHidden:YES];
    
    [self setupCampaings:self.view.frame.origin.y + self.view.frame.size.height height:self.view.frame.size.width interfaceOrientation:toInterfaceOrientation];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupCampaings:self.view.frame.size.width height:self.view.frame.size.height interfaceOrientation:self.interfaceOrientation];
    
    [self.pickerScrollView setHidden:NO];
    [self.scrollView setHidden:NO];
    
    [self hideLoading];    
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)setupCampaings:(CGFloat)width height:(CGFloat)height interfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(VALID_NOTEMPTY(self.campaignPages, NSMutableArray) && 1 < [self.campaignPages count] && -1 < self.campaignIndex)
    {
        self.pickerScrollView.startingIndex = self.campaignIndex;
    }
    
    [self.pickerScrollView setFrame:CGRectMake(self.view.bounds.origin.x,
                                               self.view.bounds.origin.y,
                                               width,
                                               self.pickerScrollView.frame.size.height)];
    
    [self.scrollView setFrame:CGRectMake(self.view.bounds.origin.x,
                                         CGRectGetMaxY(self.pickerScrollView.frame),
                                         width,
                                         height - self.pickerScrollView.frame.size.height)];
    
    if(VALID_NOTEMPTY(self.campaignPages, NSMutableArray))
    {
        CGFloat currentX = 0.0f;
        
        for(JACampaignPageView *campaignPage in self.campaignPages)
        {
            [campaignPage setFrame:CGRectMake(currentX,
                                              self.scrollView.bounds.origin.y,
                                              self.scrollView.bounds.size.width,
                                              self.scrollView.bounds.size.height)];
            [campaignPage reloadViewToInterfaceOrientation:interfaceOrientation];
            currentX += campaignPage.frame.size.width;
        }
        
        [self.scrollView setContentSize:CGSizeMake(currentX, self.scrollView.frame.size.height)];
    }
}

- (void)loadCampaignPages
{
    [self.pickerScrollView setFrame:CGRectMake(self.view.bounds.origin.x,
                                               self.view.bounds.origin.y,
                                               self.view.bounds.size.width,
                                               self.pickerScrollView.frame.size.height)];
    
    [self.scrollView setFrame:CGRectMake(self.view.bounds.origin.x,
                                         CGRectGetMaxY(self.pickerScrollView.frame),
                                         self.view.bounds.size.width,
                                         self.view.bounds.size.height - self.pickerScrollView.frame.size.height)];
    
    [self.view addSubview:self.pickerScrollView];
    [self.view addSubview:self.scrollView];
    
    CGFloat currentX = 0.0f;
    
    NSInteger startingIndex = 0;
    self.campaignPages = [NSMutableArray new];
    NSMutableArray* optionList = [NSMutableArray new];
    
    if(VALID_NOTEMPTY(self.campaignId, NSString))
    {
        [optionList addObject:@""];
        JACampaignPageView* campaignPage = [[JACampaignPageView alloc] initWithFrame:CGRectMake(currentX,
                                                                                                self.scrollView.bounds.origin.y,
                                                                                                self.scrollView.bounds.size.width,
                                                                                                self.scrollView.bounds.size.height)];
        campaignPage.interfaceOrientation = self.interfaceOrientation;
        campaignPage.singleViewDelegate = self;
        campaignPage.delegate = self;
        [self.campaignPages addObject:campaignPage];
        [self.scrollView addSubview:campaignPage];
        [self showLoading];
        [campaignPage loadWithCampaignId:self.campaignId];
        currentX += campaignPage.frame.size.width;
    }
    else if (VALID_NOTEMPTY(self.campaignTeasers, NSArray))
    {
        for (int i = 0; i < self.campaignTeasers.count; i++)
        {
            RITeaser* teaser = [self.campaignTeasers objectAtIndex:i];
            if (VALID_NOTEMPTY(teaser.teaserTexts, NSOrderedSet)) {
                RITeaserText* teaserText = [teaser.teaserTexts firstObject];
                if (VALID_NOTEMPTY(teaserText, RITeaserText))
                {
                    
                    [optionList addObject:teaserText.name];
                    
                    if ([teaserText.name isEqualToString:self.startingTitle])
                    {
                        startingIndex = i;
                    }
                    
                    JACampaignPageView* campaignPage = [[JACampaignPageView alloc] initWithFrame:CGRectMake(currentX,
                                                                                                            self.scrollView.bounds.origin.y,
                                                                                                            self.scrollView.bounds.size.width,
                                                                                                            self.scrollView.bounds.size.height)];
                    campaignPage.interfaceOrientation = self.interfaceOrientation;
                    campaignPage.singleViewDelegate = self;
                    campaignPage.delegate = self;
                    [self.campaignPages addObject:campaignPage];
                    [self.scrollView addSubview:campaignPage];
                    [self showLoading];
                    [campaignPage loadWithCampaignUrl:teaserText.url];
                    currentX += campaignPage.frame.size.width;
                }
            }
            else if (VALID_NOTEMPTY(teaser.teaserImages, NSOrderedSet))
            {
                RITeaserImage* teaserImage = [teaser.teaserImages firstObject];
                if (VALID_NOTEMPTY(teaserImage, RITeaserImage))
                {
                    [optionList addObject:teaserImage.teaserDescription];
                    
                    if ([teaserImage.teaserDescription isEqualToString:self.startingTitle])
                    {
                        startingIndex = i;
                    }
                    
                    JACampaignPageView* campaignPage = [[JACampaignPageView alloc] initWithFrame:CGRectMake(currentX,
                                                                                                            self.scrollView.bounds.origin.y,
                                                                                                            self.scrollView.bounds.size.width,
                                                                                                            self.scrollView.bounds.size.height)];
                    campaignPage.interfaceOrientation = self.interfaceOrientation;
                    campaignPage.singleViewDelegate = self;
                    campaignPage.delegate = self;
                    [self.campaignPages addObject:campaignPage];
                    [self.scrollView addSubview:campaignPage];
                    [self showLoading];
                    [campaignPage loadWithCampaignUrl:teaserImage.url];
                    currentX += campaignPage.frame.size.width;
                }
            }
        }
        //this will trigger load methods
        [self.pickerScrollView setOptions:optionList];
        self.pickerNamesAlreadySet = YES;
        self.pickerScrollView.startingIndex = startingIndex;
    }
    
    [self setupCampaings:self.view.frame.size.width height:self.view.frame.size.height interfaceOrientation:self.interfaceOrientation];
}

#pragma mark - JAPickerScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{
    self.campaignIndex = index;
    JACampaignPageView* campaignPageView = [self.campaignPages objectAtIndex:index];
    [self.scrollView scrollRectToVisible:campaignPageView.frame animated:YES];
}

- (IBAction)swipeLeft:(id)sender
{
    self.shouldPerformButtonActions = NO;
    [self.pickerScrollView scrollLeftAnimated:YES];
}

- (IBAction)swipeRight:(id)sender
{
    self.shouldPerformButtonActions = NO;
    [self.pickerScrollView scrollRightAnimated:YES];
}

#pragma mark - JACampaignPageViewDelegate
- (void)loadSuccessWithName:(NSString*)name
{
    if (NO == self.pickerNamesAlreadySet) {
        NSArray *optionList = [NSArray arrayWithObject:name];
        //this will trigger load methods
        [self.pickerScrollView setOptions:optionList];
    }
    [self hideLoading];
}

- (void)loadFailedWithResponse:(RIApiResponse)apiResponse
{
    BOOL noConnection = NO;
    if(RIApiResponseMaintenancePage == apiResponse)
    {
        [self showMaintenancePage:@selector(loadCampaignPages) objects:nil];
    }
    else
    {
        if (RIApiResponseNoInternetConnection == apiResponse)
        {
            noConnection = YES;
        }
        [self showErrorView:noConnection startingY:0.0f selector:@selector(loadCampaignPages) objects:nil];
    }
    [self hideLoading];
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
    //the flag shouldPerformButtonActions is used to fix the scrolling, if the campaignPages.count is 1, then it is not needed
    if (self.shouldPerformButtonActions || 1 == self.campaignPages.count) {
        self.backupCampaign = campaign;
        self.backupSimpleSku = simpleSku;
        
        [self finishAddToCart];
    }
}

- (void)pressedCampaignWithSku:(NSString*)sku;
{
    //the flag shouldPerformButtonActions is used to fix the scrolling, if the campaignPages.count is 1, then it is not needed
    if (self.shouldPerformButtonActions || 1 == self.campaignPages.count) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                            object:nil
                                                          userInfo:@{ @"sku" : sku ,
                                                                      @"previousCategory" : STRING_CAMPAIGNS,
                                                                      @"show_back_button" : [NSNumber numberWithBool:YES]}];
    }
}

- (void)sizePressedOnView:(JACampaignSingleView*)campaignSingleView;
{
    self.lastPressedCampaignSingleView = campaignSingleView;
    
    if(VALID(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.picker setDelegate:self];
    self.pickerDataSource = [NSMutableArray new];
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    NSString *simpleSize = @"";
    if(VALID_NOTEMPTY(campaignSingleView.campaign.productSimples, NSArray))
    {
        for (int i = 0; i < campaignSingleView.campaign.productSimples.count; i++)
        {
            RICampaignProductSimple* simple = [campaignSingleView.campaign.productSimples objectAtIndex:i];
            if(VALID_NOTEMPTY(simple.size, NSString))
            {
                [dataSource addObject:simple.size];
                if ([simple.size isEqualToString:campaignSingleView.chosenSize])
                {
                    //found it
                    simpleSize = simple.size;
                }
            }
        }
    }
    
    [self.picker setDataSourceArray:[dataSource copy]
                       previousText:simpleSize];
    
    CGFloat pickerViewHeight = self.view.frame.size.height;
    CGFloat pickerViewWidth = self.view.frame.size.width;
    [self.picker setFrame:CGRectMake(0.0f,
                                     pickerViewHeight,
                                     pickerViewWidth,
                                     pickerViewHeight)];
    [self.view addSubview:self.picker];
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         [self.picker setFrame:CGRectMake(0.0f,
                                                          0.0f,
                                                          pickerViewWidth,
                                                          pickerViewHeight)];
                     }];
}

- (void)finishAddToCart
{
    [self showLoading];
    [RICart addProductWithQuantity:@"1"
                               sku:self.backupCampaign.sku
                            simple:self.backupSimpleSku
                  withSuccessBlock:^(RICart *cart) {
                      
                      NSNumber *price = self.backupCampaign.priceEuroConverted;
                      if(VALID_NOTEMPTY(self.backupCampaign.specialPriceEuroConverted, NSNumber) && [self.backupCampaign.specialPriceEuroConverted floatValue] > 0.0f)
                      {
                          price = self.backupCampaign.specialPriceEuroConverted;
                      }
                      
                      NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                      [trackingDictionary setValue:self.backupCampaign.sku forKey:kRIEventLabelKey];
                      [trackingDictionary setValue:@"AddToCart" forKey:kRIEventActionKey];
                      [trackingDictionary setValue:@"Catalog" forKey:kRIEventCategoryKey];
                      [trackingDictionary setValue:price forKey:kRIEventValueKey];
                      
                      NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                      
                      [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                      [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                      [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                      [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                      
                      // Since we're sending the converted price, we have to send the currency as EUR.
                      // Otherwise we would have to send the country currency ([RICountryConfiguration getCurrentConfiguration].currencyIso)
                      [trackingDictionary setValue:price forKey:kRIEventPriceKey];
                      [trackingDictionary setValue:@"EUR" forKey:kRIEventCurrencyCodeKey];
                      
                      [trackingDictionary setValue:@"Campaings" forKey:kRIEventLocationKey];
                      [trackingDictionary setValue:self.backupCampaign.sku forKey:kRIEventSkuKey];
                      [trackingDictionary setValue:self.backupCampaign.brand forKey:kRIEventBrandKey];
                      [trackingDictionary setValue:self.backupCampaign.name forKey:kRIEventProductNameKey];
                      
                      NSString *discountPercentage = @"0";
                      if(VALID_NOTEMPTY(self.backupCampaign.maxSavingPercentage, NSNumber))
                      {
                          discountPercentage = [self.backupCampaign.maxSavingPercentage stringValue];
                      }
                      [trackingDictionary setValue:discountPercentage forKey:kRIEventDiscountKey];
                      [trackingDictionary setValue:@"1" forKey:kRIEventQuantityKey];
                      
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

#pragma mark - UIScrollViewDelegate

//this depends on animation existing. if in the future there is a case where no animation
//happens on the scroll view, we have to move this to another scrollviewdelegate method
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.shouldPerformButtonActions = YES;
}

#pragma mark JAPickerDelegate
- (void)selectedRow:(NSInteger)selectedRow
{
    RICampaignProductSimple* selectedSimple = [self.lastPressedCampaignSingleView.campaign.productSimples objectAtIndex:selectedRow];
    if(VALID_NOTEMPTY(selectedSimple.size, NSString))
    {
        self.lastPressedCampaignSingleView.chosenSize = selectedSimple.size;
    }
    
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         self.picker = nil;
                     }];
}

- (void)closePicker
{
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         self.picker = nil;
                     }];
}

@end