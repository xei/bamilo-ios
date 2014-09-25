//
//  JAEmailNotificationsViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 17/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAEmailNotificationsViewController.h"
#import "RIForm.h"
#import "JAButtonWithBlur.h"
#import "RICustomer.h"
#import "JANewsletterComponent.h"

@interface JAEmailNotificationsViewController ()
<
    JADynamicFormDelegate,
    JANoConnectionViewDelegate
>

@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (strong, nonatomic) IBOutlet UIView *topView;
@property (assign, nonatomic) float formHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *height;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation JAEmailNotificationsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_USER_EMAIL_NOTIFICATIONS;
    
    self.topView.layer.cornerRadius = 4.0f;
    
    [self showLoading];
    
    self.formHeight = 0.0f;
    
    [RIForm getForm:@"managenewsletters"
       successBlock:^(RIForm *form) {
           
           self.dynamicForm = [[JADynamicForm alloc] initWithForm:form
                                                                delegate:self
                                                            startingPosition:self.formHeight];
           
           for(UIView *view in self.dynamicForm.formViews)
           {
               [self.topView addSubview:view];
               self.formHeight = CGRectGetMaxY(view.frame);
           }
           
           self.height.constant = self.formHeight + 6.0f;
           
           [self.saveButton setTitle:STRING_SAVE_LABEL forState:UIControlStateNormal];
           [self.saveButton addTarget:self action:@selector(updatePreferences) forControlEvents:UIControlEventTouchUpInside];
           
           [self hideLoading];
           
       } failureBlock:^(NSArray *errorMessage) {
           
           [self hideLoading];
           
           JAErrorView *errorView = [JAErrorView getNewJAErrorView];
           [errorView setErrorTitle:STRING_ERROR
                           andAddTo:self];
       }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action

- (void)updatePreferences
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self continueUpdatePreferences];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self continueUpdatePreferences];
    }
}

- (void)continueUpdatePreferences
{
    [self.dynamicForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.dynamicForm form]
          parameters:[self.dynamicForm getValues]
        successBlock:^(id object)
     {
         BOOL notSelectedNewsletter = YES;
         
         for (UIView *view in self.dynamicForm.formViews) {
             if ([view isKindOfClass:[JACheckBoxWithOptionsComponent class]])
             {
                 if (((JACheckBoxWithOptionsComponent *)view).values.count > 0)
                 {
                     NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                     [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
                     [trackingDictionary setValue:@"SubscribeNewsletter" forKey:kRIEventActionKey];
                     [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
                     
                     [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventNewsletter]
                                                               data:[trackingDictionary copy]];
                     
                     notSelectedNewsletter = NO;
                     
                     break;
                 }
             }
         }
         
         if (notSelectedNewsletter)
         {
             NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
             [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
             [trackingDictionary setValue:@"UnsubscribeNewsletter" forKey:kRIEventActionKey];
             [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
             
             [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventNewsletter]
                                                       data:[trackingDictionary copy]];
         }
         
         [self.dynamicForm resetValues];
         
         [self hideLoading];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:kDidSaveEmailNotificationsNotification object:nil];
         [self.navigationController popViewControllerAnimated:YES];
         
     } andFailureBlock:^(id errorObject)
     {
         [self hideLoading];
         
         if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.dynamicForm validateFields:errorObject];
             
             JAErrorView *errorView = [JAErrorView getNewJAErrorView];
             [errorView setErrorTitle:STRING_ERROR_INVALID_FIELDS
                             andAddTo:self];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.dynamicForm checkErrors];
             
             JAErrorView *errorView = [JAErrorView getNewJAErrorView];
             [errorView setErrorTitle:[errorObject componentsJoinedByString:@","]
                             andAddTo:self];
         }
         else
         {
             [self.dynamicForm checkErrors];
             
             JAErrorView *errorView = [JAErrorView getNewJAErrorView];
             [errorView setErrorTitle:STRING_ERROR
                             andAddTo:self];
         }
     }];
}

#pragma mark - No connection delegate

- (void)retryConnection
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self continueUpdatePreferences];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self continueUpdatePreferences];
    }
}

@end