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

@interface JALoadCountryViewController ()

@property (assign, nonatomic) BOOL isPopupOpened;
@property (assign, nonatomic) NSInteger requestCount;
@property (assign, nonatomic) NSInteger configurationRequestCount;
@property (strong, nonatomic) RICustomer *customer;
@property (strong, nonatomic) NSString *countriesRequestId;
@property (strong, nonatomic) NSString *apiRequestId;
@property (strong, nonatomic) NSString *cartRequestId;
@property (strong, nonatomic) NSString *customerRequestId;

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
    
    // Do any additional setup after loading the view.
    self.screenName = @"SplashScreen";
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isPopupOpened = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
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
    
    [self hideLoading];
}

- (void)continueProcessing
{
    [self showLoading];
    
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
                                 if(isUpdateMandatory)
                                 {
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_UPDATE_NECESSARY_TITLE message:STRING_UPDATE_NECESSARY_MESSAGE delegate:self cancelButtonTitle:STRING_OK_UPDATE otherButtonTitles:nil];
                                     [alert setTag:kForceUpdateAlertViewTag];
                                     [alert show];
                                     
                                     [self hideLoading];
                                 }
                                 else
                                 {
                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:STRING_UPDATE_AVAILABLE_TITLE message:STRING_UPDATE_AVAILABLE_MESSAGE delegate:self cancelButtonTitle:STRING_NO_THANKS otherButtonTitles:STRING_UPDATE, nil];
                                     [alert setTag:kUpdateAvailableAlertViewTag];
                                     [alert show];
                                     
                                     [self hideLoading];
                                 }
                             }
                             else
                             {
                                 if (0 >= self.requestCount)
                                 {
                                     [self getConfigurations];
                                 }
                             }
                         }
                                   andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage)
                         {
                             if(RIApiResponseMaintenancePage == apiResponse)
                             {
                                 [self showMaintenancePage:@selector(continueProcessing) objects:nil];
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
                             [self hideLoading];
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
        
        self.customerRequestId = [RICustomer autoLogin:^(BOOL success, RICustomer *customer)
                                  {
                                      self.customer = customer;
                                      [RICountry getCountryConfigurationWithSuccessBlock:^(RICountryConfiguration *configuration)
                                       {
                                           [RIGoogleAnalyticsTracker initGATrackerWithId:configuration.gaId];
                                           
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
            [trackingDictionary setValue:[NSNumber numberWithInt:[ageComponents year]] forKey:kRIEventAgeKey];
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
    
    [[RITrackingWrapper sharedInstance] sendLaunchEventWithData:[launchData copy]];
    
    [[RITrackingWrapper sharedInstance] trackEvent:event
                                              data:[trackingDictionary copy]];
    
    trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventChangeCountry]
                                              data:[trackingDictionary copy]];
    
    [self hideLoading];
    
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
            
            NSURL  *url = [NSURL URLWithString:kAppStoreUrl];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
    else if(kForceUpdateAlertViewTag == [alertView tag])
    {
        if(0 == buttonIndex)
        {
            NSURL  *url = [NSURL URLWithString:kAppStoreUrl];
            if([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
    }
}

@end
