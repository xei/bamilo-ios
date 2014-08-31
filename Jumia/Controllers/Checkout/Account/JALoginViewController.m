//
//  JALoginViewController.m
//  Jumia
//
//  Created by Pedro Lopes on 31/07/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JALoginViewController.h"
#import "RIForm.h"
#import "RIField.h"
#import "RICustomer.h"
#import <FacebookSDK/FacebookSDK.h>

@interface JALoginViewController ()
<
FBLoginViewDelegate
>

@property (assign, nonatomic) BOOL isAnimationRunning;
@property (assign, nonatomic) NSInteger numberOfFormsToLoad;

// Steps
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepIconLeftConstrain;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stepLabelWidthConstrain;

// Login
@property (strong, nonatomic) JADynamicForm *loginDynamicForm;
@property (strong, nonatomic) NSMutableArray *loginFormFieldsArray;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *loginSeparator;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIImageView *loginArrow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginViewConstrains;
@property (weak, nonatomic) IBOutlet UIView *loginFormView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginFormViewConstrains;
@property (assign, nonatomic) CGFloat loginFormHeight;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *forgotButton;
@property (strong, nonatomic) UIView *facebookLoginSeparator;
@property (strong, nonatomic) UIView *facebookLoginSeparatorLeftView;
@property (strong, nonatomic) UILabel *facebookLoginSeparatorLabel;
@property (strong, nonatomic) UIView *facebookLoginSeparatorRightView;
@property (strong, nonatomic) FBLoginView *facebookLoginView;
@property (strong, nonatomic) UILabel *facebookLoginLabel;

