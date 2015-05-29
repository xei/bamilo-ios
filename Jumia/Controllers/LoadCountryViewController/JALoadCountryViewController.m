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
#import "RIGTMTracker.h"

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
    
    // Do any additional setup after loading the view.
    self.screenName = @"SplashScreen";
    
    
    self.coverView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.coverView.backgroundColor = [UIColor blackColor];
    self.coverView.alpha = 0.2;
    [self.view addSubview:self.coverView];
    
    UIImage* image = [UIImage imageNamed:@"loadingAnimationFrame1"];
    
    int lastFrame = 24;
    if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"] || [[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
    {
        lastFrame = 6;
    }else if([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"])
    {
        lastFrame = 8;
    }
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
        if(VALID_NOTEMPTY(self.pushNotification, NSDictionary))
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                                object:nil];
            
            if (VALID_NOTEMPTY([self.pushNotification objectForKey:@"u"], NSString))
            {
                NSString *urlString = [self.pushNotification objectForKey:@"u"];
                
                // Check if the country is the same
                NSString *currentCountry = [RIApi getCountryIsoInUse];
                NSString *countryFromUrl = [[urlString substringWithRange:NSMakeRange(0, 2)] uppercaseString];
                if([currentCountry isEqualToString:countryFromUrl])
                {
                    [self continueProcessing];
                }
                else
                {
                    RICountry* country = [RICountry getUniqueCountry];
                    if (VALID_NOTEMPTY(country, RICountry)) {
                        self.selectedCountry = country;
                        [self continueProcessing];
                    } else {
                        // Change country
                        self.countriesRequestId = [RICountry getCountriesWithSuccessBlock:^(id countries)
                                                   {
                                                       for (RICountry *country in countries)
                                                       {
                                                           if ([[country.countryIso uppercaseString] isEqualToString:[countryFromUrl uppercaseString]])
                                                           {
                                                               self.selectedCountry = country;
                                                               
                                                               [self continueProcessing];
                                                           }
                                                       }
                                                       
                                                   } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages)
                                                   {
                                                       [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
                                                   }];
                    }
                }
            }
            else
            {
                if(VALID_NOTEMPTY(self.pushNotification, NSDictionary) && VALID_NOTEMPTY([self.pushNotification objectForKey:@"UTM"], NSString))
                {
                    [[RITrackingWrapper sharedInstance] trackCampaignWithName:[self.pushNotification objectForKey:@"UTM"]];
                }
            }
        }
        else
        {
            [self continueProcessing];
        }
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.coverView setFrame:self.view.bounds];
    self.loadingBaseAnimation.center = CGPointMake(self.view.center.x, self.view.center.y - 64.0f);
}

- (void)continueProcessing
{
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
//        [self showLoading];
    }
    
    self.isRequestDone = NO;
    
    self.requestCount = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementRequestCount) name:RISectionRequestStartedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decrementRequestCount) name:RISectionRequestEndedNotificationName object:nil];
    
    if(VALID_NOTEMPTY(self.selectedCountry, RICountry))
    {
        [RICommunicationWrapper deleteSessionCookie];
    }
    self.apiRequestId = [RIApi startApiWithCountry:self.selectedCountry
                                      successBlock:^(RIApi *api, BOOL hasUpdate, BOOL isUpdateMandatory)
                         {
                             if(hasUpdate)
                             {
                                 self.isPopupOpened = YES;
                                 self.isRequestDone = YES;
                                 if(isUpdateMandatory)
                                 {
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_UPDATE_NECESSARY_TITLE message:[NSString stringWithFormat:STRING_UPDATE_NECESSARY_MESSAGE, APP_NAME] delegate:self cancelButtonTitle:STRING_OK_UPDATE otherButtonTitles:nil];
                                     [alert setTag:kForceUpdateAlertViewTag];
                                     [alert show];
//                                     [self hideLoading];
                                 }
                                 else
                                 {
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_UPDATE_AVAILABLE_TITLE message:[NSString stringWithFormat:STRING_UPDATE_AVAILABLE_MESSAGE, APP_NAME] delegate:self cancelButtonTitle:STRING_NO_THANKS otherButtonTitles:STRING_UPDATE, nil];
                                     [alert setTag:kUpdateAvailableAlertViewTag];
                                     [alert show];
                                     
//                                     [self hideLoading];
                                 }
                             }
                             else
                             {
                                 if (0 >= self.requestCount)
                                 {
                                     [self getConfigurations];
                                 }
                             }
                             [self removeErrorView];
                             //show loading has to be added here, in case the no connection error view was shown
                             // and the loading was removed because of that
//                             [self showLoading];
                         }
                                   andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage)
                         {
                             [self removeErrorView];
                             self.apiResponse = apiResponse;
                             self.isRequestDone=YES;
                             if(RIApiResponseMaintenancePage == apiResponse)
                             {
                                 [self showMaintenancePage:@selector(continueProcessing) objects:nil];
                             }
                             else if(RIApiResponseKickoutView == apiResponse)
                             {
                                 [self showKickoutView:@selector(continueProcessing) objects:nil];
                             }
                             else
                             {
                                 BOOL noInternet = NO;
                                 if(RIApiResponseNoInternetConnection == apiResponse)
                                 {
                                     noInternet = YES;
                                 }
                                 
                                 [self showErrorView:noInternet startingY:0.0f selector:@selector(continueProcessing) objects:nil];
                             }
//                             [self hideLoading];
                         }];
}

- (void)incrementRequestCount
{
    self.requestCount++;
}

- (void)decrementRequestCount
{
    self.requestCount--;
    
    if (0 >= self.requestCount)
    {
        [self getConfigurations];
    }
}

