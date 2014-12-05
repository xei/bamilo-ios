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
FBLoginViewDelegate
>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (nonatomic, strong) UIView *loginView;
@property (nonatomic, strong) UILabel *loginLabel;
@property (nonatomic, strong) UIView *loginSeparator;
@property (weak, nonatomic) UIButton *loginButton;
@property (weak, nonatomic) UIButton *signUpButton;
@property (weak, nonatomic) UIButton *forgotPasswordButton;
@property (strong, nonatomic) UIButton *facebookLoginButton;
@property (strong, nonatomic) UILabel *facebookLoginLabel;
@property (assign, nonatomic) CGFloat loginViewCurrentY;
@property (assign, nonatomic) BOOL requestDone;

@end

@implementation JASignInViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboard)
                                                 name:kOpenMenuNotification
                                               object:nil];
    
    self.screenName = @"Login";
    
    self.A4SViewControllerAlias = @"ACCOUNT";
    
    self.navBarLayout.title = STRING_LOGIN;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.clipsToBounds = YES;
    [self.view addSubview:self.scrollView];
    
    self.loginView = [[UIView alloc] initWithFrame:CGRectZero];
    self.loginView.layer.cornerRadius = 5.0f;
    self.loginView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.loginView];

    self.loginLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.loginLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
    [self.loginLabel setText:STRING_CREDENTIALS];
    [self.loginLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.loginView addSubview:self.loginLabel];
    
    self.loginSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    [self.loginSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.loginView addSubview:self.loginSeparator];
    
    self.facebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookLoginButton setFrame:CGRectZero];
    [self.facebookLoginButton setTitle:STRING_LOGIN_WITH_FACEBOOK forState:UIControlStateNormal];
    [self.facebookLoginButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.facebookLoginButton addTarget:self action:@selector(facebookLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookLoginButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.loginView addSubview:self.facebookLoginButton];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setFrame:CGRectZero];
    [self.loginButton setTitle:STRING_LOGIN forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.loginView addSubview:self.loginButton];

    self.forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotPasswordButton setFrame:CGRectZero];
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
    [self.signUpButton setFrame:CGRectZero];
    [self.signUpButton setTitle:STRING_CREATE_ACCOUNT forState:UIControlStateNormal];
    [self.signUpButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.signUpButton addTarget:self action:@selector(signUpButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.loginView addSubview:self.signUpButton];
    
    [self showLoading];
    
    [self getLoginForm];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.requestDone)
    {
        [self setupViews:self.view.frame.size.width height:self.view.frame.size.height toInterfaceOrientation:self.interfaceOrientation];
        
        [self hideLoading];
    }
}

