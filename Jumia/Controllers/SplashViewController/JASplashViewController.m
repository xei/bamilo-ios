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

@interface JASplashViewController ()
<
UIAlertViewDelegate
>

@property (nonatomic, assign) BOOL isPopupOpened;
@property (nonatomic, assign) NSInteger requestCount;
@property (weak, nonatomic) IBOutlet UIImageView *splashImage;
@property (strong, nonatomic) JANavigationBarView *navigationBarView;

@end

@implementation JASplashViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSelectCountry:)
                                                 name:kSelectedCountryNotification
                                               object:nil];
    
    if (self.selectedCountry)
    {
        self.navigationController.navigationBarHidden = YES;
        
        [self showLoading];
        
//        // Change the Facebook app id
//        NSString *appId;
//        
//#warning Necessary to check if the facebook app id is changed properly
//        
//        if ([self.selectedCountry.countryIso isEqualToString:@"MA"]) {
//            appId = @"518468904830623";
//        } else if ([self.selectedCountry.countryIso isEqualToString:@"CI"]) {
//            appId = @"472507709498904";
//        } else if ([self.selectedCountry.countryIso isEqualToString:@"NG"]) {
//            appId = @"321703697936806";
//        } else if ([self.selectedCountry.countryIso isEqualToString:@"EG"]) {
//            appId = @"390085037744566";
//        } else if ([self.selectedCountry.countryIso isEqualToString:@"KE"]) {
//            appId = @"319581271497227";
//        } else if ([self.selectedCountry.countryIso isEqualToString:@"UG"]) {
//            appId = @"321703697936806";
//        } else if ([self.selectedCountry.countryIso isEqualToString:@"GH"]) {
//            appId = @"321703697936806";
//        } else {
//            appId = @"321703697936806";
//        }
//
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"Info"
//                                                         ofType:@"plist"];
//        NSMutableDictionary *menuDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:path];
//        [menuDictionary removeObjectForKey:@"FacebookAppID"];
//        [menuDictionary addEntriesFromDictionary:@{@"FacebookAppID": appId}];
//        
//        NSError *error;
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *documentsDirectory = [paths objectAtIndex:0];
//        
//        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"Info.plist"];
//        
//        if (![[NSFileManager defaultManager] fileExistsAtPath: path])
//        {
//            NSString *bundle = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
//            [[NSFileManager defaultManager]  copyItemAtPath:bundle toPath:path error:&error];
//        }
//        
//        [menuDictionary writeToFile:plistPath atomically: YES];
        
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
        [RICustomer autoLogin:^{
            UIViewController* rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootViewController"];
            
            [[[UIApplication sharedApplication] delegate] window].rootViewController = rootViewController;
            
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
