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

@interface JASplashViewController ()
<
JAChooseCountryDelegate,
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
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update necessary" message:@"We found something that we needed to fix to make shopping experience in Jumia even better! You will need to update before continue using the app." delegate:self cancelButtonTitle:@"Ok, Update!" otherButtonTitles:nil];
                                  [alert setTag:kForceUpdateAlertViewTag];
                                  [alert show];
                                  
                                  [self hideLoading];
                              }
                              else
                              {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update available" message:@"There is a new update available that we prepared to make shopping experience in Jumia even better! Make sure you upgrade today!" delegate:self cancelButtonTitle:@"No, thanks." otherButtonTitles:@"Update!", nil];
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
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update necessary" message:@"We found something that we needed to fix to make shopping experience in Jumia even better! You will need to update before continue using the app." delegate:self cancelButtonTitle:@"Ok, Update!" otherButtonTitles:nil];
                                      [alert setTag:kForceUpdateAlertViewTag];
                                      [alert show];
                                      
                                      [self hideLoading];
                                  }
                                  else
                                  {
                                      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update available" message:@"There is a new update available that we prepared to make shopping experience in Jumia even better! Make sure you upgrade today!" delegate:self cancelButtonTitle:@"No, thanks." otherButtonTitles:@"Update!", nil];
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
            [self.navigationItem setHidesBackButton:YES
                                           animated:NO];
            
            self.navigationBarView = [JANavigationBarView getNewNavBarView];
            [self.navigationController.navigationBar.viewForBaselineLayout addSubview:self.navigationBarView];
            
            [self.navigationBarView changeToChooseCountry];
            self.navigationBarView.leftButton.hidden = YES;
            
            [self.navigationBarView.applyButton addTarget:self
                                                   action:@selector(sendSelectedCountryNotification)
                                         forControlEvents:UIControlEventTouchUpInside];
            
            JAChooseCountryViewController *choose = [self.storyboard instantiateViewControllerWithIdentifier:@"chooseCountryViewController"];
            choose.delegate = self;
            
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
        [RICustomer getCustomerWithSuccessBlock:^(id customer) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                object:nil];
            [self procedeToFirstAppScreen];
        } andFailureBlock:^(NSArray *errorMessages) {
            [self procedeToFirstAppScreen];
        }];
    }
}

- (void)procedeToFirstAppScreen
{
    if(!self.isPopupOpened)
    {
        UIViewController* rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"rootViewController"];
        
        [[[UIApplication sharedApplication] delegate] window].rootViewController = rootViewController;
        
        [self hideLoading];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Send notification action

- (void)sendSelectedCountryNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kDidPressApplyNotification
                                                        object:nil];
}

#pragma mark - Choose country delegate

- (void)didSelectedCountry:(RICountry *)country
{
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
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update necessary" message:@"We found something that we needed to fix to make shopping experience in Jumia even better! You will need to update before continue using the app." delegate:self cancelButtonTitle:@"Ok, Update!" otherButtonTitles:nil];
                              [alert setTag:kForceUpdateAlertViewTag];
                              [alert show];
                              
                              [self hideLoading];
                          }
                          else
                          {
                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update available" message:@"There is a new update available that we prepared to make shopping experience in Jumia even better! Make sure you upgrade today!" delegate:self cancelButtonTitle:@"No, thanks." otherButtonTitles:@"Update!", nil];
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

@end