- (void) hideKeyboard
{
    [self.dynamicForm resignResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getLoginForm
{
    self.requestDone = NO;
    
    [RIForm getForm:@"login"
       successBlock:^(RIForm *form)
     {
         self.dynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:0.0f];
         [self.dynamicForm setDelegate:self];
         
         for(UIView *view in self.dynamicForm.formViews)
         {
             [self.loginView addSubview:view];
         }
         
         [self setupViews:self.view.frame.size.width height:self.view.frame.size.height toInterfaceOrientation:self.interfaceOrientation];
         
         [self.scrollView setHidden:NO];
         self.requestDone = YES;
         
         [self hideLoading];
     } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
     {
         self.requestDone = YES;
         if(RIApiResponseMaintenancePage == apiResponse)
         {
             [self showMaintenancePage:@selector(getLoginForm) objects:nil];
         }
         else
         {
             BOOL noConnection = NO;
             if (RIApiResponseNoInternetConnection == apiResponse)
             {
                 noConnection = YES;
             }
             [self.scrollView setHidden:YES];
             [self showErrorView:noConnection startingY:0.0f selector:@selector(getLoginForm) objects:nil];
         }
         
         [self hideLoading];
     }];
}

#pragma mark - Action

- (void)setupViews:(CGFloat)width height:(CGFloat)height toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat horizontalMargin = 6.0f;
    CGFloat verticalMargin = 6.0f;
    
    [self.scrollView setFrame:CGRectMake(0.0f,
                                         0.0f,
                                         width,
                                         height)];
    
    [self.loginView setFrame:CGRectMake(horizontalMargin,
                                        verticalMargin,
                                        self.scrollView.frame.size.width - (2 * horizontalMargin),
                                        340.0f)];
    
    [self.loginLabel setFrame:CGRectMake(horizontalMargin,
                                         2.0f,
                                         self.loginView.frame.size.width - (2 * horizontalMargin),
                                         21.0f)];
    
    [self.loginSeparator setFrame:CGRectMake(0.0f,
                                                                   26.0f,
                                                                   self.scrollView.frame.size.width - (2 * horizontalMargin),
                                             1.0f)];
    
    NSString *facebookImageNameFormatter = @"facebookMedium_%@";
    NSString *loginImageNameFormatter = @"orangeMedium_%@";
    NSString *signupImageNameFormatter = @"greyMedium_%@";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        facebookImageNameFormatter = @"facebookMediumPortrait_%@";
        loginImageNameFormatter = @"orangeMediumPortrait_%@";
        signupImageNameFormatter = @"greyMediumPortrait_%@";
        
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            facebookImageNameFormatter = @"facebookFullPortrait_%@";
            loginImageNameFormatter = @"orangeFullPortrait_%@";
            signupImageNameFormatter = @"greyFullPortrait_%@";
        }
    }
    
    UIImage *facebookNormalImage = [UIImage imageNamed:[NSString stringWithFormat:facebookImageNameFormatter, @"normal"]];
    [self.facebookLoginButton setFrame:CGRectMake((self.loginView.frame.size.width - facebookNormalImage.size.width) / 2,
                                                  42.0f,
                                                  facebookNormalImage.size.width,
                                                  facebookNormalImage.size.height)];
    [self.facebookLoginButton setBackgroundImage:facebookNormalImage forState:UIControlStateNormal];
    [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:facebookImageNameFormatter, @"highlighted"]] forState:UIControlStateHighlighted];
    [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:facebookImageNameFormatter, @"highlighted"]] forState:UIControlStateSelected];
    
    self.loginViewCurrentY = CGRectGetMaxY(self.facebookLoginButton.frame) + 6.0f;
    
    for(UIView *view in self.dynamicForm.formViews)
    {
        CGRect dynamicFormFieldViewFrame = view.frame;
        dynamicFormFieldViewFrame.origin.x = self.facebookLoginButton.frame.origin.x;
        dynamicFormFieldViewFrame.origin.y = self.loginViewCurrentY;
        dynamicFormFieldViewFrame.size.width = self.facebookLoginButton.frame.size.width;
        ;
        view.frame = dynamicFormFieldViewFrame;
        self.loginViewCurrentY = CGRectGetMaxY(view.frame);
    }
    
    self.loginViewCurrentY += 15.0f;
    UIImage *loginNormalImage = [UIImage imageNamed:[NSString stringWithFormat:loginImageNameFormatter, @"normal"]];
    [self.loginButton setFrame:CGRectMake((self.loginView.frame.size.width - loginNormalImage.size.width) / 2,
                                          self.loginViewCurrentY,
                                          loginNormalImage.size.width,
                                          loginNormalImage.size.height)];
    [self.loginButton setBackgroundImage:loginNormalImage forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:loginImageNameFormatter, @"highlighted"]] forState:UIControlStateHighlighted];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:loginImageNameFormatter, @"highlighted"]] forState:UIControlStateSelected];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:loginImageNameFormatter, @"disabled"]] forState:UIControlStateDisabled];
    
    self.loginViewCurrentY = CGRectGetMaxY(self.loginButton.frame) + 5.0f;
    // Forgot Password
    [self.forgotPasswordButton setFrame:CGRectMake((self.loginView.frame.size.width - loginNormalImage.size.width) / 2,
                                                   self.loginViewCurrentY,
                                                   loginNormalImage.size.width,
                                                   30.0f)];
    
    self.loginViewCurrentY = CGRectGetMaxY(self.forgotPasswordButton.frame) + 6.0f;
    
    UIImage *singupNormalImage = [UIImage imageNamed:[NSString stringWithFormat:signupImageNameFormatter, @"normal"]];
    [self.signUpButton setFrame:CGRectMake((self.loginView.frame.size.width - singupNormalImage.size.width) / 2,
                                           self.loginViewCurrentY,
                                           singupNormalImage.size.width,
                                           singupNormalImage.size.height)];
    [self.signUpButton setBackgroundImage:singupNormalImage forState:UIControlStateNormal];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:signupImageNameFormatter, @"highlighted"]] forState:UIControlStateHighlighted];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:signupImageNameFormatter, @"highlighted"]] forState:UIControlStateSelected];
    [self.signUpButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:signupImageNameFormatter, @"disabled"]] forState:UIControlStateDisabled];
    
    [self.loginView setFrame:CGRectMake(self.loginView.frame.origin.x,
                                        self.loginView.frame.origin.y,
                                        self.loginView.frame.size.width,
                                        CGRectGetMaxY(self.signUpButton.frame) + 10.0f)];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width,
                                               self.loginView.frame.size.height + (2 * verticalMargin))];
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
    
    // notify the InAppNotification SDK that this the active view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}


- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    CGFloat newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    CGFloat newHeight = self.view.frame.size.width + self.view.frame.origin.x;
    
    [self setupViews:newWidth height:newHeight toInterfaceOrientation:toInterfaceOrientation];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupViews:self.view.frame.size.width height:self.view.frame.size.height toInterfaceOrientation:self.interfaceOrientation];
    
    [self hideLoading];
    
    [self hideKeyboard];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)facebookLoginButtonPressed:(id)sender
{
    [self hideKeyboard];
    
    FBSession *session = [[FBSession alloc] initWithPermissions:@[@"public_profile", @"email", @"user_birthday"]];
    [FBSession setActiveSession:session];
    
    [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error)
     {
         if(FBSessionStateOpen == status)
         {
             [self getFacebookUserInfo];
         }
     }];
}

- (void) getFacebookUserInfo
{
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id<FBGraphUser> user, NSError *error)
     {
         if (!error)
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
                                                      successBlock:^(RICustomer* customer, NSString* nextStep) {
                                                          
                                                          NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                                          [trackingDictionary setValue:customer.idCustomer forKey:kRIEventLabelKey];
                                                          [trackingDictionary setValue:@"FacebookLoginSuccess" forKey:kRIEventActionKey];
                                                          [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
                                                          [trackingDictionary setValue:customer.idCustomer forKey:kRIEventUserIdKey];
                                                          [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                                                          [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                                                          [trackingDictionary setValue:customer.gender forKey:kRIEventGenderKey];
                                                          [trackingDictionary setValue:customer.createdAt forKey:kRIEventAccountDateKey];
                                                          
                                                          NSDate* now = [NSDate date];
                                                          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                          [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                                          NSDate *dateOfBirth = [dateFormatter dateFromString:customer.birthday];
                                                          NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:dateOfBirth toDate:now options:0];
                                                          [trackingDictionary setValue:[NSNumber numberWithInt:[ageComponents year]] forKey:kRIEventAgeKey];
                                                          
                                                          
                                                          NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                                          [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                                                          if(self.fromSideMenu)
                                                          {
                                                              [trackingDictionary setValue:@"Side menu" forKey:kRIEventLocationKey];
                                                          }
                                                          else
                                                          {
                                                              [trackingDictionary setValue:@"My account" forKey:kRIEventLocationKey];
                                                          }
                                                          
                                                          [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookLoginSuccess]
                                                                                                    data:[trackingDictionary copy]];
                                                          
                                                          [self.dynamicForm resetValues];
                                                          
                                                          [self hideLoading];
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                                                                              object:nil];
                                                          
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                                                              object:nil];
                                                          
                                                          if(VALID_NOTEMPTY(self.nextNotification, NSNotification))
                                                          {
                                                              [self.navigationController popViewControllerAnimated:NO];
                                                              
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:self.nextNotification.name
                                                                                                                  object:self.nextNotification.object
                                                                                                                userInfo:self.nextNotification.userInfo];
                                                          }
                                                          else
                                                          {
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
                                                          }
                                                          
                                                      } andFailureBlock:^(RIApiResponse apiResponse,  NSArray *errorObject) {
                                                          
                                                          NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                                          [trackingDictionary setValue:@"LoginFailed" forKey:kRIEventActionKey];
                                                          [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
                                                          if(self.fromSideMenu)
                                                          {
                                                              [trackingDictionary setValue:@"Side menu" forKey:kRIEventLocationKey];
                                                          }
                                                          else
                                                          {
                                                              [trackingDictionary setValue:@"My account" forKey:kRIEventLocationKey];
                                                          }
                                                          
                                                          [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookLoginFail]
                                                                                                    data:[trackingDictionary copy]];
                                                          
                                                          [self hideLoading];
                                                          
                                                          [self showMessage:STRING_ERROR success:NO];
                                                      }];
             }
             else
             {
                 [self showMessage:[error description] success:NO];
             }
         }
     }];
}