- (void)getConfigurations
{
    if(!self.isPopupOpened)
    {
        self.configurationRequestCount = 1;
        
        if([RICommunicationWrapper setSessionCookie])
        {
            self.configurationRequestCount = 2;
            
            self.cartRequestId = [RICart getCartWithSuccessBlock:^(RICart *cartData)
                                  {
                                      NSDictionary* userInfo = [NSDictionary dictionaryWithObject:cartData forKey:kUpdateCartNotificationValue];
                                      [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:userInfo];
                                      
                                      self.configurationRequestCount--;
                                      
                                  } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages)
                                  {
                                      self.configurationRequestCount--;
                                  }];
        }
        
        self.customerRequestId = [RICustomer autoLogin:^(BOOL success, RICustomer *customer, NSString *loginMethod)
                                  {
                                      self.customer = customer;
                                      self.loginMethod = loginMethod;
                                      [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration)
                                       {
                                           [RIGoogleAnalyticsTracker initGATrackerWithId:configuration.gaId];
                                           
                                           [RIGTMTracker initWithGTMTrackerId:configuration.gtmId];
                                            
                                           self.configurationRequestCount--;
                                       } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessages)
                                       {
                                           self.configurationRequestCount--;
                                       }];
                                  }];
    }
}

- (void)initCountry
{
    self.isRequestDone = YES;
    
    if(VALID_NOTEMPTY(self.loginMethod, NSString) && [@"signup" isEqualToString:self.loginMethod])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo:nil];
        [RICommunicationWrapper deleteSessionCookie];
    }
    
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
    
    NSNumber *event = [NSNumber numberWithInt:RIEventAutoLoginFail];
    [trackingDictionary setValue:@"AutoLoginFailed" forKey:kRIEventActionKey];
    if(VALID_NOTEMPTY(self.customer, RICustomer))
    {
        event = [NSNumber numberWithInt:RIEventAutoLoginSuccess];
        [trackingDictionary setValue:@"AutoLoginSuccess" forKey:kRIEventActionKey];
        
        if(VALID_NOTEMPTY(self.customer, RICustomer))
        {
            [trackingDictionary setValue:self.customer.idCustomer forKey:kRIEventLabelKey];
            [trackingDictionary setValue:self.customer.idCustomer forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:self.customer.gender forKey:kRIEventGenderKey];
            [trackingDictionary setValue:self.customer.createdAt forKey:kRIEventAccountDateKey];
            
            NSDate* now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *dateOfBirth = [dateFormatter dateFromString:self.customer.birthday];
            NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:dateOfBirth toDate:now options:0];
            [trackingDictionary setValue:[NSNumber numberWithInteger:[ageComponents year]] forKey:kRIEventAgeKey];
        }
    }
    
    CGFloat duration = fabs([self.startLoadingTime timeIntervalSinceNow] * 1000);
    
    NSMutableDictionary *launchData = [[NSMutableDictionary alloc] init];
    [launchData setValue:[NSString stringWithFormat:@"%f", duration] forKey:kRILaunchEventDurationDataKey];
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    [launchData setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
    
    [launchData setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
    [launchData setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
    [launchData setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    [launchData setValue:[RICustomer getCustomerGender] forKey:kRIEventGenderKey];
    
    NSString *source = @"Organic";
    if(VALID_NOTEMPTY(self.pushNotification, NSDictionary))
    {
        source = @"Push";
        if(VALID_NOTEMPTY([self.pushNotification objectForKey:@"UTM"], NSString))
        {
            [launchData setObject:[self.pushNotification objectForKey:@"UTM"] forKey:kRILaunchEventCampaignKey];
        }
    }

    [launchData setValue:source forKey:kRILaunchEventSourceKey];
    [[RITrackingWrapper sharedInstance] sendLaunchEventWithData:[launchData copy]];
    
    [[RITrackingWrapper sharedInstance] trackEvent:event
                                              data:[trackingDictionary copy]];
    
    trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventChangeCountry]
                                              data:[trackingDictionary copy]];
    
//    [self hideLoading];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCountryNotification object:nil userInfo:self.pushNotification];
}

#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    self.isPopupOpened = NO;
    if(kUpdateAvailableAlertViewTag == [alertView tag])
    {
        if(0 == buttonIndex)
        {
            if (0 >= self.requestCount) {
                [self getConfigurations];
            }
        }
        else if(1 == buttonIndex)
        {
            if (0 >= self.requestCount) {
                [self getConfigurations];
            }
            
            NSURL  *url;
            if([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"])
            {
                url = [NSURL URLWithString:kAppStoreUrl];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"])
            {
                url = [NSURL URLWithString:kAppStoreUrlDaraz];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
            {
                url = [NSURL URLWithString:kAppStoreUrlShop];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"])
            {
                url = [NSURL URLWithString:kAppStoreUrlBamilo];
            }
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
    else if(kForceUpdateAlertViewTag == [alertView tag])
    {
        if(0 == buttonIndex)
        {
            NSURL  *url;
            if([[APP_NAME uppercaseString] isEqualToString:@"JUMIA"])
            {
                url = [NSURL URLWithString:kAppStoreUrl];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"DARAZ"])
            {
                url = [NSURL URLWithString:kAppStoreUrlDaraz];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"SHOP.COM.MM"])
            {
                url = [NSURL URLWithString:kAppStoreUrlShop];
            }
            else if ([[APP_NAME uppercaseString] isEqualToString:@"بامیلو"])
            {
                url = [NSURL URLWithString:kAppStoreUrlBamilo];
            }
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

@end
