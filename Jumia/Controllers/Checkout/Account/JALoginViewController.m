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
#import "JAUtils.h"
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

@property (assign, nonatomic) BOOL loadFailed;
@property (assign, nonatomic) BOOL hasNoConnection;

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
    
    self.screenName = @"CheckoutStart";
    
    self.navBarLayout.title = STRING_CHECKOUT;
    
    self.navBarLayout.showCartButton = NO;
    
    self.hasNoConnection = NO;

    [self setupViews];
    
    [self showLoading];
 
    [self getForms];
}

- (void)getForms
{
    self.loadFailed = NO; //resetting to NO, it is turned to YES if it fails
    
    self.numberOfFormsToLoad = 2;
    [RIForm getForm:@"login"
       successBlock:^(RIForm *form) {
           
           self.loginDynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:7.0f];
           self.loginFormHeight = 0.0f;

           for(UIView *view in self.loginDynamicForm.formViews)
           {
               [self.loginFormView addSubview:view];
               if(CGRectGetMaxY(view.frame) > self.loginFormHeight)
               {
                   self.loginFormHeight = CGRectGetMaxY(view.frame);
               }
           }
           
           self.numberOfFormsToLoad--;
           
       } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
           if(RIApiResponseNoInternetConnection == apiResponse)
           {
               self.hasNoConnection = YES;
           }
           
           self.loadFailed = YES;
           self.numberOfFormsToLoad--;
       }];
    
    [RIForm getForm:@"registersignup"
       successBlock:^(RIForm *form) {
           
           self.signupDynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:7.0f];
           self.signupFormHeight = 0.0f;

           for(UIView *view in self.signupDynamicForm.formViews)
           {
               [self.signUpFormView addSubview:view];
               if(CGRectGetMaxY(view.frame) > self.signupFormHeight)
               {
                   self.signupFormHeight = CGRectGetMaxY(view.frame);
               }
           }
           
           self.numberOfFormsToLoad--;
           
       } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
           if(RIApiResponseNoInternetConnection == apiResponse)
           {
               self.hasNoConnection = YES;
           }
           
           self.loadFailed = YES;
           self.numberOfFormsToLoad--;
       }];
}

- (void) setupViews
{
    self.isAnimationRunning = NO;
    
    CGFloat availableWidth = self.stepView.frame.size.width;
    
    [self.stepLabel setText:STRING_CHECKOUT_ABOUT_YOU];
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
    [self.loginLabel setText:STRING_LOGIN];
    [self.loginSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    
    self.signUpView.layer.cornerRadius = 5.0f;
    UITapGestureRecognizer *showSignupViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(showSignup)];
    [self.signUpView addGestureRecognizer:showSignupViewTap];
    [self.signUpLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.signUpLabel setText:STRING_SIGNUP];
    [self.signUpSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
}

- (void) finishedFormsLoading
{
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
    
    if(!self.loadFailed)
    {
        [self finishingSetupViews];
        
        [self showLogin];
    }
    else
    {
        [self showErrorView:self.hasNoConnection startingY:0.0f selector:@selector(getForms) objects:nil];
    }
    
    [self hideLoading];
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
    [self.loginButton setTitle:STRING_LOGIN forState:UIControlStateNormal];
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
    [self.forgotButton setTitle:STRING_FORGOT_PASSWORD forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.forgotButton addTarget:self action:@selector(forgotButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.loginFormView addSubview:self.forgotButton];
    self.loginFormHeight += self.forgotButton.frame.size.height;
    
    // Separator
    self.facebookLoginSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.facebookLoginSeparatorLabel = [[UILabel alloc] init];
    [self.facebookLoginSeparatorLabel setText:STRING_OR];
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
    [self.facebookLoginLabel setText:STRING_LOGIN_WITH_FACEBOOK];
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
    [self.signUpButton setTitle:STRING_SIGNUP forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(signUpButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.signUpFormView addSubview:self.signUpButton];
    self.signupFormHeight += self.signUpButton.frame.size.height;
    
    self.signupFormHeight += 12.0f;
    // Separator
    self.facebookSignupSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.facebookSignupSeparatorLabel = [[UILabel alloc] init];
    [self.facebookSignupSeparatorLabel setText:STRING_OR];
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
    [self.facebookSingupLabel setText:STRING_SIGNUP_WITH_FACEBOOK];
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
        
        RICustomer *customerObject = ((RICustomer *)object);
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:customerObject.idCustomer forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"LoginSuccess" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
        [trackingDictionary setValue:customerObject.idCustomer forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:customerObject.firstName forKey:kRIEventUserFirstNameKey];
        [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
        [trackingDictionary setValue:@"Checkout" forKey:kRIEventLocationKey];
        [trackingDictionary setValue:customerObject.gender forKey:kRIEventGenderKey];
        [trackingDictionary setValue:customerObject.createdAt forKey:kRIEventAccountDateKey];
        
        NSDate* now = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *dateOfBirth = [dateFormatter dateFromString:customerObject.birthday];
        NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:dateOfBirth toDate:now options:0];
        [trackingDictionary setValue:[NSNumber numberWithInt:[ageComponents year]] forKey:kRIEventAgeKey];

        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLoginSuccess]
                                                  data:[trackingDictionary copy]];
        
        trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"CheckoutAboutYou" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutAboutYou]
                                                  data:[trackingDictionary copy]];
        
        [self.loginDynamicForm resetValues];
        
        [self hideLoading];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                            object:nil];
        
        if([RICustomer checkIfUserHasAddresses])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                                object:nil
                                                              userInfo:nil];
        }
        else
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button"]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                                object:nil
                                                              userInfo:userInfo];
        }
        
    } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject) {
        [self hideLoading];
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:@"LoginFailed" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
        [trackingDictionary setValue:@"Checkout" forKey:kRIEventLocationKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLoginFail]
                                                  data:[trackingDictionary copy]];
        
        
        if(VALID_NOTEMPTY(errorObject, NSDictionary))
        {
            [self.loginDynamicForm validateFields:errorObject];
            
            [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
        }
        else if(VALID_NOTEMPTY(errorObject, NSArray))
        {
            [self.loginDynamicForm checkErrors];
            
            [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
        }
        else
        {
            [self.loginDynamicForm checkErrors];
            
            [self showMessage:STRING_ERROR success:NO];
        }
    }];
}

