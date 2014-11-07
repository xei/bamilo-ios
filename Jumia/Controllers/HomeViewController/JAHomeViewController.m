//
//  JAHomeViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAHomeViewController.h"
#import "RITeaserCategory.h"
#import "JATeaserPageView.h"
#import "JATeaserView.h"
#import "JAUtils.h"
#import "RICustomer.h"
#import "JAPromotionPopUp.h"
#import "JAAppDelegate.h"
#import "JAHomeWizardView.h"
#import "JAFallbackView.h"

@interface JAHomeViewController ()

@property (nonatomic, strong) NSArray* teaserCategories;
@property (weak, nonatomic) IBOutlet JAPickerScrollView *teaserCategoryScrollView;
@property (strong, nonatomic) UIScrollView *teaserPagesScrollView;
@property (nonatomic, strong) NSMutableArray* teaserPageViews;

@property (nonatomic, assign)CGRect teaserPageScrollPortraitRect;
@property (nonatomic, assign)CGRect teaserPageScrollLandscapeRect;

@end

@implementation JAHomeViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"ShopMain";
    self.A4SViewControllerAlias = @"HOME";
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary valueForKey:@"CFBundleVersion"];
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    NSNumber *numberOfSessions = [[NSUserDefaults standardUserDefaults] objectForKey:kNumberOfSessions];
    if(VALID_NOTEMPTY(numberOfSessions, NSNumber))
    {
        [trackingDictionary setValue:[numberOfSessions stringValue] forKey:kRIEventAmountSessions];
    }
    
    [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:appVersion forKey:kRILaunchEventAppVersionDataKey];
    [trackingDictionary setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
    [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookHome]
                                              data:[trackingDictionary copy]];
    
    self.teaserCategoryScrollView.delegate = self;
    self.teaserCategoryScrollView.startingIndex = 0;
    
    CGRect rectToStart;
    if (UIInterfaceOrientationLandscapeRight == self.interfaceOrientation || UIInterfaceOrientationLandscapeLeft == self.interfaceOrientation) {
        self.teaserPageScrollLandscapeRect = CGRectMake(self.view.bounds.origin.x,
                                                        CGRectGetMaxY(self.teaserCategoryScrollView.frame),
                                                        self.view.bounds.size.width,
                                                        self.view.bounds.size.height - self.teaserCategoryScrollView.frame.size.height - 64.0f);
        self.teaserPageScrollPortraitRect = CGRectMake(self.teaserPageScrollLandscapeRect.origin.x,
                                                       self.teaserPageScrollLandscapeRect.origin.y,
                                                       self.view.bounds.size.height,
                                                       self.view.bounds.size.width - self.teaserCategoryScrollView.frame.size.height - 64.0f);
        rectToStart = self.teaserPageScrollLandscapeRect;
    } else {
        self.teaserPageScrollPortraitRect = CGRectMake(self.view.bounds.origin.x,
                                                       CGRectGetMaxY(self.teaserCategoryScrollView.frame),
                                                       self.view.bounds.size.width,
                                                       self.view.bounds.size.height - self.teaserCategoryScrollView.frame.size.height - 64.0f);
        self.teaserPageScrollLandscapeRect = CGRectMake(self.teaserPageScrollPortraitRect.origin.x,
                                                        self.teaserPageScrollPortraitRect.origin.y,
                                                        self.view.bounds.size.height,
                                                        self.view.bounds.size.width - self.teaserCategoryScrollView.frame.size.height - 64.0f);

        rectToStart = self.teaserPageScrollPortraitRect;
    }
    self.teaserPagesScrollView = [[UIScrollView alloc] initWithFrame:rectToStart];
    self.teaserPagesScrollView.pagingEnabled = YES;
    self.teaserPagesScrollView.scrollEnabled = NO;
    self.teaserPagesScrollView.delegate = self;
    [self.view addSubview:self.teaserPagesScrollView];
    
    [self completeTeasersLoading];
}

- (void)stopLoading
{
    [self hideLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addNotifications];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                        object:nil];
    
    BOOL alreadyShowedWizardHome = [[NSUserDefaults standardUserDefaults] boolForKey:kJAHomeWizardUserDefaultsKey];
    if(alreadyShowedWizardHome == NO)
    {
        JAHomeWizardView* wizardView = [[JAHomeWizardView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:wizardView];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJAHomeWizardUserDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:NSTimeIntervalSince1970];
        [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self removeNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

- (void)addNotifications
{
    //we do this to make sure no notification is added more than once
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushCatalogWithUrl:)
                                                 name:kTeaserNotificationPushCatalogWithUrl
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushPDVWithUrl:)
                                                 name:kTeaserNotificationPushPDVWithUrl
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushAllCategories)
                                                 name:kTeaserNotificationPushAllCategories
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushCampaigns:)
                                                 name:kTeaserNotificationPushCatalogWithUrlForCampaigns
                                               object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self showLoading];
    if (UIInterfaceOrientationLandscapeLeft == toInterfaceOrientation || UIInterfaceOrientationLandscapeRight == toInterfaceOrientation) {
        self.teaserPagesScrollView.frame = self.teaserPageScrollLandscapeRect;
    } else {
        self.teaserPagesScrollView.frame = self.teaserPageScrollPortraitRect;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self hideLoading];
    CGFloat currentPageX = 0.0f;
    CGFloat currentPageY = 0.0f;
    for (JATeaserPageView* teaserPageView in self.teaserPageViews) {
        [teaserPageView loadTeasersForFrame:CGRectMake(currentPageX,
                                                       currentPageY,
                                                       self.teaserPagesScrollView.bounds.size.width,
                                                       self.teaserPagesScrollView.bounds.size.height)];
        [self.teaserPagesScrollView addSubview:teaserPageView];
        
        currentPageX += teaserPageView.frame.size.width;
    }
    [self.teaserPagesScrollView setContentSize:CGSizeMake(currentPageX,
                                                          self.teaserPagesScrollView.frame.size.height)];
    [self selectedIndex:0];
}

