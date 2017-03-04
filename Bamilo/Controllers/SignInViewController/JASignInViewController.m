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
#import "JAAccountServicesView.h"

#define kSideMargin 16
#define kTopMargin 30
#define kSubTitleMargin 20
#define kBeforeDynamicFormMargin 30
#define kForgotPasswordMargin 16
#define kLoginButtonMargin 20

#define kIPadWidth 288

@interface JASignInViewController() <JADynamicFormDelegate, JAAccountServicesProtocol>
{
    CGFloat _elementsWidth;
    UIView *_firstResponder;
}

@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subTitleLabel;
@property (strong, nonatomic) JAAccountServicesView *casAccountServicesImagesView;
@property (strong, nonatomic) UILabel *casSubtitleLabel;
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
        [_mainScrollView setShowsHorizontalScrollIndicator:NO];
        [_mainScrollView setShowsVerticalScrollIndicator:NO];
        [_mainScrollView setContentSize:_mainScrollView.bounds.size];
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
        
        if ([RICountryConfiguration getCurrentConfiguration].casIsActive.boolValue) {
            if (VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].casTitle, NSString)) {
                [_titleLabel setText:[RICountryConfiguration getCurrentConfiguration].casTitle];
            }
        }
        [_titleLabel sizeHeightToFit];
    }
    return _titleLabel;
}

- (UILabel *)casSubtitleLabel
{
    if (!VALID_NOTEMPTY(_casSubtitleLabel, UILabel)) {
        _casSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSideMargin, CGRectGetMaxY(self.titleLabel.frame) + kSubTitleMargin, _elementsWidth, 30)];
        [_casSubtitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_casSubtitleLabel setNumberOfLines:0];
        [_casSubtitleLabel setFont:JABodyFont];
        [_casSubtitleLabel setTextColor:JABlack800Color];
        [_casSubtitleLabel setHidden:YES];
        if ([RICountryConfiguration getCurrentConfiguration].casIsActive.boolValue && VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].casSubtitle, NSString)) {
            [_casSubtitleLabel setHidden:NO];
            [_casSubtitleLabel setText:[RICountryConfiguration getCurrentConfiguration].casSubtitle];
        }
        [_casSubtitleLabel sizeHeightToFit];
    }
    return _casSubtitleLabel;
}

- (JAAccountServicesView *)casAccountServicesImagesView
{
    if (!VALID_NOTEMPTY(_casAccountServicesImagesView, JAAccountServicesView)) {
        _casAccountServicesImagesView = [[JAAccountServicesView alloc] initWithFrame:CGRectMake(kSideMargin, CGRectGetMaxY(self.titleLabel.frame) + kSubTitleMargin, _elementsWidth, 0.f)]; // view will define its height
        [_casAccountServicesImagesView setHidden:YES];
        if ([RICountryConfiguration getCurrentConfiguration].casIsActive.boolValue && VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].casImages, NSArray)) {
            [_casAccountServicesImagesView setHidden:NO];
            [_casAccountServicesImagesView setAccountServicesArray:[RICountryConfiguration getCurrentConfiguration].casImages];
            [_casAccountServicesImagesView setDelegate:self];
            if (VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].casSubtitle, NSString)) {
                [_casAccountServicesImagesView setY:CGRectGetMaxY(self.casSubtitleLabel.frame) + kSubTitleMargin];
            }
        }
    }
    return _casAccountServicesImagesView;
}

