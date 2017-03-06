//
//  JALoadCountryViewController.m
//  Jumia
//
//  Created by plopes on 08/10/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JALoadCountryViewController.h"
#import "JAUtils.h"
#import "RIGoogleAnalyticsTracker.h"
#import "RICustomer.h"
#import "RICountry.h"
//#import "RIGTMTracker.h"

@interface JALoadCountryViewController ()

@property (assign, nonatomic) BOOL isPopupOpened;
@property (assign, nonatomic) NSInteger requestCount;
@property (assign, nonatomic) NSInteger configurationRequestCount;
@property (strong, nonatomic) RICustomer *customer;
@property (strong, nonatomic) NSString *loginMethod;
@property (strong, nonatomic) NSString *countriesRequestId;
@property (strong, nonatomic) NSString *apiRequestId;
@property (strong, nonatomic) NSString *cartRequestId;
@property (strong, nonatomic) NSString *customerRequestId;
@property (assign, nonatomic) BOOL isRequestDone;
@property (assign, nonatomic) RIApiResponse apiResponse;

@property (nonatomic, strong)UIImageView* loadingBaseAnimation;
@property (nonatomic, strong)UIView* coverView;

@end

@implementation JALoadCountryViewController

@synthesize configurationRequestCount = _configurationRequestCount;
-(void)setConfigurationRequestCount:(NSInteger)configurationRequestCount
{
    _configurationRequestCount = configurationRequestCount;
    if(0 == configurationRequestCount)
    {
        [self initCountry];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.apiResponse = RIApiResponseSuccess;
    
    self.navBarLayout.showCartButton = NO;
    
    self.coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.coverView.backgroundColor = [UIColor blackColor];
    self.coverView.alpha = 0.2;
    [self.view addSubview:self.coverView];
    
    UIImage* image = [UIImage imageNamed:@"loadingAnimationFrame1"];
    
    int lastFrame = 8;
    self.loadingBaseAnimation = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                              0,
                                                                              image.size.width,
                                                                              image.size.height)];
    self.loadingBaseAnimation.animationDuration = 1.0f;
    NSMutableArray* animationFrames = [NSMutableArray new];
    for (int i = 1; i <= lastFrame; i++) {
        NSString* frameName = [NSString stringWithFormat:@"loadingAnimationFrame%d", i];
        UIImage* frame = [UIImage imageNamed:frameName];
        [animationFrames addObject:frame];
    }
    self.loadingBaseAnimation.animationImages = [animationFrames copy];
    self.loadingBaseAnimation.center = CGPointMake(self.view.center.x, self.view.center.y - 64.0f);
    
    [self.view addSubview:self.loadingBaseAnimation];
    [self.loadingBaseAnimation startAnimating];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.coverView setFrame:self.view.bounds];
    self.loadingBaseAnimation.center = CGPointMake(self.view.center.x, self.view.center.y - 64.0f);
    
    self.isPopupOpened = NO;
    
    if(!self.isRequestDone)
    {
        [self continueProcessing];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RISectionRequestStartedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RISectionRequestEndedNotificationName object:nil];
    
    if(VALID_NOTEMPTY(self.countriesRequestId, NSString))
    {
        [RICountry cancelRequest:self.countriesRequestId];
        self.countriesRequestId = nil;
    }
    
    if(VALID_NOTEMPTY(self.apiRequestId, NSString))
    {
        [RIApi cancelRequest:self.apiRequestId];
        self.apiRequestId = nil;
    }
    
    if(VALID_NOTEMPTY(self.cartRequestId, NSString))
    {
        [RICart cancelRequest:self.cartRequestId];
        self.cartRequestId = nil;
    }
    
    if(VALID_NOTEMPTY(self.customerRequestId, NSString))
    {
        [RICustomer cancelRequest:self.customerRequestId];
        self.customerRequestId = nil;
    }
    
//    [self hideLoading];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.coverView setFrame:self.view.bounds];
    self.loadingBaseAnimation.center = CGPointMake(self.view.center.x, self.view.center.y - 64.0f);
}

- (void)continueProcessing {
    if(self.apiResponse == RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess) {
//        [self showLoading];
    }
    
    self.isRequestDone = NO;
    self.requestCount = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementRequestCount) name:RISectionRequestStartedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decrementRequestCount) name:RISectionRequestEndedNotificationName object:nil];

    self.apiRequestId = [RIApi startApiWithCountry:self.selectedCountry reloadAPI:YES successBlock:^(RIApi *api, BOOL hasUpdate, BOOL isUpdateMandatory) {
        if(hasUpdate) {
            self.isPopupOpened = YES;
            self.isRequestDone = YES;
            if(isUpdateMandatory) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_UPDATE_NECESSARY_TITLE message:[NSString stringWithFormat:STRING_UPDATE_NECESSARY_MESSAGE, APP_NAME] delegate:self cancelButtonTitle:STRING_OK_UPDATE otherButtonTitles:nil];
                [alert setTag:kForceUpdateAlertViewTag];
                [alert show];
                [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                return;
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_UPDATE_AVAILABLE_TITLE message:[NSString stringWithFormat:STRING_UPDATE_AVAILABLE_MESSAGE, APP_NAME] delegate:self cancelButtonTitle:STRING_NO_THANKS otherButtonTitles:STRING_UPDATE, nil];
                [alert setTag:kUpdateAvailableAlertViewTag];
                [alert show];
            }
         } else {
             if (0 >= self.requestCount) {
                 [self getConfigurations];
             }
         }
        
         [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
        self.apiResponse = apiResponse;
        self.isRequestDone = YES;
        [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(continueProcessing) objects:nil];
    }];
}