- (void)completeTeasersLoading
{
    [RITeaserCategory getTeaserCategoriesWithSuccessBlock:^(id teaserCategories) {
        
        self.teaserCategories = teaserCategories;
        
        NSMutableArray* titles = [NSMutableArray new];
        self.teaserPageViews = [NSMutableArray new];
        
        CGFloat currentPageX = self.teaserPagesScrollView.bounds.origin.x;
        
        for (RITeaserCategory* teaserCategory in teaserCategories) {
            if(VALID_NOTEMPTY(teaserCategory.homePageTitle, NSString))
            {
                [titles addObject:teaserCategory.homePageTitle];
                
                JATeaserPageView* teaserPageView = [[JATeaserPageView alloc] init];
                teaserPageView.teaserCategory = teaserCategory;
                NSLog(@"%@", NSStringFromCGRect(self.teaserPagesScrollView.frame));
                [teaserPageView loadTeasersForFrame:CGRectMake(currentPageX,
                                                               self.teaserPagesScrollView.bounds.origin.y,
                                                               self.teaserPagesScrollView.bounds.size.width,
                                                               self.teaserPagesScrollView.bounds.size.height)];
                [self.teaserPagesScrollView addSubview:teaserPageView];
                [self.teaserPageViews addObject:teaserPageView];
                
                currentPageX += teaserPageView.frame.size.width;
            }
        }
        
        [self.teaserCategoryScrollView setOptions:titles];
        
        [self.teaserPagesScrollView setContentSize:CGSizeMake(currentPageX,
                                                              self.teaserPagesScrollView.frame.size.height)];
        
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }

        // notify the InAppNotification SDK that this the active view controller
        [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
        
        [RIPromotion getPromotionWithSuccessBlock:^(RIPromotion *promotion) {
            [self loadPromotion:promotion];
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *error) {
            
        }];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
        if(RIApiResponseMaintenancePage == apiResponse)
        {
            [self showMaintenancePage:@selector(completeTeasersLoading) objects:nil];
        }
        else
        {
            if (RIApiResponseNoInternetConnection == apiResponse)
            {
                [self showErrorView:YES startingY:0.0f selector:@selector(completeTeasersLoading) objects:nil];
            } else {
                JAFallbackView* fallbackView = [JAFallbackView getNewJAFallbackView];
                [fallbackView setupFallbackView:self.view.bounds];
                [self.view addSubview:fallbackView];
            }
        }
    }];
}

- (void)loadPromotion:(RIPromotion*)promotion
{
    JAPromotionPopUp* promotionPopUp = [[JAPromotionPopUp alloc] initWithFrame:self.view.bounds];
    [promotionPopUp loadWithPromotion:promotion];
    [self.view addSubview:promotionPopUp];
}

#pragma mark - JATeaserCategoryScrollViewDelegate

- (void)selectedIndex:(NSInteger)index
{
    //check if teaser page at said index is loaded
    
    JATeaserPageView* teaserPageView = [self.teaserPageViews objectAtIndex:index];
        
    [self.teaserPagesScrollView scrollRectToVisible:teaserPageView.frame animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)swipeRight:(id)sender
{
    [self removeNotifications];
    [self.teaserCategoryScrollView scrollRight];
}

- (IBAction)swipeLeft:(id)sender
{
    [self removeNotifications];
    [self.teaserCategoryScrollView scrollLeftAnimated:YES];
}

#pragma mark - UIScrollViewDelegate

//this depends on animation existing. if in the future there is a case where no animation
//happens on the scroll view, we have to move this to another scrollviewdelegate method
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self addNotifications];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

#pragma mark - Teaser actions

- (void)pushCatalogWithUrl:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithCatalogUrlNofication
                                                        object:notification.object
                                                      userInfo:notification.userInfo];
}

- (void)pushPDVWithUrl:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithPDVUrlNofication
                                                        object:notification.object
                                                      userInfo:notification.userInfo];
}

- (void)pushCampaigns:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectCampaignNofication
                                                        object:notification.object
                                                      userInfo:notification.userInfo];
}

- (void)pushAllCategories
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidSelectTeaserWithAllCategoriesNofication
                                                        object:nil
                                                      userInfo:nil];
}

@end
