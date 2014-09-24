//
//  JASignInViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASignInViewController.h"
#import "RIForm.h"
#import "RIField.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import <FacebookSDK/FacebookSDK.h>

@interface JASignInViewController ()
<
    JADynamicFormDelegate,
    FBLoginViewDelegate,
    JANoConnectionViewDelegate
>

@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIView *loginSeparator;
@property (weak, nonatomic) UIButton *loginButton;
@property (weak, nonatomic) UIButton *signUpButton;
@property (weak, nonatomic) UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookLoginButton;
@property (strong, nonatomic) FBLoginView *facebookLoginView;
@property (strong, nonatomic) UILabel *facebookLoginLabel;
@property (assign, nonatomic) CGFloat loginViewCurrentY;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewHeightConstrain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewBottomConstrain;

@end

@implementation JASignInViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.title = STRING_LOGIN;
    
    [self showLoading];
    
    self.loginView.layer.cornerRadius = 5.0f;
    
    [self.loginLabel setText:STRING_CREDENTIALS];
    [self.loginLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    
    [self.loginSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    
    self.facebookLoginView = [[FBLoginView alloc] init];
    self.facebookLoginView.delegate = self;
    self.facebookLoginView.readPermissions = @[@"public_profile", @"email", @"user_birthday"];
    [self.facebookLoginView setFrame:self.facebookLoginButton.frame];
    
    for (id obj in self.facebookLoginView.subviews)
    {
        if ([obj isKindOfClass:[UIButton class]])
        {
            UIButton * loginButton =  obj;
            [loginButton setBackgroundImage:[UIImage imageNamed:@"facebookMedium_normal"] forState:UIControlStateNormal];
            [loginButton setBackgroundImage:[UIImage imageNamed:@"facebookMedium_highlighted"] forState:UIControlStateHighlighted];
            [loginButton setBackgroundImage:[UIImage imageNamed:@"facebookMedium_highlighted"] forState:UIControlStateSelected];
            [loginButton sizeToFit];
        }
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            loginLabel.frame = CGRectMake(0, 0, 0, 0);
        }
    }
    self.facebookLoginLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 296.0f, 44.0f)];
    [self.facebookLoginLabel setText:STRING_LOGIN_WITH_FACEBOOK];
    [self.facebookLoginLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.facebookLoginLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.facebookLoginLabel setTextAlignment:NSTextAlignmentCenter];
    [self.facebookLoginView addSubview:self.facebookLoginLabel];
    [self.loginView addSubview:self.facebookLoginView];
    
    [self.facebookLoginButton removeFromSuperview];
    
    self.loginViewCurrentY = CGRectGetMaxY(self.facebookLoginView.frame) + 6.0f;
    
    [RIForm getForm:@"login"
       successBlock:^(RIForm *form) {
           
           self.dynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:self.loginViewCurrentY];
           [self.dynamicForm setDelegate:self];
           
           for(UIView *view in self.dynamicForm.formViews)
           {
               [self.loginView addSubview:view];
               self.loginViewCurrentY = CGRectGetMaxY(view.frame);
           }
           
           [self finishedFormLoading];
           
       } failureBlock:^(NSArray *errorMessage) {
           
           [self finishedFormLoading];
           
           JAErrorView *errorView = [JAErrorView getNewJAErrorView];
           [errorView setErrorTitle:STRING_ERROR
                           andAddTo:self];
           
       }];
}

#pragma mark - Action

- (void)finishedFormLoading
{
    self.loginViewCurrentY += 15.0f;
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setFrame:CGRectMake(6.0f, self.loginViewCurrentY, 296.0f, 44.0f)];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [self.loginButton setTitle:STRING_LOGIN forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.loginView addSubview:self.loginButton];
    
    self.loginViewCurrentY = CGRectGetMaxY(self.loginButton.frame) + 5.0f;
    // Forgot Password
    self.forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotPasswordButton setFrame:CGRectMake(6.0f, self.loginViewCurrentY, 296.0f, 30.0f)];
    [self.forgotPasswordButton setBackgroundColor:[UIColor clearColor]];
    [self.forgotPasswordButton setTitle:STRING_FORGOT_PASSWORD forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.forgotPasswordButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateSelected];
    [self.forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotPasswordButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.loginView addSubview:self.forgotPasswordButton];
    
    self.loginViewCurrentY = CGRectGetMaxY(self.forgotPasswordButton.frame) + 6.0f;
    self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.signUpButton setFrame:CGRectMake(6.0f, self.loginViewCurrentY, 296.0f, 44.0f)];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"grayBig_normal"] forState:UIControlStateNormal];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"grayBig_highlighted"] forState:UIControlStateHighlighted];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"grayBig_highlighted"] forState:UIControlStateSelected];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"grayBig_disabled"] forState:UIControlStateDisabled];
    [self.signUpButton setTitle:STRING_CREATE_ACCOUNT forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.loginView addSubview:self.signUpButton];
    
    self.loginViewHeightConstrain.constant = CGRectGetMaxY(self.signUpButton.frame) + 10.0f;
    self.loginViewBottomConstrain.constant = self.view.frame.size.height - (6.0f + CGRectGetMaxY(self.signUpButton.frame) + 10.0f) - 200.0f;
    
    [self hideLoading];
}

