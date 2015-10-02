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

#define kDynamicFormFieldsTag 1

@interface JAEmailNotificationsViewController ()
<
JADynamicFormDelegate
>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *notificationsView;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (strong, nonatomic) UIButton *saveButton;
@property (strong, nonatomic) RIForm *form;
@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JAEmailNotificationsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.apiResponse = RIApiResponseSuccess;
    self.screenName = @"CustomerEmailNotifications";
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_USER_EMAIL_NOTIFICATIONS;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(6.0f,
                                                                     6.0f,
                                                                     self.view.frame.size.width - 12.0f,
                                                                     self.view.frame.size.height - 64.0f)];
    
    self.notificationsView = [[UIView alloc] initWithFrame:CGRectZero];
    self.notificationsView.layer.cornerRadius = 5.0f;
    [self.notificationsView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    [self.scrollView addSubview:self.notificationsView];
    [self.view addSubview:self.scrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getForm];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"NewsletterSubscription"];
}

- (void)getForm
{
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse==RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    [RIForm getForm:@"manage_newsletters"
       successBlock:^(RIForm *form) {
           
           self.form = form;
           
           if(self.firstLoading)
           {
               NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
               [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
               self.firstLoading = NO;
           }
           
           [self setupView];
           [self removeErrorView];
           [self hideLoading];
           
       } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
           self.apiResponse = apiResponse;
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
           else if(RIApiResponseKickoutView == apiResponse)
           {
               [self showKickoutView:@selector(getForm) objects:nil];
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
             [self showMessage:STRING_NO_CONNECTION success:NO];
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

-(void)setupView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(6.0f,
                                                                     6.0f,
                                                                     self.view.frame.size.width - 12.0f,
                                                                     self.view.frame.size.height)];
    self.dynamicForm = [[JADynamicForm alloc] initWithForm:self.form
                                          startingPosition:0.0f
                                                 widthSize:self.scrollView.frame.size.width
                                        hasFieldNavigation:YES];
    
    [self.dynamicForm setDelegate:self];
    
    self.notificationsView = [[UIView alloc] initWithFrame:CGRectZero];
    self.notificationsView.layer.cornerRadius = 5.0f;
    [self.notificationsView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    [self.scrollView addSubview:self.notificationsView];
    [self.view addSubview:self.scrollView];
    
    CGFloat formHeight = 0.0f;
    for(UIView *view in self.dynamicForm.formViews)
    {
        [view setTag:kDynamicFormFieldsTag];
        [view setFrame:CGRectMake(0.0f,
                                  formHeight,
                                  self.scrollView.frame.size.width,
                                  view.frame.size.height)];
        [self.notificationsView addSubview:view];
        formHeight += CGRectGetMaxY(view.frame);
        if(RI_IS_RTL){
            [view flipSubviewAlignments];
        }
    }
    
    [self.notificationsView setFrame:CGRectMake(0.0f,
                                                0.0f,
                                                self.scrollView.frame.size.width,
                                                formHeight + 6.0f)];
    
    NSString *orangeButtonName = @"orangeBig_%@";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        orangeButtonName = @"orangeFullPortrait_%@";
    }
    
    UIImage *imageName = [UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"normal"]];
    self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.saveButton setFrame:CGRectMake((self.scrollView.frame.size.width - imageName.size.width) / 2, CGRectGetMaxY(self.notificationsView.frame) + 6.0f, imageName.size.width, imageName.size.height)];
    [self.saveButton setBackgroundImage:imageName forState:UIControlStateNormal];
    [self.saveButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]]forState:UIControlStateHighlighted];
    [self.saveButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]]forState:UIControlStateSelected];
    [self.saveButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"disabled"]]forState:UIControlStateDisabled];
    [self.saveButton setTitle:STRING_SAVE_LABEL forState:UIControlStateNormal];
    [self.saveButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.saveButton addTarget:self action:@selector(continueUpdatePreferences) forControlEvents:UIControlEventTouchUpInside];
    [self.saveButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:16.0f]];
    [self.scrollView addSubview:self.saveButton];
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(self.saveButton.frame) + 6.0f)];
}

-(UIButton *)saveButton
{
    if(!_saveButton)
    {
        _saveButton = [[UIButton alloc] initWithFrame:CGRectZero];
    }
    return _saveButton;
}

-(void) removeView
{
    [self.scrollView removeFromSuperview];
    
    [self.saveButton removeFromSuperview];
    
    NSArray *subViews = self.notificationsView.subviews;
    for(UIView *view in subViews)
    {
        if(kDynamicFormFieldsTag == view.tag)
        {
            [view removeFromSuperview];
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self removeView];
    
    [self showLoading];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupView];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

@end