//
//  JAMyAccountViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAMyAccountViewController.h"
#import "RIForm.h"
#import "RICustomer.h"

@interface JAMyAccountViewController ()

@property (strong, nonatomic) JADynamicForm *changePasswordForm;
@property (strong, nonatomic) JADynamicForm *manageNewsletterForm;
@property (assign, nonatomic) float changePasswordFormHeight;
@property (assign, nonatomic) float manageNewsletterFormHeight;
@property (weak, nonatomic) IBOutlet UIView *changePasswordView;
@property (weak, nonatomic) IBOutlet UIView *manageNewsletterView;
@property (weak, nonatomic) IBOutlet UISwitch *switchPushNotification;

@end

@implementation JAMyAccountViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.title = STRING_MY_ACCOUNT;
    
    // Get the form for the forgot password
    [RIForm getForm:@"changepassword"
       successBlock:^(RIForm *form) {
           
           self.changePasswordForm = [[JADynamicForm alloc] initWithForm:form startingPosition:7.0f];
           self.changePasswordFormHeight = 0.0f;
           
           for(UIView *view in self.changePasswordForm.formViews)
           {
               [self.changePasswordView addSubview:view];
               
               if(CGRectGetMaxY(view.frame) > self.changePasswordFormHeight)
               {
                   self.changePasswordFormHeight = CGRectGetMaxY(view.frame);
               }
           }
           
       } failureBlock:^(NSArray *errorMessage) {
           
           [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                       message:@"There was an error"
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:STRING_OK, nil] show];
           
       }];
    
    // Get the form for the newsletter
    [RIForm getForm:@"managenewsletters"
       successBlock:^(RIForm *form) {
           
           self.manageNewsletterForm = [[JADynamicForm alloc] initWithForm:form startingPosition:7.0f];
           self.manageNewsletterFormHeight = 0.0f;
           
           for(UIView *view in self.manageNewsletterForm.formViews)
           {
               [self.manageNewsletterView addSubview:view];
               
               if(CGRectGetMaxY(view.frame) > self.manageNewsletterFormHeight)
               {
                   self.manageNewsletterFormHeight = CGRectGetMaxY(view.frame);
               }
           }
           
       } failureBlock:^(NSArray *errorMessage) {
           
           [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                       message:@"There was an error"
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:STRING_OK, nil] show];
           
       }];
    
    // Verify if the push notifications are enabled
    UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
    
    if (types == UIRemoteNotificationTypeNone)
    {
        self.switchPushNotification.on = NO;
    }
    else
    {
        self.switchPushNotification.on = YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions

- (void)changePushNotificationStatus:(id)sender
{
    if (self.switchPushNotification.on)
    {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    }
}

- (void)changeNewsletterStatus:(id)sender
{
    [self.manageNewsletterForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.manageNewsletterForm form] parameters:[self.manageNewsletterForm getValues] successBlock:^(id object) {
        
        [[RITrackingWrapper sharedInstance] trackEvent:[RICustomer getCustomerId]
                                                 value:nil
                                                action:@"ChangeNewsletter"
                                              category:@"Account"
                                                  data:nil];
        
        [self.manageNewsletterForm resetValues];
        
        [self hideLoading];
        
        [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                    message:@"Newsletter settings changed"
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:STRING_OK, nil] show];
        
    } andFailureBlock:^(id errorObject) {
        [self hideLoading];
        
        if(VALID_NOTEMPTY(errorObject, NSDictionary))
        {
            [self.manageNewsletterForm validateFields:errorObject];
            
            [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                        message:STRING_ERROR_INVALID_FIELDS
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:STRING_OK, nil] show];
        }
        else if(VALID_NOTEMPTY(errorObject, NSArray))
        {
            [self.manageNewsletterForm checkErrors];
            
            [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                        message:[errorObject componentsJoinedByString:@","]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:STRING_OK, nil] show];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                        message:@"Generic error"
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:STRING_OK, nil] show];
        }
    }];
}

- (void)changePassword
{
    [self.changePasswordForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.changePasswordForm form] parameters:[self.changePasswordForm getValues] successBlock:^(id object) {
        
        [[RITrackingWrapper sharedInstance] trackEvent:[RICustomer getCustomerId]
                                                 value:nil
                                                action:@"ChangePassword"
                                              category:@"Account"
                                                  data:nil];
        
        [self.changePasswordForm resetValues];
        
        [self hideLoading];
        
        [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                    message:@"Passoword changed"
                                   delegate:nil
                          cancelButtonTitle:nil
                          otherButtonTitles:STRING_OK, nil] show];
        
    } andFailureBlock:^(id errorObject) {
        [self hideLoading];
        
        if(VALID_NOTEMPTY(errorObject, NSDictionary))
        {
            [self.changePasswordForm validateFields:errorObject];
            
            [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                        message:STRING_ERROR_INVALID_FIELDS
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:STRING_OK, nil] show];
        }
        else if(VALID_NOTEMPTY(errorObject, NSArray))
        {
            [self.changePasswordForm checkErrors];
            
            [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                        message:[errorObject componentsJoinedByString:@","]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:STRING_OK, nil] show];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:STRING_JUMIA
                                        message:@"Generic error"
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:STRING_OK, nil] show];
        }
    }];
}

@end
