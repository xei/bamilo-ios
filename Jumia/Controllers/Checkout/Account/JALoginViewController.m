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
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewConstrains;
@property (weak, nonatomic) IBOutlet UIView *loginSeparator;
@property (assign, nonatomic) CGFloat loginFormHeight;
@property (weak, nonatomic) IBOutlet UIView *loginFormView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginFormViewConstrains;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIView *signUpView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpViewConstrains;
@property (weak, nonatomic) IBOutlet UIView *signUSeparator;
@property (assign, nonatomic) CGFloat signupFormHeight;
@property (weak, nonatomic) IBOutlet UIView *signUpFormView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpViewFormConstrains;
@property (weak, nonatomic) IBOutlet UILabel *signUpLabel;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIView *forgotView;
@property (weak, nonatomic) IBOutlet UIButton *forgotButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookLogin;
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
           
           self.numberOfFormsToLoad--;
           
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
           
           self.numberOfFormsToLoad--;
           
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
    [self.signUSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
}

- (void) finishedFormsLoading
{
    [self hideLoading];
    
    [self showLogin];
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
        [self.signUpFormView setFrame:CGRectMake(self.signUpFormView.frame.origin.x,
                                                 self.signUpFormView.frame.origin.y,
                                                 self.signUpFormView.frame.size.width,
                                                 self.signupFormHeight)];
        self.signUpViewFormConstrains.constant = self.signupFormHeight;
        
        [self.signUpView setFrame:CGRectMake(self.signUpView.frame.origin.x,
                                             self.signUpView.frame.origin.y,
                                             self.signUpView.frame.size.width,
                                             26.0f + self.signupFormHeight + 6.0f)];
        self.signUpViewConstrains.constant = 26.0f + self.signupFormHeight + 6.0f;
    } completion:^(BOOL finished) {
        [self.signUpFormView setHidden:NO];
    }];
}

- (void) hideSignup
{
    [self.signUpFormView setHidden:YES];
    [self.signUpFormView setFrame:CGRectMake(self.signUpFormView.frame.origin.x,
                                             self.signUpFormView.frame.origin.y,
                                             self.signUpFormView.frame.size.width,
                                             0.0f)];
    self.signUpViewFormConstrains.constant = 0.0f;
    
    [self.signUpView setFrame:CGRectMake(self.signUpView.frame.origin.x,
                                         self.signUpView.frame.origin.y,
                                         self.signUpView.frame.size.width,
                                         25.0f)];
    self.signUpViewConstrains.constant = 25.0f;
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
