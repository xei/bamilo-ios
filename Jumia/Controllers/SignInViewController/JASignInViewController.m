//
//  JASignInViewController.m
//  Jumia
//
//  Created by lucianoduarte on 01/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JASignInViewController.h"
#import "RIForm.h"
#import "RIField.h"
#import "RICustomer.h"
#import "JAUtils.h"
#import "JABottomBar.h"
#import "JAAuthenticationViewController.h"

#define kSideMargin 16
#define kTopMargin 36
#define kSubTitleMargin 6
#define kBeforeDynamicFormMargin 4
#define kDynamicFormMargin 28
#define kForgotPasswordMargin 16
#define kLoginButtonMargin 48

#define kIPadWidth 288

@interface JASignInViewController() <JADynamicFormDelegate>
{
    CGFloat _elementsWidth;
}

@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subTitleLabel;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (strong, nonatomic) UIButton *forgotPasswordButton;
@property (strong, nonatomic) JABottomBar *loginButton;
@property (assign, nonatomic) BOOL requestDone;
@property (assign, nonatomic) RIApiResponse apiResponse;
@property (assign, nonatomic) CGFloat contentScrollOriginalHeight;

@end

@implementation JASignInViewController

- (UIScrollView *)mainScrollView
{
    if (!VALID_NOTEMPTY(_mainScrollView, UIScrollView)) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.viewBounds];
    }
    return _mainScrollView;
}

- (UILabel *)titleLabel
{
    if (!VALID_NOTEMPTY(_titleLabel, UILabel)) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                kSideMargin,
                                                                kTopMargin,
                                                                _elementsWidth,
                                                                60)];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setNumberOfLines:0];
        [_titleLabel setFont:JADisplay2Font];
        [_titleLabel setTextColor:JABlackColor];
        [_titleLabel setText:STRING_LOGIN_WELCOME_BACK];
        [_titleLabel sizeToFit];
        [_titleLabel setWidth:_elementsWidth];
    }
    return _titleLabel;
}

- (UILabel *)subTitleLabel
{
    if (!VALID_NOTEMPTY(_subTitleLabel, UILabel)) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                   kSideMargin,
                                                                   CGRectGetMaxY(self.titleLabel.frame) + kSubTitleMargin,
                                                                   _elementsWidth,
                                                                   60)];
        [_subTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_subTitleLabel setNumberOfLines:0];
        [_subTitleLabel setFont:JACaptionFont];
        [_subTitleLabel setTextColor:JABlack800Color];
        [_subTitleLabel setText:STRING_LOGIN_ENTER_PASSWORD_TO_CONTINUE];
        [_subTitleLabel sizeToFit];
        [_subTitleLabel setWidth:_elementsWidth];
    }
    return _subTitleLabel;
}

- (UIButton *)forgotPasswordButton
{
    if (!VALID_NOTEMPTY(_forgotPasswordButton, UIButton)) {
        _forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgotPasswordButton setFrame:CGRectMake(
                                                   self.mainScrollView.width - self.forgotPasswordButton.width - kSideMargin,
                                                   CGRectGetMaxY(self.subTitleLabel.frame) + kForgotPasswordMargin,
                                                   _elementsWidth,
                                                   _forgotPasswordButton.height)];
        [_forgotPasswordButton.titleLabel setFont:JACaptionFont];
        [_forgotPasswordButton setTitle:STRING_FORGOT_YOUR_PASSWORD forState:UIControlStateNormal];
        [_forgotPasswordButton setTitleColor:JABlue1Color forState:UIControlStateNormal];
        /*[self.forgotPasswordButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
         [self.forgotPasswordButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateSelected];*/
        [_forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_forgotPasswordButton sizeToFit];
        [_forgotPasswordButton setX:self.mainScrollView.width - self.forgotPasswordButton.width - kSideMargin];
    }
    return _forgotPasswordButton;
}

