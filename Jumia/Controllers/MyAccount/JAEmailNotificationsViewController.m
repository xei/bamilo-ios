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
    JADynamicFormDelegate
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
    
    self.screenName = @"CustomerEmailNotifications";
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_USER_EMAIL_NOTIFICATIONS;
    
    self.topView.layer.cornerRadius = 4.0f;
    
    [self showLoading];
    
    self.formHeight = 0.0f;
    
    [self getForm];
}

- (void)getForm
{
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
           
           [self.saveButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
           [self.saveButton setTitle:STRING_SAVE_LABEL forState:UIControlStateNormal];
           [self.saveButton addTarget:self action:@selector(continueUpdatePreferences) forControlEvents:UIControlEventTouchUpInside];
           
           if(self.firstLoading)
           {
               NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
               [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
               self.firstLoading = NO;
           }

           [self hideLoading];
           
       } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
           
           if(self.firstLoading)
           {
               NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
               [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
               self.firstLoading = NO;
           }

           BOOL noConnection = NO;
           if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
           {
               noConnection = YES;
           }
           [self showErrorView:noConnection startingY:0.0f selector:@selector(getForm) objects:nil];
           
           [self hideLoading];
       }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
                     [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
                     [trackingDictionary setValue:@"My Account" forKey:kRIEventLocationKey];
                     
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
         
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
     {
         [self hideLoading];
         
         if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
         {
             [self showMessage:STRING_NO_NEWTORK success:NO];
         }
         else if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.dynamicForm validateFields:errorObject];
             
             [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.dynamicForm checkErrors];
             
             [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
         }
         else
         {
             [self.dynamicForm checkErrors];
             
             [self showMessage:STRING_ERROR success:NO];
         }
     }];
}

@end