- (void)signUpButtonPressed:(id)sender
{
    [self.dynamicForm resignResponder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignUpScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

- (void)forgotPasswordButtonPressed:(id)sender
{
    [self.dynamicForm resignResponder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowForgotPasswordScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

- (void)loginButtonPressed:(id)sender
{
    [self.dynamicForm resignResponder];
    
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self continueLogin];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self continueLogin];
    }
}

- (void)continueLogin
{
    [self.dynamicForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.dynamicForm form]
          parameters:[self.dynamicForm getValues]
        successBlock:^(id object)
     {
         [self.dynamicForm resetValues];
         
         NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
         [trackingDictionary setValue:((RICustomer *)object).idCustomer forKey:kRIEventLabelKey];
         [trackingDictionary setValue:@"LoginSuccess" forKey:kRIEventActionKey];
         [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
         [trackingDictionary setValue:((RICustomer *)object).idCustomer forKey:kRIEventUserIdKey];
         [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
         [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
         NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
         [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
         
         [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLoginSuccess]
                                                   data:[trackingDictionary copy]];
         
         [self hideLoading];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                             object:@{@"index": @(0),
                                                                      @"name": STRING_HOME}];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                             object:nil];
     } andFailureBlock:^(id errorObject) {
         
         NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
         [trackingDictionary setValue:@"LoginFailed" forKey:kRIEventActionKey];
         [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
         
         [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLoginFail]
                                                   data:[trackingDictionary copy]];
         
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
            [self continueLogin];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self continueLogin];
    }
}

#pragma mark - Facebook Delegate

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView
                            user:(id<FBGraphUser>)user
{
    if (![RICustomer checkIfUserIsLogged])
    {
        [self showLoading];
        
        NSString *email = [user objectForKey:@"email"];
        NSString *firstName = [user objectForKey:@"first_name"];
        NSString *lastName = [user objectForKey:@"last_name"];
        NSString *birthday = [user objectForKey:@"birthday"];
        NSString *gender = [user objectForKey:@"gender"];
        
        NSDictionary *parameters = @{ @"email": email,
                                      @"first_name": firstName,
                                      @"last_name": lastName,
                                      @"birthday": birthday,
                                      @"gender": gender };
        
        [RICustomer loginCustomerByFacebookWithParameters:parameters
                                             successBlock:^(id customer) {
                                                 
                                                 NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                                 [trackingDictionary setValue:((RICustomer *)customer).idCustomer forKey:kRIEventLabelKey];
                                                 [trackingDictionary setValue:@"FacebookLoginSuccess" forKey:kRIEventActionKey];
                                                 [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
                                                 [trackingDictionary setValue:((RICustomer *)customer).idCustomer forKey:kRIEventUserIdKey];
                                                 [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                                                 [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                                                 NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                                 [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                                                 
                                                 [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookLoginSuccess]
                                                                                           data:[trackingDictionary copy]];
                                                 
                                                 [self.dynamicForm resetValues];
                                                 
                                                 [self hideLoading];

                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                                                     object:@{@"index": @(0),
                                                                                                              @"name": STRING_HOME}];
                                                 
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                                                     object:nil];
                                             } andFailureBlock:^(NSArray *errorObject) {
                                                 
                                                 NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                                 [trackingDictionary setValue:@"LoginFailed" forKey:kRIEventActionKey];
                                                 [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
                                                 
                                                 [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookLoginFail]
                                                                                           data:[trackingDictionary copy]];
                                                 
                                                 [self hideLoading];
                                                 
                                                 JAErrorView *errorView = [JAErrorView getNewJAErrorView];
                                                 [errorView setErrorTitle:STRING_ERROR
                                                                 andAddTo:self];

                                             }];
    }
}


// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error
{
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage)
    {
        JAErrorView *errorView = [JAErrorView getNewJAErrorView];
        [errorView setErrorTitle:alertMessage
                        andAddTo:self];
    }
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    [UIView animateWithDuration:0.5f animations:^{
        self.loginViewBottomConstrain.constant = self.view.frame.size.height - (6.0f + CGRectGetMaxY(self.signUpButton.frame) - view.frame.origin.y);
        [self.loginView layoutIfNeeded];
    }];
}

- (void) lostFocus
{
    [UIView animateWithDuration:0.5f animations:^{
        self.loginViewBottomConstrain.constant = self.view.frame.size.height - (6.0f + CGRectGetMaxY(self.signUpButton.frame) + 10.0f);
        [self.loginView layoutIfNeeded];
    }];
}

@end
