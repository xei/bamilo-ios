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
@property (assign, nonatomic) float changePasswordFormHeight;
@property (weak, nonatomic) IBOutlet UIView *changePasswordView;
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
    
}

- (void)changeNewsletterStatus:(id)sender
{
    
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
