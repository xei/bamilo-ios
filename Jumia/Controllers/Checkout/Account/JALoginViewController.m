//
//  JALoginViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JALoginViewController.h"
#import "JAAddressesViewController.h"
#import "RIForm.h"
#import "RIField.h"
#import <FacebookSDK/FacebookSDK.h>

@interface JALoginViewController ()
<
UITextFieldDelegate,
FBLoginViewDelegate
>

@property (assign, nonatomic) NSInteger numberOfFormsToLoad;
@property (strong, nonatomic) NSMutableArray *fieldsArray;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// Login
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *loginSeparator;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewConstrains;
@property (weak, nonatomic) IBOutlet UIView *loginFormView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginFormViewConstrains;
@property (assign, nonatomic) CGFloat loginFormHeight;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *forgotButton;
@property (strong, nonatomic) UIButton *facebookLoginButton;

// Signup
@property (weak, nonatomic) IBOutlet UIView *signUpView;
@property (weak, nonatomic) IBOutlet UIView *signUpSeparator;
@property (weak, nonatomic) IBOutlet UILabel *signUpLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpViewConstrains;
@property (weak, nonatomic) IBOutlet UIView *signUpFormView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpViewFormConstrains;
@property (assign, nonatomic) CGFloat signupFormHeight;
@property (strong, nonatomic) UIButton *signUpButton;
@property (strong, nonatomic) UIButton *facebookSignupButton;


@property (strong, nonatomic) FBLoginView *facebookLoginView;

@end

@implementation JALoginViewController

@synthesize numberOfFormsToLoad=_numberOfFormsToLoad;
-(void)setNumberOfFormsToLoad:(NSInteger)numberOfFormsToLoad
{
    _numberOfFormsToLoad=numberOfFormsToLoad;
    if (0 == numberOfFormsToLoad) {
        [self finishedFormsLoading];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
    
    [self showLoading];
    
    self.numberOfFormsToLoad = 2;
    [RIForm getForm:@"login"
       successBlock:^(RIForm *form) {
           
           
           NSArray *views = [JAFormComponent generateForm:[form.fields array] startingY:1.0f];
           self.fieldsArray = [views copy];
           self.loginFormHeight = 0.0f;
           for(UIView *view in views)
           {
               [self.loginFormView addSubview:view];
               if(CGRectGetMaxY(view.frame) > self.loginFormHeight)
               {
                   self.loginFormHeight = CGRectGetMaxY(view.frame);
               }
           }
           
           self.numberOfFormsToLoad--;
           
       } failureBlock:^(NSArray *errorMessage) {
           
           self.numberOfFormsToLoad--;
           
           [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                       message:@"There was an error"
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"OK", nil] show];
           
       }];
    
    [RIForm getForm:@"registersignup"
       successBlock:^(RIForm *form) {
           
           
           NSArray *views = [JAFormComponent generateForm:[form.fields array] startingY:1.0f];
           self.fieldsArray = [views copy];
           self.signupFormHeight = 0.0f;
           for(UIView *view in views)
           {
               [self.signUpFormView addSubview:view];
               if(CGRectGetMaxY(view.frame) > self.signupFormHeight)
               {
                   self.signupFormHeight = CGRectGetMaxY(view.frame);
               }
           }
           
           self.numberOfFormsToLoad--;
           
       } failureBlock:^(NSArray *errorMessage) {
           self.numberOfFormsToLoad--;
           
           [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                       message:@"There was an error"
                                      delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"OK", nil] show];
           
       }];
}

- (void) setupViews
{
    self.loginView.layer.cornerRadius = 5.0f;
    
    UITapGestureRecognizer *showLoginViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(showLogin)];
    [self.loginView addGestureRecognizer:showLoginViewTap];
    [self.loginLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.loginLabel setText:@"Login"];
    [self.loginSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    
    self.signUpView.layer.cornerRadius = 5.0f;
    UITapGestureRecognizer *showSignupViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(showSignup)];
    [self.signUpView addGestureRecognizer:showSignupViewTap];
    [self.signUpLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.signUpLabel setText:@"Signup"];
    [self.signUpSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
}

- (void) finishedFormsLoading
{
    [self finishingSetupViews];
    
    [self hideLoading];
    
    [self showLogin];
}