- (UILabel *)subTitleLabel
{
    if (!VALID_NOTEMPTY(_subTitleLabel, UILabel)) {
        _subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(
                                                                   kSideMargin,
                                                                   CGRectGetMaxY(self.titleLabel.frame) + kBeforeDynamicFormMargin,
                                                                   _elementsWidth,
                                                                   60)];
        [_subTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_subTitleLabel setNumberOfLines:0];
        [_subTitleLabel setFont:JABodyFont];
        [_subTitleLabel setTextColor:JABlack800Color];
        [_subTitleLabel setText:STRING_LOGIN_ENTER_PASSWORD_TO_CONTINUE];
        
        if ([RICountryConfiguration getCurrentConfiguration].casIsActive.boolValue) {
            if (VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].casSubtitle, NSString)) {
                [_subTitleLabel setY:CGRectGetMaxY(self.casSubtitleLabel.frame) + kBeforeDynamicFormMargin];
            }
            if (VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].casImages, NSArray)) {
                [_subTitleLabel setY:CGRectGetMaxY(self.casAccountServicesImagesView.frame) + kBeforeDynamicFormMargin];
            }
        }
        [_subTitleLabel sizeHeightToFit];
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
        [_forgotPasswordButton.titleLabel setFont:JABodyFont];
        [_forgotPasswordButton setTitle:STRING_FORGOT_YOUR_PASSWORD forState:UIControlStateNormal];
        [_forgotPasswordButton setTitleColor:JABlue1Color forState:UIControlStateNormal];
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
        [_loginButton addButton:[STRING_CONTINUE uppercaseString] target:self action:@selector(loginButtonPressed:)];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideKeyboard)
                                                 name:kOpenMenuNotification
                                               object:nil];
    
    self.apiResponse = RIApiResponseSuccess;
    
    self.A4SViewControllerAlias = @"ACCOUNT";
    
    self.navBarLayout.title = STRING_LOGIN;
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showCartButton = YES;
    self.navBarLayout.showSearchButton = YES;
    
    _elementsWidth = self.viewBounds.size.width - (kSideMargin * 2);
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        _elementsWidth = kIPadWidth;
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.titleLabel];
    [self.mainScrollView addSubview:self.casSubtitleLabel];
    [self.mainScrollView addSubview:self.casAccountServicesImagesView];
    [self.mainScrollView addSubview:self.subTitleLabel];
    [self.mainScrollView addSubview:self.forgotPasswordButton];
    [self.mainScrollView addSubview:self.loginButton];
    
    if(self.apiResponse == RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess) {
        [self showLoading];
    }
    
    [self getLoginForm];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self.mainScrollView setXCenterAligned];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance]trackScreenWithName:@"CustomerSignUp"];
}

