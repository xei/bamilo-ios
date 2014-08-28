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
#import <FacebookSDK/FacebookSDK.h>

@interface JASignInViewController ()
<
JADynamicFormDelegate,
FBLoginViewDelegate
>

@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (strong, nonatomic) NSMutableArray *fieldsArray;
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
    
    [self showLoading];
    
    self.loginView.layer.cornerRadius = 5.0f;
    
    [self.loginLabel setText:@"Credentials"];
    [self.loginLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    
    [self.loginSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    
    self.fieldsArray = [NSMutableArray new];
    
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
    [self.facebookLoginLabel setText:@"Login with Facebook"];
    [self.facebookLoginLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.facebookLoginLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.facebookLoginLabel setTextAlignment:NSTextAlignmentCenter];
    [self.facebookLoginView addSubview:self.facebookLoginLabel];
    [self.loginView addSubview:self.facebookLoginView];
    
    [self.facebookLoginButton removeFromSuperview];
    
    [RIForm getForm:@"login"
       successBlock:^(RIForm *form) {
           
           self.loginViewCurrentY = CGRectGetMaxY(self.facebookLoginView.frame) + 6.0f;
           self.dynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:self.loginViewCurrentY];
           [self.dynamicForm setDelegate:self];
           self.fieldsArray = [self.dynamicForm.formViews copy];
           
           for(UIView *view in self.dynamicForm.formViews)
           {
               [self.loginView addSubview:view];
               self.loginViewCurrentY = CGRectGetMaxY(view.frame);
           }
           
           [self finishedFormLoading];
           
       } failureBlock:^(NSArray *errorMessage) {
           
           [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                       message:@"There was an error"
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"OK", nil] show];
           
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
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.loginView addSubview:self.loginButton];
    
    self.loginViewCurrentY = CGRectGetMaxY(self.loginButton.frame) + 5.0f;
    // Forgot Password
    self.forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotPasswordButton setFrame:CGRectMake(6.0f, self.loginViewCurrentY, 296.0f, 30.0f)];
    [self.forgotPasswordButton setBackgroundColor:[UIColor clearColor]];
    [self.forgotPasswordButton setTitle:@"Forgot Password?" forState:UIControlStateNormal];
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
    [self.signUpButton setTitle:@"Create Account" forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.loginView addSubview:self.signUpButton];
    
    self.loginViewHeightConstrain.constant = CGRectGetMaxY(self.signUpButton.frame) + 10.0f;
    self.loginViewBottomConstrain.constant = self.view.frame.size.height - (6.0f + CGRectGetMaxY(self.signUpButton.frame) + 10.0f);
    
    [self hideLoading];
}

- (void)signUpButtonPressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowBackNofication
                                                        object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignUpScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

- (void)forgotPasswordButtonPressed:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowBackNofication
                                                        object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowForgotPasswordScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

- (void)loginButtonPressed:(id)sender
{
    BOOL hasErrors = [self.dynamicForm checkErrors];
    
    if(!hasErrors)
    {
        NSDictionary *parameters = [self.dynamicForm getValues];
        
        [self showLoading];
        
        [RIForm sendForm:self.dynamicForm.form parameters:parameters successBlock:^(id object) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                object:@{@"index": @(0),
                                                                         @"name": @"Home"}];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                object:nil];
            [self hideLoading];
            
        } andFailureBlock:^(NSArray *errorObject) {
            [self hideLoading];
            
            [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                        message:[errorObject componentsJoinedByString:@","]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }];
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
                                                 [self hideLoading];
                                                 
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                                                                     object:@{@"index": @(0),
                                                                                                              @"name": @"Home"}];
                                                 
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                                                     object:nil];
                                             } andFailureBlock:^(NSArray *errorObject) {
                                                 [self hideLoading];
                                                 
                                                 [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                                                             message:@"Error doing login."
                                                                            delegate:nil
                                                                   cancelButtonTitle:nil
                                                                   otherButtonTitles:@"OK", nil] show];
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
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    self.loginViewBottomConstrain.constant = self.view.frame.size.height - (6.0f + CGRectGetMaxY(self.signUpButton.frame) - view.frame.origin.y);
}

- (void) lostFocus
{
    self.loginViewBottomConstrain.constant = self.view.frame.size.height - (6.0f + CGRectGetMaxY(self.signUpButton.frame) + 10.0f);
}

@end
