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

@interface JAEmailNotificationsViewController ()
<
    JADynamicFormDelegate
>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *notificationsView;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
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
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                     self.view.frame.origin.y,
                                                                     self.view.frame.size.width,
                                                                     self.view.frame.size.height - 64.0f)];
    
    self.notificationsView = [[UIView alloc] initWithFrame:CGRectZero];
    self.notificationsView.layer.cornerRadius = 5.0f;
    [self.notificationsView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    [self.scrollView addSubview:self.notificationsView];
    [self.view addSubview:self.scrollView];
    
    [self showLoading];
    
    [self getForm];
}

- (void)getForm
{
    [RIForm getForm:@"managenewsletters"
       successBlock:^(RIForm *form) {
           
           self.dynamicForm = [[JADynamicForm alloc] initWithForm:form
                                                                delegate:self
                                                            startingPosition:0.0f];
           
           CGFloat formHeight = 0.0f;
           for(UIView *view in self.dynamicForm.formViews)
           {
               [self.notificationsView addSubview:view];
               formHeight = CGRectGetMaxY(view.frame);
           }
           
           [self.notificationsView setFrame:CGRectMake(6.0f, 6.0f, 308.0f, formHeight + 6.0f)];
           
           self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
           [self.saveButton setFrame:CGRectMake(6.0f, CGRectGetMaxY(self.notificationsView.frame) + 6.0f, 308.0f, 44.0f)];
           [self.saveButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
           [self.saveButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
           [self.saveButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
           [self.saveButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
           [self.saveButton setTitle:STRING_SAVE_LABEL forState:UIControlStateNormal];
           [self.saveButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
           [self.saveButton addTarget:self action:@selector(continueUpdatePreferences) forControlEvents:UIControlEventTouchUpInside];
           [self.saveButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
           [self.scrollView addSubview:self.saveButton];
           
           [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(self.saveButton.frame) + 6.0f)];
           
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
           
           if(RIApiResponseMaintenancePage == apiResponse)
           {
               [self showMaintenancePage:@selector(getForm) objects:nil];
           }
           else
           {
               BOOL noConnection = NO;
               if (RIApiResponseNoInternetConnection == apiResponse)
               {
                   noConnection = YES;
               }
               [self showErrorView:noConnection startingY:0.0f selector:@selector(getForm) objects:nil];
           }
           
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
                 NSMutableDictionary *values = [(JACheckBoxWithOptionsComponent*)view values];
                 if (VALID_NOTEMPTY(values, NSMutableDictionary))
                 {
                     NSArray *keys = [values allKeys];
                     for(NSString *key in keys)
                     {
                         NSString *value = [values objectForKey:key];
                         if(VALID_NOTEMPTY(value, NSString) && ![@"-1" isEqualToString:value])
                         {
                             notSelectedNewsletter = NO;
                             break;
                         }
                     }
                 }
             }
         }
         
         NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
         [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
         [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
         [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
         [trackingDictionary setValue:@"My Account" forKey:kRIEventLocationKey];
         if (notSelectedNewsletter)
         {
             [trackingDictionary setValue:@"UnsubscribeNewsletter" forKey:kRIEventActionKey];
         }
         else
         {
             [trackingDictionary setValue:@"SubscribeNewsletter" forKey:kRIEventActionKey];
         }

         [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventNewsletter]
                                                   data:[trackingDictionary copy]];
         
         [self.dynamicForm resetValues];
         
         [self hideLoading];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:kDidSaveEmailNotificationsNotification object:nil];
         [self.navigationController popViewControllerAnimated:YES];
         
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
     {
         [self hideLoading];
         
         if (RIApiResponseNoInternetConnection == apiResponse)
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