- (void)viewDidDisappear:(BOOL)animated {
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

- (void)dealloc     {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getLoginForm {
    self.requestDone = NO;
    
    [RIForm getForm:@"login" successBlock:^(RIForm *form) {
         CGFloat yOffset = CGRectGetMaxY(self.subTitleLabel.frame) + kSubTitleMargin;
         
         self.dynamicForm = [[JADynamicForm alloc] initWithForm:form values:@{@"email" : self.authenticationEmail} startingPosition:yOffset hasFieldNavigation:YES];
         [self.dynamicForm setDelegate:self];
         
         for(UIView *view in self.dynamicForm.formViews) {
             [self.mainScrollView addSubview:view];
         }
         
         [self setupViewsVertically];
         
         [self.mainScrollView setHidden:NO];
         self.requestDone = YES;
         
         [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
         [self hideLoading];
         
     } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
         self.apiResponse = apiResponse;
         self.requestDone = YES;
         [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(getLoginForm) objects:nil];
         
         [self hideLoading];
     }];
}

#pragma mark - Action
- (void)setupViewsVertically
{
    CGFloat dynamicFormCurrentY = 0.f;
    for (UIView *view in self.dynamicForm.formViews) {
        [view setX:kSideMargin];
        dynamicFormCurrentY = CGRectGetMaxY(view.frame);
    }
    
    [self.forgotPasswordButton setY:dynamicFormCurrentY + kForgotPasswordMargin];
    [self.loginButton setY:CGRectGetMaxY(self.forgotPasswordButton.frame) + kLoginButtonMargin];
    
    [self.mainScrollView setHeight:self.viewBounds.size.height];
    self.contentScrollOriginalHeight = CGRectGetHeight(self.mainScrollView.frame);
    
    [self setupViewsHorizontally];
}

- (void)setupViewsHorizontally {
    [self.titleLabel setXCenterAligned];
    [self.casSubtitleLabel setXCenterAligned];
    [self.casAccountServicesImagesView setXCenterAligned];
    [self.subTitleLabel setXCenterAligned];
    
    for(UIView *view in self.dynamicForm.formViews)
    {
        [view setXCenterAligned];
    }
    
    [self.loginButton setWidth:_elementsWidth];
    [self.loginButton setXCenterAligned];
    [self.forgotPasswordButton setX:CGRectGetMaxX(self.loginButton.frame) - self.forgotPasswordButton.width];
    
    [self publishScreenLoadTime];
    
    // notify the InAppNotification SDK that this the active view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

- (void)forgotPasswordButtonPressed:(id)sender {
    [self hideKeyboard];
    //[[NSNotificationCenter defaultCenter] postNotificationName:kShowForgotPasswordScreenNotification object:nil userInfo:@{@"email" : self.authenticationEmail}];
}

- (void)loginButtonPressed:(id)sender {
    [self continueLogin];
}

- (void)continueLogin
{
    [self hideKeyboard];
    [self showLoading];
    
    [RIForm sendForm:[self.dynamicForm form]
          parameters:[self.dynamicForm getValues]
        successBlock:^(id object, NSArray* successMessages) {
         
         [self.dynamicForm resetValues];
            
         [RICustomer resetCustomerAsGuest];
         if ([object isKindOfClass:[NSDictionary class]]) {
             NSDictionary* responseDictionary = (NSDictionary*)object;
             
             RICustomer *customerObject = [responseDictionary objectForKey:@"customer"];
             
             NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
             [trackingDictionary setValue:customerObject.customerId forKey:kRIEventLabelKey];
             [trackingDictionary setValue:@"LoginSuccess" forKey:kRIEventActionKey];
             [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
             [trackingDictionary setValue:customerObject.customerId forKey:kRIEventUserIdKey];
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
                 NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:0];
                 [trackingDictionary setValue:[NSNumber numberWithInteger:[ageComponents year]] forKey:kRIEventAgeKey];
             }
             
             NSNumber *numberOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountTransactions];
             [trackingDictionary setValue:numberOfPurchases forKey:kRIEventAmountTransactions];
             
             [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLoginSuccess]
                                                       data:[trackingDictionary copy]];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                 object:customerObject.wishlistProducts];
             
             NSMutableDictionary *userInfo = [NSMutableDictionary new];
             if (self.fromSideMenu) {
                 [userInfo setObject:@YES forKey:@"from_side_menu"];
             }
             [[NSNotificationCenter defaultCenter] postNotificationName:kRunBlockAfterAuthenticationNotification object:self.nextStepBlock userInfo:userInfo];
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
- (void) hideKeyboard {
    [[self findFirstResponder] resignFirstResponder];
}

- (void) keyboardWillShow:(NSNotification *)notification
{
    CGFloat keyboardHeight = [self getKeyboardHeight:notification];
    
    if (!keyboardHeight) {
        return;
    }
    
    CGFloat keyboardY = self.viewBounds.size.height - keyboardHeight;
    UIView *firstResponder = [self findFirstResponder];
    
    if (!firstResponder || CGRectGetMaxY(firstResponder.frame) < keyboardY) {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainScrollView setFrame:CGRectMake(self.mainScrollView.frame.origin.x,
                                                 self.mainScrollView.frame.origin.y,
                                                 self.mainScrollView.frame.size.width,
                                                 self.contentScrollOriginalHeight - keyboardHeight)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    if (self.contentScrollOriginalHeight == 0 || self.contentScrollOriginalHeight == CGRectGetHeight(self.mainScrollView.frame)) {
        return;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainScrollView setFrame:CGRectMake(self.mainScrollView.frame.origin.x,
                                                 self.mainScrollView.frame.origin.y,
                                                 self.mainScrollView.frame.size.width,
                                                 self.contentScrollOriginalHeight)];
    }];
}

#pragma mark - DynamicForms delegate
- (void)changedFocus:(UIView *)view {
    _firstResponder = view;
}

- (void)lostFocus
{
    _firstResponder = nil;
}

- (UIView *)findFirstResponder
{
    if (_firstResponder) {
        return _firstResponder;
    }
    return nil;
}

#pragma mark - helper functions
- (CGFloat)getKeyboardHeight:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = kbSize.height;
    
    if (self.view.frame.size.width == kbSize.height) {
        height = kbSize.width;
    }
    
    return height;
}

- (void)accountServicesViewChange
{
    [self.subTitleLabel setYBottomOf:self.casAccountServicesImagesView at:kBeforeDynamicFormMargin];
    [self setupViewsVertically];
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    return @"Login";
}

-(NSString *)getPerformanceTrackerLabel {
    return self.authenticationEmail;
}

@end