// Signup
@property (strong, nonatomic) JADynamicForm *signupDynamicForm;
@property (strong, nonatomic) NSMutableArray *signupFormFieldsArray;
@property (weak, nonatomic) IBOutlet UIView *signUpView;
@property (weak, nonatomic) IBOutlet UIView *signUpSeparator;
@property (weak, nonatomic) IBOutlet UILabel *signUpLabel;
@property (weak, nonatomic) IBOutlet UIImageView *signUpArrow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpViewConstrains;
@property (weak, nonatomic) IBOutlet UIView *signUpFormView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *signUpViewFormConstrains;
@property (assign, nonatomic) CGFloat signupFormHeight;
@property (strong, nonatomic) UIButton *signUpButton;
@property (strong, nonatomic) UIView *facebookSignupSeparator;
@property (strong, nonatomic) UIView *facebookSignupSeparatorLeftView;
@property (strong, nonatomic) UILabel *facebookSignupSeparatorLabel;
@property (strong, nonatomic) UIView *facebookSignupSeparatorRightView;
@property (strong, nonatomic) FBLoginView *facebookSingupView;
@property (strong, nonatomic) UILabel *facebookSingupLabel;

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
    
    self.navBarLayout.title = @"Checkout";
    
    [self setupViews];
    
    [self showLoading];
    
    self.numberOfFormsToLoad = 2;
    [RIForm getForm:@"login"
       successBlock:^(RIForm *form) {
           
           self.loginDynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:7.0f];
           self.loginFormHeight = 0.0f;
           self.loginFormFieldsArray = [self.loginDynamicForm.formViews copy];
           for(UIView *view in self.loginDynamicForm.formViews)
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
           
           self.signupDynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:7.0f];
           self.signupFormHeight = 0.0f;
           self.signupFormFieldsArray = [self.signupDynamicForm.formViews copy];
           for(UIView *view in self.signupDynamicForm.formViews)
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
    self.isAnimationRunning = NO;
    
    CGFloat availableWidth = self.stepView.frame.size.width;
    
    [self.stepLabel setText:@"1. About you"];
    [self.stepLabel sizeToFit];
    
    CGFloat realWidth = self.stepIcon.frame.size.width + 6.0f + self.stepLabel.frame.size.width;
    
    if(availableWidth >= realWidth)
    {
        CGFloat xStepIconValue = (availableWidth - realWidth) / 2;
        self.stepIconLeftConstrain.constant = xStepIconValue;
        self.stepLabelWidthConstrain.constant = self.stepLabel.frame.size.width;
    }
    else
    {
        self.stepLabelWidthConstrain.constant = (availableWidth - self.stepIcon.frame.size.width - 6.0f);
        self.stepIconLeftConstrain.constant = 0.0f;
    }
    
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
    self.loginFormHeight += 15.0f;
    // Login
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setFrame:CGRectMake(6.0f, self.loginFormHeight, 296.0f, 44.0f)];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.loginFormView addSubview:self.loginButton];
    self.loginFormHeight += self.loginButton.frame.size.height;
    
    self.loginFormHeight += 5.0f;
    // Forgot Password
    self.forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotButton setFrame:CGRectMake(6.0f, self.loginFormHeight, 296.0f, 30.0f)];
    [self.forgotButton setBackgroundColor:[UIColor clearColor]];
    [self.forgotButton setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.forgotButton addTarget:self action:@selector(forgotButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.loginFormView addSubview:self.forgotButton];
    self.loginFormHeight += self.forgotButton.frame.size.height;
    
    // Separator
    self.facebookLoginSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.facebookLoginSeparatorLabel = [[UILabel alloc] init];
    [self.facebookLoginSeparatorLabel setText:@"OR"];
    [self.facebookLoginSeparatorLabel setTextColor:UIColorFromRGB(0xcccccc)];
    [self.facebookLoginSeparatorLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.facebookLoginSeparatorLabel sizeToFit];
    
    self.facebookLoginSeparatorLeftView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.facebookLoginSeparatorLeftView setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self.facebookLoginSeparatorLeftView setFrame:CGRectMake(0.0f, (self.facebookLoginSeparatorLabel.frame.size.height - 1.0f) / 2.0f, 121.0f, 1.0f)];
    
    [self.facebookLoginSeparatorLabel setFrame:CGRectMake(CGRectGetMaxX(self.facebookLoginSeparatorLeftView.frame) + 15.0f, 0.0f, self.facebookLoginSeparatorLabel.frame.size.width, self.facebookLoginSeparatorLabel.frame.size.height)];
    
    self.facebookLoginSeparatorRightView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.facebookLoginSeparatorRightView setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self.facebookLoginSeparatorRightView setFrame:CGRectMake(175.0f, (self.facebookLoginSeparatorLabel.frame.size.height - 1.0f) / 2.0f, 121.0f, 1.0f)];
    
    [self.facebookLoginSeparator addSubview:self.facebookLoginSeparatorLeftView];
    [self.facebookLoginSeparator addSubview:self.facebookLoginSeparatorLabel];
    [self.facebookLoginSeparator addSubview:self.facebookLoginSeparatorRightView];
    
    [self.facebookLoginSeparator setFrame:CGRectMake(6.0f, self.loginFormHeight, 296.0f, self.facebookLoginSeparatorLabel.frame.size.height)];
    [self.loginFormView addSubview:self.facebookLoginSeparator];
    self.loginFormHeight += self.facebookLoginSeparator.frame.size.height;
    
    self.loginFormHeight += 11.0f;
    // Facebook Login
    self.facebookLoginView = [[FBLoginView alloc] init];
    self.facebookLoginView.delegate = self;
    self.facebookLoginView.readPermissions = @[@"public_profile", @"email", @"user_birthday"];
    [self.facebookLoginView setFrame:CGRectMake(6.0f, self.loginFormHeight, 296.0f, 44.0f)];
    
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
    [self.loginFormView addSubview:self.facebookLoginView];
    self.loginFormHeight += self.facebookLoginView.frame.size.height;
    
    self.signupFormHeight += 15.0f;
    // Signup
    self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.signUpButton setFrame:CGRectMake(6.0f, self.signupFormHeight, 296.0f, 44.0f)];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [self.signUpButton setTitle:@"Signup" forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(signUpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.signUpFormView addSubview:self.signUpButton];
    self.signupFormHeight += self.signUpButton.frame.size.height;
    
    self.signupFormHeight += 12.0f;
    // Separator
    self.facebookSignupSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.facebookSignupSeparatorLabel = [[UILabel alloc] init];
    [self.facebookSignupSeparatorLabel setText:@"OR"];
    [self.facebookSignupSeparatorLabel setTextColor:UIColorFromRGB(0xcccccc)];
    [self.facebookSignupSeparatorLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.facebookSignupSeparatorLabel sizeToFit];
    
    self.facebookSignupSeparatorLeftView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.facebookSignupSeparatorLeftView setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self.facebookSignupSeparatorLeftView setFrame:CGRectMake(0.0f, (self.facebookSignupSeparatorLabel.frame.size.height - 1.0f) / 2.0f, 121.0f, 1.0f)];
    
    [self.facebookSignupSeparatorLabel setFrame:CGRectMake(CGRectGetMaxX(self.facebookSignupSeparatorLeftView.frame) + 15.0f, 0.0f, self.facebookSignupSeparatorLabel.frame.size.width, self.facebookSignupSeparatorLabel.frame.size.height)];
    
    self.facebookSignupSeparatorRightView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.facebookSignupSeparatorRightView setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self.facebookSignupSeparatorRightView setFrame:CGRectMake(175.0f, (self.facebookSignupSeparatorLabel.frame.size.height - 1.0f) / 2.0f, 121.0f, 1.0f)];
    
    [self.facebookSignupSeparator addSubview:self.facebookSignupSeparatorLeftView];
    [self.facebookSignupSeparator addSubview:self.facebookSignupSeparatorLabel];
    [self.facebookSignupSeparator addSubview:self.facebookSignupSeparatorRightView];
    
    [self.facebookSignupSeparator setFrame:CGRectMake(6.0f, self.signupFormHeight, 296.0f, self.facebookSignupSeparatorLabel.frame.size.height)];
    [self.signUpFormView addSubview:self.facebookSignupSeparator];
    self.signupFormHeight += self.facebookSignupSeparator.frame.size.height;
    
    self.signupFormHeight += 11.0f;
    // Facebook Signup
    self.facebookSingupView = [[FBLoginView alloc] init];
    self.facebookSingupView.delegate = self;
    self.facebookSingupView.readPermissions = @[@"public_profile", @"email", @"user_birthday"];
    [self.facebookSingupView setFrame:CGRectMake(6.0f, self.signupFormHeight, 296.0f, 44.0f)];
    
    for (id obj in self.facebookSingupView.subviews)
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
    
    self.facebookSingupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 296.0f, 44.0f)];
    [self.facebookSingupLabel setText:@"Signup with Facebook"];
    [self.facebookSingupLabel setTextColor:UIColorFromRGB(0xffffff)];
    [self.facebookSingupLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.facebookSingupLabel setTextAlignment:NSTextAlignmentCenter];
    
    [self.facebookSingupView addSubview:self.facebookSingupLabel];
    [self.signUpFormView addSubview:self.facebookSingupView];
    self.signupFormHeight += self.facebookSingupView.frame.size.height;
}

