//
//  JAHomeViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 28/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAHomeViewController.h"
#import "RITeaserGrouping.h"
#import "JATeaserPageView.h"
#import "JATeaserView.h"
#import "JAUtils.h"
#import "RICustomer.h"
#import "JAPromotionPopUp.h"
#import "JAAppDelegate.h"
#import "JAHomeWizardView.h"
#import "JAFallbackView.h"

@interface JAHomeViewController ()

@property (nonatomic, strong) NSArray* teaserGroupings;
@property (strong, nonatomic) JATeaserPageView* teaserPageView;

@property (nonatomic, assign) BOOL isLoaded;

@property (nonatomic, strong)JAHomeWizardView *wizardView;
@property (nonatomic, strong)JAFallbackView *fallbackView;

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
    
    self.isLoaded = NO;
    
    self.teaserPageView = [[JATeaserPageView alloc] init];
}

- (void)stopLoading
{
    [self hideLoading];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.teaserPageView setFrame:self.view.bounds];
    
    [self requestTeasers];
    
//    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0.0];
//    [self didRotateFromInterfaceOrientation:self.interfaceOrientation];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kTurnOffLeftSwipePanelNotification
                                                        object:nil];
    
    BOOL alreadyShowedWizardHome = [[NSUserDefaults standardUserDefaults] boolForKey:kJAHomeWizardUserDefaultsKey];
    if(alreadyShowedWizardHome == NO)
    {
        self.wizardView = [[JAHomeWizardView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.wizardView];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kJAHomeWizardUserDefaultsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self hideLoading];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"HomeShop"];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    if(VALID_NOTEMPTY(self.wizardView, JAHomeWizardView))
    {
        CGRect newFrame = CGRectMake(self.wizardView.frame.origin.x,
                                     self.wizardView.frame.origin.y,
                                     self.view.frame.size.height + self.view.frame.origin.y,
                                     self.view.frame.size.width - self.view.frame.origin.y);
        [self.wizardView reloadForFrame:newFrame];
    }
    
    if(VALID_NOTEMPTY(self.fallbackView, JAFallbackView) && VALID_NOTEMPTY(self.fallbackView.superview, UIView))
    {
        [self.fallbackView setupFallbackView:CGRectMake(self.fallbackView.frame.origin.x,
                                                        self.fallbackView.frame.origin.y,
                                                        self.view.frame.size.height + self.view.frame.origin.y,
                                                        self.view.frame.size.width - self.view.frame.origin.y)
                                 orientation:toInterfaceOrientation];
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self hideLoading];
    
    if(VALID_NOTEMPTY(self.wizardView, JAHomeWizardView))
    {
        [self.wizardView reloadForFrame:self.view.bounds];
        [self.view bringSubviewToFront:self.wizardView];
    }
    
    if(VALID_NOTEMPTY(self.fallbackView, JAFallbackView) && VALID_NOTEMPTY(self.fallbackView.superview, UIView))
    {
        [self.fallbackView setupFallbackView:self.view.bounds orientation:self.interfaceOrientation];
    }
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)requestTeasers
{
    if (self.isLoaded) {
        return;
    }
    
    [RITeaserGrouping getTeaserGroupingsWithSuccessBlock:^(NSArray *teaserGroupings) {
        self.isLoaded = YES;
        
        [self removeErrorView];
        
        self.teaserGroupings = teaserGroupings;
        
        //$$$ CALL THIS THE CORRECT WAY
        self.teaserPageView.teaserGroupings = teaserGroupings;
        [self.teaserPageView loadTeasersForFrame:self.view.bounds];
        [self.view addSubview:self.teaserPageView];
        
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
        [self removeErrorView];
        if(self.firstLoading)
        {
            NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
            [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
            self.firstLoading = NO;
        }
        
        if(RIApiResponseMaintenancePage == apiResponse)
        {
            [self showMaintenancePage:@selector(requestTeasers) objects:nil];
        }
        else
        {
            if (RIApiResponseNoInternetConnection == apiResponse)
            {
                [self showErrorView:YES startingY:0.0f selector:@selector(requestTeasers) objects:nil];
            } else {
                self.fallbackView = [JAFallbackView getNewJAFallbackView];
                [self.fallbackView setupFallbackView:self.view.bounds orientation:self.interfaceOrientation];
                [self.view addSubview:self.fallbackView];
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


@end