-(void)forgotButtonPressed
{
    [self.loginDynamicForm resignResponder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutForgotPasswordScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

-(void)signUpButtonPressed
{
    [self.signupDynamicForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.signupDynamicForm form] parameters:[self.signupDynamicForm getValues] successBlock:^(id object) {
        [self.signupDynamicForm resetValues];
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:@"Checkout" forKey:kRIEventLocationKey];
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSignupSuccess]
                                                  data:trackingDictionary];
        
        [self hideLoading];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                            object:nil];
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button"]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                            object:nil
                                                          userInfo:userInfo];
    } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject) {
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:@"Checkout" forKey:kRIEventLocationKey];
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSignupFail]
                                                  data:trackingDictionary];

        [self hideLoading];
        
        if(VALID_NOTEMPTY(errorObject, NSDictionary))
        {
            [self.signupDynamicForm validateFields:errorObject];
            
            [self showMessage:STRING_ERROR_INVALID_FIELDS success:NO];
        }
        else if(VALID_NOTEMPTY(errorObject, NSArray))
        {
            [self.signupDynamicForm checkErrors];
            
            [self showMessage:[errorObject componentsJoinedByString:@","] success:NO];
        }
        else
        {
            [self.signupDynamicForm checkErrors];
            
            [self showMessage:STRING_ERROR success:NO];
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
                                                 
                                                 RICustomer *customerObject = ((RICustomer *)customer);
                                                 
                                                 NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                                 [trackingDictionary setValue:customerObject.idCustomer forKey:kRIEventLabelKey];
                                                 [trackingDictionary setValue:@"FacebookLoginSuccess" forKey:kRIEventActionKey];
                                                 [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
                                                 [trackingDictionary setValue:customerObject.idCustomer forKey:kRIEventUserIdKey];
                                                 [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                                                 [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                                                 [trackingDictionary setValue:customerObject.gender forKey:kRIEventGenderKey];
                                                 [trackingDictionary setValue:customerObject.createdAt forKey:kRIEventAccountDateKey];
                                                 
                                                 NSDate* now = [NSDate date];
                                                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                 [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                                 NSDate *dateOfBirth = [dateFormatter dateFromString:customerObject.birthday];
                                                 NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:dateOfBirth toDate:now options:0];
                                                 [trackingDictionary setValue:[NSNumber numberWithInt:[ageComponents year]] forKey:kRIEventAgeKey];
                                                 [trackingDictionary setValue:@"Checkou" forKey:kRIEventLocationKey];
                                                 NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                                 [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                                                 
                                                 [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookLoginSuccess]
                                                                                           data:[trackingDictionary copy]];

                                                 trackingDictionary = [[NSMutableDictionary alloc] init];
                                                 [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
                                                 [trackingDictionary setValue:@"CheckoutAboutYou" forKey:kRIEventActionKey];
                                                 [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
                                                 [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutAboutYou]
                                                                                           data:[trackingDictionary copy]];
                                                 
                                                 [self.loginDynamicForm resetValues];
                                                 
                                                 [self hideLoading];
                                                 
                                                 if([RICustomer checkIfUserHasAddresses])
                                                 {
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                                                                         object:nil
                                                                                                       userInfo:nil];
                                                 }
                                                 else
                                                 {
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                                                         object:nil];
                                                     
                                                     NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button"]];
                                                     
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                                                                         object:nil
                                                                                                       userInfo:userInfo];
                                                 }
                                             } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorObject) {
                                                 [self hideLoading];
                                                 
                                                 NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                                 [trackingDictionary setValue:@"LoginFailed" forKey:kRIEventActionKey];
                                                 [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
                                                 [trackingDictionary setValue:@"Checkout" forKey:kRIEventLocationKey];
                                                 
                                                 [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookLoginFail]
                                                                                           data:[trackingDictionary copy]];
                                                 
                                                 [self showMessage:STRING_ERROR success:NO];
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
         [self showMessage:alertMessage success:NO];
    }
}

@end