- (void) finishingSetupViews
{
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setFrame:CGRectMake(6.0f, 1.0f + self.loginFormHeight + 6.0f, 296.0f, 44.0f)];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.loginFormView addSubview:self.loginButton];
    
    self.loginFormHeight += self.loginButton.frame.size.height;
    
    self.forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotButton setFrame:CGRectMake(6.0f, 1.0f + self.loginFormHeight + 6.0f, 296.0f, 44.0f)];
    [self.forgotButton setBackgroundColor:[UIColor clearColor]];
    [self.forgotButton setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.forgotButton addTarget:self action:@selector(forgotButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.loginFormView addSubview:self.forgotButton];
    
    self.loginFormHeight += self.forgotButton.frame.size.height;
    
    self.facebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookLoginButton setFrame:CGRectMake(6.0f, 1.0f + self.loginFormHeight + 6.0f, 296.0f, 44.0f)];
    [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
    [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [self.facebookLoginButton setTitle:@"Login with Facebook" forState:UIControlStateNormal];
    [self.facebookLoginButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.facebookLoginButton addTarget:self action:@selector(facebookLoginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.loginFormView addSubview:self.facebookLoginButton];
    
    self.loginFormHeight += self.facebookLoginButton.frame.size.height + 6.0f;
    
    self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.signUpButton setFrame:CGRectMake(6.0f, 1.0f + self.signupFormHeight + 6.0f, 296.0f, 44.0f)];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [self.signUpButton setTitle:@"Signup" forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(signUpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpFormView addSubview:self.signUpButton];
    
    self.signupFormHeight += self.signUpButton.frame.size.height + 6.0f;
    
    self.facebookSignupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookSignupButton setFrame:CGRectMake(6.0f, 1.0f + self.signupFormHeight + 6.0f, 296.0f, 44.0f)];
    [self.facebookSignupButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
    [self.facebookSignupButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [self.facebookSignupButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [self.facebookSignupButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [self.facebookSignupButton setTitle:@"Signup with Facebook" forState:UIControlStateNormal];
    [self.facebookSignupButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.facebookSignupButton addTarget:self action:@selector(facebookSignupButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpFormView addSubview:self.facebookSignupButton];
    
    self.signupFormHeight += self.facebookSignupButton.frame.size.height + 6.0f;
}

- (void) showLogin
{
    [UIView animateWithDuration:0.5 animations:^{
        [self hideSignup];
        self.loginFormViewConstrains.constant = self.loginFormHeight;
        [self.loginFormView setFrame:CGRectMake(self.loginFormView.frame.origin.x,
                                                self.loginFormView.frame.origin.y,
                                                self.loginFormView.frame.size.width,
                                                self.loginFormHeight)];
        
        self.loginViewConstrains.constant = 26.0f + self.loginFormHeight + 6.0f;
        [self.loginView setFrame:CGRectMake(self.loginView.frame.origin.x,
                                            self.loginView.frame.origin.y,
                                            self.loginView.frame.size.width,
                                            26.0f + self.loginFormHeight + 6.0f)];
    } completion:^(BOOL finished) {
        [self.loginFormView setHidden:NO];
    }];
}

- (void) hideLogin
{
    [self.loginFormView setHidden:YES];
    
    self.loginFormViewConstrains.constant = 0.0f;
    [self.loginFormView setFrame:CGRectMake(self.loginFormView.frame.origin.x,
                                            self.loginFormView.frame.origin.y,
                                            self.loginFormView.frame.size.width,
                                            0.0f)];
    
    self.loginViewConstrains.constant = 25.0f;
    [self.loginView setFrame:CGRectMake(self.loginView.frame.origin.x,
                                        self.loginView.frame.origin.y,
                                        self.loginView.frame.size.width,
                                        25.0f)];
}

- (void) showSignup
{
    [UIView animateWithDuration:0.5 animations:^{
        [self hideLogin];
        self.signUpViewFormConstrains.constant = self.signupFormHeight;
        [self.signUpFormView setFrame:CGRectMake(self.signUpFormView.frame.origin.x,
                                                 self.signUpFormView.frame.origin.y,
                                                 self.signUpFormView.frame.size.width,
                                                 self.signupFormHeight)];
        
        self.signUpViewConstrains.constant = 26.0f + self.signupFormHeight + 6.0f;
        [self.signUpView setFrame:CGRectMake(self.signUpView.frame.origin.x,
                                             self.signUpView.frame.origin.y,
                                             self.signUpView.frame.size.width,
                                             26.0f + self.signupFormHeight + 6.0f)];
    } completion:^(BOOL finished) {
        [self.signUpFormView setHidden:NO];
    }];
}

- (void) hideSignup
{
    [self.signUpFormView setHidden:YES];
    
    self.signUpViewFormConstrains.constant = 0.0f;
    [self.signUpFormView setFrame:CGRectMake(self.signUpFormView.frame.origin.x,
                                             self.signUpFormView.frame.origin.y,
                                             self.signUpFormView.frame.size.width,
                                             0.0f)];
    
    self.signUpViewConstrains.constant = 25.0f;
    [self.signUpView setFrame:CGRectMake(self.signUpView.frame.origin.x,
                                         self.signUpView.frame.origin.y,
                                         self.signUpView.frame.size.width,
                                         25.0f)];
}

-(void)loginButtonPressed
{
    NSLog(@"loginButtonPressed");
}

-(void)forgotButtonPressed
{
    NSLog(@"forgotButtonPressed");
}

-(void)facebookLoginButtonPressed
{
    NSLog(@"facebookLoginButtonPressed");
}

-(void)signUpButtonPressed
{
    NSLog(@"signUpButtonPressed");
}

-(void)facebookSignupButtonPressed
{
 NSLog(@"facebookSignupButtonPressed");
}

-(void)loginAndGoToAddressesAction
{
    [self showLoading];
    [RIForm getForm:@"login" successBlock:^(id form) {
        NSLog(@"Got login form with success");
        for (RIField *field in [form fields])
        {
            if([@"Alice_Module_Customer_Model_LoginForm[email]" isEqualToString:[field name]])
            {
                field.value = @"sofias@jumia.com";
            }
            else if([@"Alice_Module_Customer_Model_LoginForm[password]" isEqualToString:[field name]])
            {
                field.value = @"123456";
            }
        }
        [RIForm sendForm:form successBlock:^(NSDictionary *jsonObject) {
            NSLog(@"Login with success");
            [self hideLoading];
            
            JAAddressesViewController *addressesVC = [self.storyboard instantiateViewControllerWithIdentifier:@"addressesViewController"];
            
            [self.navigationController pushViewController:addressesVC
                                                 animated:YES];
            
        } andFailureBlock:^(NSArray *errorObject) {
            NSLog(@"Login failed");
            [self hideLoading];
        }];
    } failureBlock:^(NSArray *errorMessage) {
        NSLog(@"Failed getting login form");
        [self hideLoading];
    }];
}

@end