- (void)signUpButtonPressed:(id)sender
{
    [self hideKeyboard];
    
    NSMutableDictionary *userInfo = nil;
    
    if(VALID_NOTEMPTY(self.nextNotification, NSNotification))
    {
        userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:self.nextNotification forKey:@"notification"];
        [userInfo setObject:[NSNumber numberWithBool:self.fromSideMenu] forKey:@"from_side_menu"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignUpScreenNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)forgotPasswordButtonPressed:(id)sender
{
    [self hideKeyboard];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowForgotPasswordScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

- (void)loginButtonPressed:(id)sender
{
    [self hideKeyboard];
    
    [self continueLogin];
}

- (void)continueLogin
{
    [self hideKeyboard];
    
    [self showLoading];
    
    [RIForm sendForm:[self.dynamicForm form]
          parameters:[self.dynamicForm getValues]
        successBlock:^(id object)
     {
         [self.dynamicForm resetValues];
         
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
         if(self.fromSideMenu)
         {
             [trackingDictionary setValue:@"Side menu" forKey:kRIEventLocationKey];
         }
         else
         {
             [trackingDictionary setValue:@"My account" forKey:kRIEventLocationKey];
         }
         
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
         
         [self hideLoading];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                             object:nil];
         
         if(VALID_NOTEMPTY(self.nextNotification, NSNotification))
         {
             [self.navigationController popViewControllerAnimated:NO];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:self.nextNotification.name
                                                                 object:self.nextNotification.object
                                                               userInfo:self.nextNotification.userInfo];
         }
         else
         {
             [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
         }
         
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject) {
         
         NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
         [trackingDictionary setValue:@"LoginFailed" forKey:kRIEventActionKey];
         [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
         if(self.fromSideMenu)
         {
             [trackingDictionary setValue:@"Side menu" forKey:kRIEventLocationKey];
         }
         else
         {
             [trackingDictionary setValue:@"My account" forKey:kRIEventLocationKey];
         }
         
         [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLoginFail]
                                                   data:[trackingDictionary copy]];
         
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
        [self showMessage:alertMessage success:NO];
    }
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    [UIView animateWithDuration:0.5f animations:^{
    }];
}

- (void) lostFocus
{
    [UIView animateWithDuration:0.5f animations:^{
    }];
}

#pragma mark - Keyboard notifications

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = kbSize.height;
    
    if(self.view.frame.size.width == kbSize.height)
    {
        height = kbSize.width;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:CGRectMake(self.view.bounds.origin.x,
                                             self.view.bounds.origin.y,
                                             self.view.bounds.size.width,
                                             self.view.bounds.size.height - height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.scrollView setFrame:self.view.bounds];
    }];
}

@end