- (JABottomBar *)loginButton
{
    if (!VALID_NOTEMPTY(_loginButton, JABottomBar)) {
        _loginButton = [[JABottomBar alloc] initWithFrame:CGRectMake(
                                                                     kSideMargin,
                                                                     CGRectGetMaxY(self.forgotPasswordButton.frame) + kLoginButtonMargin,
                                                                     _elementsWidth,
                                                                     kBottomDefaultHeight)];
        [_loginButton addButton:[@"Continue" uppercaseString] target:self action:@selector(loginButtonPressed:)];
    }
    return _loginButton;
}

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
    
    self.apiResponse = RIApiResponseSuccess;
    
    self.screenName = @"Login";
    self.A4SViewControllerAlias = @"ACCOUNT";
    
    self.navBarLayout.title = STRING_LOGIN;
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showCartButton = YES;
    self.navBarLayout.showSearchButton = YES;
    
    _elementsWidth = self.viewBounds.size.width - (kSideMargin * 2);
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.titleLabel];
    [self.mainScrollView addSubview:self.subTitleLabel];
    [self.mainScrollView addSubview:self.forgotPasswordButton];
    [self.mainScrollView addSubview:self.loginButton];
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.width, CGRectGetMaxY(self.loginButton.frame))];
    
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    
    [self getLoginForm];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.mainScrollView setXCenterAligned];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance]trackScreenWithName:@"CustomerSignUp"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
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
         self.dynamicForm = [[JADynamicForm alloc] initWithForm:form values:@{@"email" : self.authenticationEmail} startingPosition:0.0f hasFieldNavigation:YES];
         [self.dynamicForm setDelegate:self];
         
         for(UIView *view in self.dynamicForm.formViews)
         {
             [self.mainScrollView addSubview:view];
         }
         
         [self setupViewsVertically];
         
         [self.mainScrollView setHidden:NO];
         self.requestDone = YES;
         
         [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
         [self hideLoading];
         
     } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
     {
         self.apiResponse = apiResponse;
         self.requestDone = YES;
         [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(getLoginForm) objects:nil];
         
         [self hideLoading];
     }];
}

#pragma mark - Action

- (void)setupViewsVertically
{
    CGFloat dynamicFormCurrentY = CGRectGetMaxY(self.subTitleLabel.frame) + kBeforeDynamicFormMargin;
    for(UIView *view in self.dynamicForm.formViews)
    {
        [view setX:kSideMargin];
        [view setY:dynamicFormCurrentY + kDynamicFormMargin];
        dynamicFormCurrentY = CGRectGetMaxY(view.frame);
    }
    
    [self.forgotPasswordButton setY:dynamicFormCurrentY + kForgotPasswordMargin];
    [self.loginButton setY:CGRectGetMaxY(self.forgotPasswordButton.frame) + kLoginButtonMargin];
    
    self.contentScrollOriginalHeight = self.mainScrollView.height;
    
    [self setupViewsHorizontally];
}

- (void)setupViewsHorizontally
{
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat middleX = (self.mainScrollView.width / 2);
        
        [self.titleLabel setWidth:kIPadWidth];
        [self.titleLabel setX:middleX - (self.titleLabel.width / 2)];
        
        [self.subTitleLabel setWidth:kIPadWidth];
        [self.subTitleLabel setX:middleX - (self.subTitleLabel.width / 2)];
        
        for(UIView *view in self.dynamicForm.formViews)
        {
            [view setWidth:kIPadWidth];
            [view setX:middleX - (view.width / 2)];
        }
        
        [self.forgotPasswordButton setX:middleX + (kIPadWidth / 2) - self.forgotPasswordButton.width];
        
        [self.loginButton setWidth:kIPadWidth];
        [self.loginButton setX:middleX - (self.loginButton.width / 2)];
        
    } else {
        [self.titleLabel setWidth:_elementsWidth];
        [self.titleLabel setX:kSideMargin];
        
        [self.subTitleLabel setWidth:_elementsWidth];
        [self.subTitleLabel setX:kSideMargin];
        
        for(UIView *view in self.dynamicForm.formViews)
        {
            [view setWidth:_elementsWidth];
            [view setX:kSideMargin];
        }
        
        [self.forgotPasswordButton setX:self.mainScrollView.width - self.forgotPasswordButton.width - kSideMargin];
        
        [self.loginButton setWidth:_elementsWidth];
        [self.loginButton setX:kSideMargin];
    }
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
    
    // notify the InAppNotification SDK that this the active view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

- (void)forgotPasswordButtonPressed:(id)sender
{
    [self hideKeyboard];
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowForgotPasswordScreenNotification
                                                        object:nil
                                                      userInfo:@{@"email" : self.authenticationEmail}];
}