- (void) showLogin
{
    if(!self.isAnimationRunning)
    {
        self.isAnimationRunning = YES;
        [self hideSignup];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.loginFormViewConstrains.constant = self.loginFormHeight;
            [self.loginFormView setFrame:CGRectMake(self.loginFormView.frame.origin.x,
                                                    self.loginFormView.frame.origin.y,
                                                    self.loginFormView.frame.size.width,
                                                    self.loginFormHeight)];
            
            self.loginViewConstrains.constant = 26.0f + self.loginFormHeight + 6.0f;
            [self.loginView setFrame:CGRectMake(self.loginView.frame.origin.x,
                                                27.0f,
                                                self.loginView.frame.size.width,
                                                26.0f + self.loginFormHeight + 6.0f)];
        } completion:^(BOOL finished) {
            [self.loginArrow setImage:[UIImage imageNamed:@"arrowOrangeOpened"]];
            [self.loginFormView setHidden:NO];
            self.isAnimationRunning = NO;
        }];
    }
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
                                        27.0f,
                                        self.loginView.frame.size.width,
                                        25.0f)];
    
    [self.loginArrow setImage:[UIImage imageNamed:@"arrowOrangeClosed"]];
}

- (void) showSignup
{
    if(!self.isAnimationRunning)
    {
        self.isAnimationRunning = YES;
        
        [self hideLogin];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            self.signUpViewFormConstrains.constant = self.signupFormHeight;
            [self.signUpFormView setFrame:CGRectMake(self.signUpFormView.frame.origin.x,
                                                     self.signUpFormView.frame.origin.y,
                                                     self.signUpFormView.frame.size.width,
                                                     self.signupFormHeight)];
            
            self.signUpViewConstrains.constant = 26.0f + self.signupFormHeight + 6.0f;
            [self.signUpView setFrame:CGRectMake(self.signUpView.frame.origin.x,
                                                 58.0f,
                                                 self.signUpView.frame.size.width,
                                                 26.0f + self.signupFormHeight + 6.0f)];
        } completion:^(BOOL finished) {
            [self.signUpArrow setImage:[UIImage imageNamed:@"arrowOrangeOpened"]];
            [self.signUpFormView setHidden:NO];
            self.isAnimationRunning = NO;
        }];
    }
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
                                         53.0f + self.loginFormHeight + 12.0f,
                                         self.signUpView.frame.size.width,
                                         25.0f)];
    
    [self.signUpArrow setImage:[UIImage imageNamed:@"arrowOrangeClosed"]];
}