- (void)incrementRequestCount {
    self.requestCount++;
}

- (void)decrementRequestCount {
    self.requestCount--;
    
    if (0 >= self.requestCount) {
        [self getConfigurations];
    }
}

- (void)getConfigurations {
    if(!self.isPopupOpened) {
        self.configurationRequestCount = 1;
        
        if([RICommunicationWrapper setSessionCookie]) {
            self.configurationRequestCount = 2;
            
            self.cartRequestId = [RICart getCartWithSuccessBlock:^(RICart *cartData) {
                NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cartData forKey:kUpdateCartNotificationValue];
                [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];

                self.configurationRequestCount--;
            } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
                self.configurationRequestCount--;
            }];
        }
        
        self.customerRequestId = [RICustomer autoLogin:^(BOOL success, NSDictionary *entities, NSString *loginMethod)
                                  {
                                      self.customer = [entities objectForKey:@"customer"];
                                      self.loginMethod = loginMethod;
                                      [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration)
                                       {
                                           [RIGoogleAnalyticsTracker initGATrackerWithId:configuration.gaId];
                                           
                                           //[[RIGTMTracker sharedInstance] setGTMTrackerId:configuration.gtmId andGaId:configuration.gaId];
                                            
                                           self.configurationRequestCount--;
                                       } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages)
                                       {
                                           self.configurationRequestCount--;
                                       }];
                                  }];
    }
}

- (void)initCountry {
    self.isRequestDone = YES;
    
    if(self.loginMethod.length && [@"signup" isEqualToString:self.loginMethod]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
        [RICommunicationWrapper deleteSessionCookie];
    }
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
    
    NSNumber *event = [NSNumber numberWithInt:RIEventAutoLoginFail];
    [trackingDictionary setValue:@"AutoLoginFailed" forKey:kRIEventActionKey];
    if(self.customer) {
        event = [NSNumber numberWithInt:RIEventAutoLoginSuccess];
        [trackingDictionary setValue:@"AutoLoginSuccess" forKey:kRIEventActionKey];
        
        if(self.customer) {
            [trackingDictionary setValue:self.customer.customerId forKey:kRIEventLabelKey];
            [trackingDictionary setValue:self.customer.customerId forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:self.customer.firstName forKey:kRIEventUserFirstNameKey];
            [trackingDictionary setValue:self.customer.lastName forKey:kRIEventUserLastNameKey];
            [trackingDictionary setValue:self.customer.gender forKey:kRIEventGenderKey];
            [trackingDictionary setValue:self.customer.birthday forKey:kRIEventBirthDayKey];
            [trackingDictionary setValue:self.customer.createdAt forKey:kRIEventAccountDateKey];
            
            NSNumber *numberOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountTransactions];
            [trackingDictionary setValue:numberOfPurchases forKey:kRIEventAmountTransactions];
            
            NSDate* now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *dateOfBirth = [dateFormatter dateFromString:self.customer.birthday];
            NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:0];
            [trackingDictionary setValue:[NSNumber numberWithInteger:[ageComponents year]] forKey:kRIEventAgeKey];
        }
    }
    
    //CGFloat duration = fabs([self.startLoadingTime timeIntervalSinceNow] * 1000);
    
    NSMutableDictionary *launchData = [[NSMutableDictionary alloc] init];
    //[launchData setValue:[NSString stringWithFormat:@"%f", duration] forKey:kRILaunchEventDurationDataKey];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [launchData setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
    
    [launchData setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    [launchData setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [launchData setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [launchData setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
    
    NSString *source = @"Organic";
    if(self.pushNotification.count) {
        source = @"Push";
        if([[self.pushNotification objectForKey:@"UTM"] length]) {
            [launchData setObject:[self.pushNotification objectForKey:@"UTM"] forKey:kRILaunchEventCampaignKey];
        }
    }

    [launchData setValue:source forKey:kRILaunchEventSourceKey];
    [[RITrackingWrapper sharedInstance] sendLaunchEventWithData:[launchData copy]];
    [[RITrackingWrapper sharedInstance] trackEvent:event data:[trackingDictionary copy]];
    trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    
    NSDictionary *componentsFromLocale =  [NSLocale componentsFromLocaleIdentifier:[RILocalizationWrapper getLocalization]];
    NSString *languageCode = [componentsFromLocale objectForKey:NSLocaleLanguageCode];
    [trackingDictionary setValue:languageCode forKey:kRIEventLanguageCode];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventChangeCountry] data:[trackingDictionary copy]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCountryNotification object:nil userInfo:self.pushNotification];
    
    [self publishScreenLoadTime];
}

#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    self.isPopupOpened = NO;
    if(kUpdateAvailableAlertViewTag == [alertView tag]) {
        if (buttonIndex == 0) {
            if (0 >= self.requestCount) {
                [self getConfigurations];
            }
        } else if(buttonIndex == 1) {
            if (0 >= self.requestCount) {
                [self getConfigurations];
            }
            NSURL  *url = [NSURL URLWithString:kAppStoreUrlBamilo];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    } else if(kForceUpdateAlertViewTag == [alertView tag]) {
        if(buttonIndex == 0) {
            NSURL  *url = [NSURL URLWithString:kAppStoreUrlBamilo];

            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    return @"SplashScreen";
}

@end