- (void)loginButtonPressed:(id)sender
{
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
         
         if ([object isKindOfClass:[NSDictionary class]]) {
             NSDictionary* responseDictionary = (NSDictionary*)object;
             
             RICustomer *customerObject = [responseDictionary objectForKey:@"customer"];
             
             NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
             [trackingDictionary setValue:customerObject.idCustomer forKey:kRIEventLabelKey];
             [trackingDictionary setValue:@"LoginSuccess" forKey:kRIEventActionKey];
             [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
             [trackingDictionary setValue:customerObject.idCustomer forKey:kRIEventUserIdKey];
             [trackingDictionary setValue:customerObject.firstName forKey:kRIEventUserFirstNameKey];
             [trackingDictionary setValue:customerObject.lastName forKey:kRIEventUserLastNameKey];
             [trackingDictionary setValue:customerObject.birthday forKey:kRIEventBirthDayKey];
             [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
             [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
             NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
             [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
             if(self.fromSideMenu) {
                 [trackingDictionary setValue:@"Side menu" forKey:kRIEventLocationKey];
             } else {
                 [trackingDictionary setValue:@"My account" forKey:kRIEventLocationKey];
             }
             
             [trackingDictionary setValue:customerObject.gender forKey:kRIEventGenderKey];
             [trackingDictionary setValue:customerObject.createdAt forKey:kRIEventAccountDateKey];
             
             if (customerObject.birthday) {
                 NSDate* now = [NSDate date];
                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                 [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                 NSDate *dateOfBirth = [dateFormatter dateFromString:customerObject.birthday];
                 NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:dateOfBirth toDate:now options:0];
                 [trackingDictionary setValue:[NSNumber numberWithInteger:[ageComponents year]] forKey:kRIEventAgeKey];
             }
             
             NSNumber *numberOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountTransactions];
             [trackingDictionary setValue:numberOfPurchases forKey:kRIEventAmountTransactions];
             
             [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLoginSuccess]
                                                       data:[trackingDictionary copy]];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                 object:customerObject.wishlistProducts];
             
             
             
             if (self.fromSideMenu) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:kShowHomeScreenNotification object:nil];
             } else {
                 NSInteger count = [self.navigationController.viewControllers count];
                 if (count > 2)
                 {
                     UIViewController *viewController = [self.navigationController.viewControllers objectAtIndex:count-2];
                     UIViewController *viewControllerToPop = [self.navigationController.viewControllers objectAtIndex:count-3];
                     if ([viewController isKindOfClass:[JAAuthenticationViewController class]]) {
                         [self.navigationController popToViewController:viewControllerToPop animated:YES];
                     }else{
                         [self.navigationController popViewControllerAnimated:YES];
                     }
                 }else{
                     [self.navigationController popViewControllerAnimated:YES];
                 }
                 if(self.nextStepBlock) {
                     self.nextStepBlock();
                 }
             }
         }
         
         [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
         
         [self hideLoading];
         
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject) {
         
         NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
         [trackingDictionary setValue:@"LoginFailed" forKey:kRIEventActionKey];
         [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
         if(self.fromSideMenu) {
             [trackingDictionary setValue:@"Side menu" forKey:kRIEventLocationKey];
         } else {
             [trackingDictionary setValue:@"My account" forKey:kRIEventLocationKey];
         }
         
         [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLoginFail]
                                                   data:[trackingDictionary copy]];
         
         if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.dynamicForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(continueLogin) objects:nil];
             }];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.dynamicForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(continueLogin) objects:nil];
             }];
         } else {
             [self.dynamicForm checkErrors];
             [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:@selector(continueLogin) objects:nil];
         }
         [self hideLoading];
     }];
}

#pragma mark - Keyboard observers

- (void) hideKeyboard
{
    [self.dynamicForm resignResponder];
}

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
        [self.mainScrollView setFrame:CGRectMake(self.mainScrollView.frame.origin.x,
                                                 self.mainScrollView.frame.origin.y,
                                                 self.mainScrollView.frame.size.width,
                                                 self.contentScrollOriginalHeight - height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    if (self.contentScrollOriginalHeight == 0) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainScrollView setFrame:CGRectMake(self.mainScrollView.frame.origin.x,
                                                 self.mainScrollView.frame.origin.y,
                                                 self.mainScrollView.frame.size.width,
                                                 self.contentScrollOriginalHeight)];
    }];
}

@end