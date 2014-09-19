//
//  JASplashViewController.m
//  Jumia
//
//  Created by Telmo Pinto on 29/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASplashViewController.h"
#import "JARootViewController.h"
#import "RIApi.h"
#import "JAAppDelegate.h"
#import "RICustomer.h"
#import "JAChooseCountryViewController.h"
#import "JANavigationBarView.h"
#import <FacebookSDK/FBSession.h>
#import "RIAd4PushTracker.h"
#import "RIGoogleAnalyticsTracker.h"
#import "JAUtils.h"

@interface JASplashViewController ()
<
UIAlertViewDelegate
>

@property (weak, nonatomic) IBOutlet UIImageView *splashImage;
@property (assign, nonatomic) BOOL isPopupOpened;
@property (assign, nonatomic) NSInteger requestCount;
@property (strong, nonatomic) JANavigationBarView *navigationBarView;
@property (strong, nonatomic) NSDate *startTime;

@end

@implementation JASplashViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.startTime = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectCountry:)
                                                 name:kSelectedCountryNotification
                                               object:nil];
    
    if (self.selectedCountry)
    {
        self.navigationController.navigationBarHidden = YES;
        
        [self showLoading];
        
        self.requestCount = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementRequestCount) name:RISectionRequestStartedNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decrementRequestCount) name:RISectionRequestEndedNotificationName object:nil];
        
        [RIApi startApiWithCountry:self.selectedCountry
                      successBlock:^(RIApi *api, BOOL hasUpdate, BOOL isUpdateMandatory) {
                          
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
                              }
                          }
                          else
                          {
                              if (0 >= self.requestCount) {
                                  [self procedeToFirstAppScreen];
                              }
                          }
                      } andFailureBlock:^(NSArray *errorMessage) {
                          
                          [self hideLoading];
                          
                      }];
        
        if (self.view.frame.size.height > 500.0f)
        {
            self.splashImage.image = [UIImage imageNamed:@"splash5"];
        }
        else
        {
            self.splashImage.image = [UIImage imageNamed:@"splash4"];
        }
    }
    else
    {
        if ([RIApi checkIfHaveCountrySelected])
        {
            self.navigationController.navigationBarHidden = YES;
            
            [self showLoading];
            
            self.requestCount = 0;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementRequestCount) name:RISectionRequestStartedNotificationName object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decrementRequestCount) name:RISectionRequestEndedNotificationName object:nil];
            
            [RIApi startApiWithCountry:nil
                          successBlock:^(RIApi *api, BOOL hasUpdate, BOOL isUpdateMandatory) {
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
                                  }
                              }
                              else
                              {
                                  if (0 >= self.requestCount) {
                                      [self procedeToFirstAppScreen];
                                  }
                              }
                              
                          } andFailureBlock:^(NSArray *errorMessage) {
                              [self hideLoading];
                          }];
        }
        else
        {
            JAChooseCountryViewController *choose = [self.storyboard instantiateViewControllerWithIdentifier:@"chooseCountryViewController"];
            
            choose.navBarLayout.showMenuButton = NO;
            choose.navBarLayout.doneButtonTitle = STRING_APPLY;
            choose.navBarLayout.title = STRING_CHOOSE_COUNTRY;
            
            //center navigation doesn't exit yet, create a "fake" nav bar
            self.navigationBarView = [JANavigationBarView getNewNavBarView];
            [self.navigationController.navigationBar.viewForBaselineLayout addSubview:self.navigationBarView];
            //manual setup of the "fake" nav bar
            [self.navigationBarView initialSetup];
            [self.navigationBarView.doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
            [self.navigationBarView setupWithNavigationBarLayout:choose.navBarLayout];
            self.navigationBarView.doneButton.enabled = NO;
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeDoneButtonState:) name:kEditShouldChangeStateNotification object:nil];
            
            [self.navigationController pushViewController:choose
                                                 animated:YES];
            
        }
        
        if (self.view.frame.size.height > 500.0f)
        {
            self.splashImage.image = [UIImage imageNamed:@"splash5"];
        }
        else
        {
            self.splashImage.image = [UIImage imageNamed:@"splash4"];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isPopupOpened = NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
        [self procedeToFirstAppScreen];
    }
}

- (void)procedeToFirstAppScreen
{
    if(!self.isPopupOpened)
    {
        [RICustomer autoLogin:^(BOOL success){
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];

            if(success)
            {
                [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
                [trackingDictionary setValue:@"AutoLoginSuccess" forKey:kRIEventActionKey];
            }
            else
            {
                [trackingDictionary setValue:@"AutoLoginFailed" forKey:kRIEventActionKey];
            }
            
            UIViewController* rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootViewController"];
            
            [[[UIApplication sharedApplication] delegate] window].rootViewController = rootViewController;
            
            CGFloat duration = fabs([self.startTime timeIntervalSinceNow] * 1000);
            
            RICountryConfiguration *config = [RICountryConfiguration getCurrentConfiguration];
            [RIGoogleAnalyticsTracker initGATrackerWithId:config.gaId];
            
            NSMutableDictionary *launchData = [[NSMutableDictionary alloc] init];
            [launchData setValue:[NSString stringWithFormat:@"%f", duration] forKey:kRILaunchEventDurationDataKey];
            
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [launchData setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
            
            [launchData setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
            
            [[RITrackingWrapper sharedInstance] sendLaunchEventWithData:[launchData copy]];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventAutoLogin]
                                                      data:[trackingDictionary copy]];
            
            // Changed country in deeplink
            if (self.tempNotification)
            {
                [NSTimer scheduledTimerWithTimeInterval:0.3
                                                 target:self
                                               selector:@selector(finishNotification)
                                               userInfo:nil
                                                repeats:NO];
            }
            
            [self hideLoading];
        }];
    }
}

- (void)finishNotification
{
    NSDictionary *temp = self.tempNotification;
    self.tempNotification = nil;
    
    [[RIAd4PushTracker sharedInstance] handleNotificationWithDictionary:temp];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Choose country delegate

- (void)didSelectCountry:(NSNotification*)notification
{
    RICountry *country = notification.object;
    if (VALID_NOTEMPTY(country, RICountry)) {
        [self showLoading];
        
        self.requestCount = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(incrementRequestCount) name:RISectionRequestStartedNotificationName object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(decrementRequestCount) name:RISectionRequestEndedNotificationName object:nil];
        
        [RIApi startApiWithCountry:country
                      successBlock:^(RIApi *api, BOOL hasUpdate, BOOL isUpdateMandatory) {
                          
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
                              }
                          }
                          else
                          {
                              if (0 >= self.requestCount) {
                                  [self procedeToFirstAppScreen];
                              }
                          }
                          
                      } andFailureBlock:^(NSArray *errorMessage) {
                          [self hideLoading];
                      }];
    }
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
                [self procedeToFirstAppScreen];
            }
        }
        else if(1 == buttonIndex)
        {
            if (0 >= self.requestCount) {
                [self procedeToFirstAppScreen];
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

#pragma mark - Fake nav bar button actions

- (void)done
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidPressDoneNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kEditShouldChangeStateNotification object:nil];
}

- (void)changeDoneButtonState:(NSNotification *)notification
{
    NSNumber* state = [notification.userInfo objectForKey:@"enabled"];
    self.navigationBarView.doneButton.enabled = [state boolValue];
}

@end