-(void)loginButtonPressed
{
    [self.loginDynamicForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.loginDynamicForm form] parameters:[self.loginDynamicForm getValues] successBlock:^(id object) {
        [self.loginDynamicForm resetValues];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                            object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                            object:nil
                                                          userInfo:nil];
        [self hideLoading];
        
    } andFailureBlock:^(id errorObject) {
        [self hideLoading];
        
        if(VALID_NOTEMPTY(errorObject, NSDictionary))
        {
            [self.loginDynamicForm validateFields:errorObject];
        }
        else if(VALID_NOTEMPTY(errorObject, NSArray))
        {
            [self.loginDynamicForm checkErrors];
            [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                        message:[errorObject componentsJoinedByString:@","]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                        message:@"Generic error"
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }
    }];
}

-(void)forgotButtonPressed
{
    [self.loginDynamicForm resignResponder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowForgotPasswordScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

-(void)signUpButtonPressed
{
    [self.signupDynamicForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.signupDynamicForm form] parameters:[self.signupDynamicForm getValues] successBlock:^(id object) {
        [self.signupDynamicForm resetValues];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                            object:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                            object:nil
                                                          userInfo:nil];
        
        [self hideLoading];
        
    } andFailureBlock:^(id errorObject) {
        [self hideLoading];
        
        if(VALID_NOTEMPTY(errorObject, NSDictionary))
        {
            [self.signupDynamicForm validateFields:errorObject];
        }
        else if(VALID_NOTEMPTY(errorObject, NSArray))
        {
            [self.signupDynamicForm checkErrors];
            [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                        message:[errorObject componentsJoinedByString:@","]
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Jumia"
                                        message:@"Generic error"
                                       delegate:nil
                              cancelButtonTitle:nil
                              otherButtonTitles:@"OK", nil] show];
        }
    }];
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
                                                 
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                                                     object:nil];
                                                 
                                                 [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                                                                     object:nil
                                                                                                   userInfo:nil];
                                                 [self hideLoading];
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

@end
