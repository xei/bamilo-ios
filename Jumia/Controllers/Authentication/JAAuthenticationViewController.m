//
//  JAAuthenticationViewController.m
//  Jumia
//
//  Created by Jose Mota on 26/11/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAAuthenticationViewController.h"
#import "JABottomBar.h"
#import "JAButton.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "JATextFieldComponent.h"
#import "RICustomer.h"
#import "JAUtils.h"

#define kTopMargin 36
#define kLateralMargin 16
#define kUserIcon2TopMess 6
#define kTopMess2FacebookButton 26
#define kFacebookMess2Or 28
#define kOr2Email 22
#define kEmail2ContinueWithout 16
#define kContinueWithout2ContinueLogin 16
#define kWidth 288

@interface JAAuthenticationViewController () <UITextFieldDelegate>
{
    CGFloat _offset;
}

@property (nonatomic) UIScrollView *mainScrollView;
@property (nonatomic) UIImageView *userIcon;
@property (nonatomic) UILabel *topMessageLabel;
@property (nonatomic) JAButton *facebookButton;
@property (nonatomic) UIView *orView;
@property (nonatomic) JAButton *continueWithoutLoginButton;
@property (nonatomic) JAButton *continueToLoginButton;
@property (nonatomic) JATextFieldComponent *emailTextField;

@property (strong, nonatomic) UIButton *facebookLoginButton;

@end

@implementation JAAuthenticationViewController

- (UIScrollView *)mainScrollView
{
    if (!VALID_NOTEMPTY(_mainScrollView, UIScrollView)) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.viewBounds];
    }
    return _mainScrollView;
}

- (UIImageView *)userIcon
{
    if (!VALID_NOTEMPTY(_userIcon, UIImageView)) {
        UIImage *image = [UIImage imageNamed:@"user_icon"];
        _userIcon = [[UIImageView alloc] initWithImage:image];
        [_userIcon setFrame:CGRectMake((self.view.width - image.size.width)/2, kTopMargin, image.size.width, image.size.height)];
    }
    return _userIcon;
}

- (UILabel *)topMessageLabel
{
    if (!VALID_NOTEMPTY(_topMessageLabel, UILabel)) {
        _topMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.width - kWidth)/2, CGRectGetMaxY(self.userIcon.frame) + kUserIcon2TopMess, kWidth, 50)];
        [_topMessageLabel setTextAlignment:NSTextAlignmentCenter];
        [_topMessageLabel setNumberOfLines:0];
        [_topMessageLabel setFont:JACaptionFont];
        [_topMessageLabel setTextColor:JABlack800Color];
        [_topMessageLabel setText:STRING_LOGIN_LONG_MESSAGE];
        CGFloat width = _topMessageLabel.width;
        [_topMessageLabel sizeToFit];
        [_topMessageLabel setWidth:width];
    }
    return _topMessageLabel;
}

- (JAButton *)facebookButton
{
    if (!VALID_NOTEMPTY(_facebookButton, JAButton)) {
        _facebookButton = [[JAButton alloc] initFacebookButtonWithTitle:[STRING_LOGIN_WITH_FACEBOOK uppercaseString] target:self action:@selector(facebookLoginButtonPressed:)];
        [_facebookButton setFrame:CGRectMake((self.view.width - kWidth)/2, CGRectGetMaxY(self.topMessageLabel.frame) + kTopMess2FacebookButton, kWidth, 50)];
    }
    return _facebookButton;
}

- (UIView *)orView
{
    if (!VALID_NOTEMPTY(_orView, UIView)) {
        
        CGRect frame = CGRectMake((self.view.width - kWidth)/2, CGRectGetMaxY(self.facebookButton.frame) + kTopMess2FacebookButton, kWidth, 30);
        _orView = [[UIView alloc] initWithFrame:frame];
        
        UILabel *orLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2 - 25, (frame.size.height-30)/2, 100, 30)];
        [orLabel setTextAlignment:NSTextAlignmentCenter];
        [orLabel setTextColor:JABlack800Color];
        [orLabel setFont:JACaptionFont];
        [orLabel setText:STRING_OR];
        [orLabel sizeToFit];
        [_orView addSubview:orLabel];
        
        CGFloat textWidth = orLabel.width + 12.f;
        
        [orLabel setXCenterAligned];
        [orLabel setYCenterAligned];
        
        UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height/2, frame.size.width/2 - textWidth/2, 1)];
        [leftLine setBackgroundColor:JABlack800Color];
        [_orView addSubview:leftLine];
        
        UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/2 + textWidth/2, frame.size.height/2, frame.size.width/2 - textWidth/2, 1)];
        [rightLine setBackgroundColor:JABlack800Color];
        [_orView addSubview:rightLine];
    }
    return _orView;
}

- (JATextFieldComponent *)emailTextField
{
    if (!VALID_NOTEMPTY(_emailTextField, JATextFieldComponent)) {
        CGFloat yOffset = CGRectGetMaxY(self.topMessageLabel.frame) + kTopMess2FacebookButton;
        if ([[RICountryConfiguration getCurrentConfiguration].facebookAvailable boolValue]){
            yOffset = CGRectGetMaxY(self.orView.frame) + kOr2Email;
        }
        _emailTextField = [[JATextFieldComponent alloc] init];
        [_emailTextField setFrame:CGRectMake((self.view.width - kWidth)/2, yOffset, kWidth, _emailTextField.height)];
        [_emailTextField.textField setReturnKeyType:UIReturnKeyNext];
        [_emailTextField.textField setKeyboardType:UIKeyboardTypeEmailAddress];
        [_emailTextField.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_emailTextField setupWithTitle:STRING_EMAIL_ADDRESS label:STRING_EMAIL_EXAMPLE value:[self getEmail] mandatory:NO];
    }
    return _emailTextField;
}

- (JAButton *)continueWithoutLoginButton
{
    if (!VALID_NOTEMPTY(_continueWithoutLoginButton, JAButton)) {
        _continueWithoutLoginButton = [[JAButton alloc] initAlternativeButtonWithTitle:STRING_CONTINUE_WITHOUT_LOGIN target:self action:@selector(continueWithoutLogin)];
        [_continueWithoutLoginButton setFrame:CGRectMake((self.view.width - kWidth)/2, CGRectGetMaxY(self.emailTextField.frame) + kEmail2ContinueWithout, kWidth, kBottomDefaultHeight)];
        if (self.checkout)
        {
            [_continueWithoutLoginButton setHidden:NO];
        }else{
            [_continueWithoutLoginButton setHidden:YES];
        }
    }
    return _continueWithoutLoginButton;
}

- (JAButton *)continueToLoginButton
{
    if (!VALID_NOTEMPTY(_continueToLoginButton, JAButton)) {
        CGFloat yOffset = CGRectGetMaxY(self.continueWithoutLoginButton.frame) + kContinueWithout2ContinueLogin;
        if (!self.checkout) {
            yOffset = CGRectGetMaxY(self.emailTextField.frame) + kContinueWithout2ContinueLogin;
        }
        _continueToLoginButton = [[JAButton alloc] initButtonWithTitle:[STRING_CONTINUE uppercaseString] target:self action:@selector(checkEmail)];
        [_continueToLoginButton setFrame:CGRectMake((self.view.width - kWidth)/2, yOffset, kWidth, kBottomDefaultHeight)];
    }
    return _continueToLoginButton;
}

#pragma mark - view life cicle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenName = @"Authentication";
    
    self.navBarLayout.title = STRING_LOGIN;
    self.navBarLayout.showCartButton = NO;
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.userIcon];
    [self.mainScrollView addSubview:self.topMessageLabel];
    
    if ([[RICountryConfiguration getCurrentConfiguration].facebookAvailable boolValue]){
        [self.mainScrollView addSubview:self.facebookButton];
        [self.mainScrollView addSubview:self.orView];
    }
    
    [self.mainScrollView addSubview:self.emailTextField];
    [self.mainScrollView addSubview:self.continueWithoutLoginButton];
    [self.mainScrollView addSubview:self.continueToLoginButton];
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.width, CGRectGetMaxY(self.continueToLoginButton.frame))];
    
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
    
    [self.emailTextField.textField setDelegate:self];
}

- (void)viewWillLayoutSubviews
{
    [self.mainScrollView setXCenterAligned];
}

#pragma mark - Keyboard events

- (void)keyboardWillShow:(NSNotification *)notification
{
    // get the size of the keyboard
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat keyboardY = self.viewBounds.size.height - keyboardSize.height;
    
    UIView *firstResponder = [self findFirstResponder];
    if (!firstResponder) {
        return;
    }
    
    if (CGRectGetMaxY(firstResponder.frame) < keyboardY) {
        return;
    }
    
    _offset = keyboardY - (CGRectGetMaxY(firstResponder.frame) - 6.f);
    [self.mainScrollView setContentOffset:CGPointMake(0, -_offset) animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

- (void)hideKeyboard
{
    [[self findFirstResponder] resignFirstResponder];
}

#pragma mark - TextField delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (UIView *)findFirstResponder
{
    if ([self.emailTextField.textField isFirstResponder]) {
        return self.emailTextField;
    }
    return nil;
}

#pragma mark - Button actions

#pragma mark - Facebook Login
- (void)facebookLoginButtonPressed:(id)sender
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_birthday"] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        NSLog(@"token: %@", result.token);
        
        NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
        [parameters setValue:@"id,name, first_name, last_name, email, gender, birthday" forKey:@"fields"];
        FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc]
                                        initWithGraphPath:@"me" parameters:parameters];
        FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
        [connection addRequest:requestMe
             completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 //TODO: process me information@
                 if (error) {
                     NSLog(@"%@", error);
                     return;
                 }
                 if([result objectForKey:@"email"] == NULL || [result objectForKey:@"birthday"] == NULL) {
                     [self onErrorResponse:RIApiResponseSuccess messages:@[STRING_LOGIN_INCOMPLETE] showAsMessage:YES selector:@selector(facebookLoginButtonPressed:) objects:sender];
                     return;
                 }
                 if (![RICustomer checkIfUserIsLogged])
                 {
                     [self showLoading];
                     
                     NSString *email = [result objectForKey:@"email"];
                     NSString *firstName = [result objectForKey:@"first_name"];
                     NSString *lastName = [result objectForKey:@"last_name"];
                     NSString *birthday = [result objectForKey:@"birthday"];
                     NSString *gender = [result objectForKey:@"gender"];
                     
                     NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
                     if((VALID_NOTEMPTY(email, NSString)) && (VALID_NOTEMPTY(firstName, NSString)) && (VALID_NOTEMPTY(lastName, NSString)) && (VALID_NOTEMPTY(gender, NSString)) && (VALID_NOTEMPTY(birthday, NSString)))
                     {
                         [parameters setValue:email forKey:@"email"];
                         [parameters setValue:firstName forKey:@"first_name"];
                         [parameters setValue:lastName forKey:@"last_name"];
                         [parameters setValue:gender forKey:@"gender"];
                         [parameters setValue:birthday forKey:@"birthday"];
                         
                     }else if((VALID_NOTEMPTY(email, NSString)) && (VALID_NOTEMPTY(firstName, NSString)) && (VALID_NOTEMPTY(lastName, NSString)) && (VALID_NOTEMPTY(gender, NSString)))
                     {
                         [parameters setValue:email forKey:@"email"];
                         [parameters setValue:firstName forKey:@"first_name"];
                         [parameters setValue:lastName forKey:@"last_name"];
                         [parameters setValue:gender forKey:@"gender"];
                         
                     }else if((VALID_NOTEMPTY(email, NSString)) && (VALID_NOTEMPTY(firstName, NSString)) && (VALID_NOTEMPTY(lastName, NSString))){
                         [parameters setValue:email forKey:@"email"];
                         [parameters setValue:firstName forKey:@"first_name"];
                         [parameters setValue:lastName forKey:@"last_name"];
                         
                     }else if((VALID_NOTEMPTY(email, NSString)) && (VALID_NOTEMPTY(firstName, NSString)))
                     {
                         [parameters setValue:email forKey:@"email"];
                         [parameters setValue:firstName forKey:@"first_name"];
                         
                     }else
                     {
                         [parameters setValue:email forKey:@"email"];
                     }
                     
                     [RICustomer loginCustomerByFacebookWithParameters:parameters
                                                          successBlock:^(NSDictionary* entities, NSString* nextStep) {
                                                              
                                                              RICustomer* customer = [entities objectForKey:@"customer"];
                                                              
                                                              NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
                                                              [trackingDictionary setValue:customer.customerId forKey:kRIEventLabelKey];
                                                              [trackingDictionary setValue:@"FacebookLoginSuccess" forKey:kRIEventActionKey];
                                                              [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
                                                              [trackingDictionary setValue:customer.customerId forKey:kRIEventUserIdKey];
                                                              [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
                                                              [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
                                                              [trackingDictionary setValue:customer.gender forKey:kRIEventGenderKey];
                                                              [trackingDictionary setValue:customer.createdAt forKey:kRIEventAccountDateKey];
                                                              
                                                              NSDate* now = [NSDate date];
                                                              NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                              [dateFormatter setDateFormat:@"yyyy-MM-dd"];
                                                              NSDate *dateOfBirth = [dateFormatter dateFromString:customer.birthday];
                                                              NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:dateOfBirth toDate:now options:0];
                                                              [trackingDictionary setValue:[NSNumber numberWithInteger:[ageComponents year]] forKey:kRIEventAgeKey];
                                                              [trackingDictionary setValue:[dateFormatter stringFromDate:dateOfBirth] forKey:kRIEventBirthDayKey];
                                                              
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
                                                              
                                                              NSNumber *numberOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountTransactions];
                                                              [trackingDictionary setValue:numberOfPurchases forKey:kRIEventAmountTransactions];
                                                              
                                                              [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventFacebookLoginSuccess]
                                                                                                        data:[trackingDictionary copy]];
                                                              
//                                                              [self.dynamicForm resetValues];
                                                              
                                                              [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
                                                              
                                                              [self hideLoading];
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:kOpenCenterPanelNotification
                                                                                                                  object:nil];
                                                              
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                                                                  object:customer.wishlistProducts];
                                                              
                                                              NSMutableDictionary *userInfo = [NSMutableDictionary new];
                                                              if (self.fromSideMenu) {
                                                                  [userInfo setObject:@YES forKey:@"from_side_menu"];
                                                              }
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:kRunBlockAfterAuthenticationNotification object:self.nextStepBlock userInfo:userInfo];
                                                              
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
                                                              
                                                              [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:@selector(facebookLoginButtonPressed:) objects:sender];
                                                              [self hideLoading];
                                                              
                                                          }];
                 }
                 else
                 {
                     [self onErrorResponse:RIApiResponseSuccess messages:@[[error description]] showAsMessage:YES selector:@selector(facebookLoginButtonPressed:) objects:sender];
                 }
             }];
        [connection start];
        
    }];
}

#pragma mark - Continue Button Action

- (void)checkEmail
{
    if (![self isFirstCheckChecked]) {
        return;
    }
    [self showLoading];
    [RICustomer checkEmailWithParameters:[NSDictionary dictionaryWithObject:self.emailTextField.textField.text forKey:@"email"] successBlock:^(BOOL knownEmail, RICustomer *customerAlreadyLoggedIn) {
        
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        
        [self.emailTextField cleanError];
        
        if (VALID_NOTEMPTY(customerAlreadyLoggedIn, RICustomer)) {
            NSMutableDictionary *userInfo = [NSMutableDictionary new];
            if (self.fromSideMenu) {
                [userInfo setObject:@YES forKey:@"from_side_menu"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kRunBlockAfterAuthenticationNotification object:self.nextStepBlock userInfo:userInfo];
            [self hideLoading];
            return;
        }
        
        NSMutableDictionary *userInfo;
        if (!VALID_NOTEMPTY(self.userInfo, NSDictionary)) {
            userInfo = [NSMutableDictionary new];
        }else{
            userInfo = [self.userInfo mutableCopy];
        }
        
        [userInfo setObject:self.emailTextField.textField.text forKey:@"email"];
        
        if (knownEmail) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification object:self.nextStepBlock userInfo:userInfo];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignUpScreenNotification object:self.nextStepBlock userInfo:userInfo];
        }
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorObject) {
        
        NSString *errorMessage = @"invalid email";
        if (VALID_NOTEMPTY(errorObject, NSArray)) {
            if (VALID_NOTEMPTY([errorObject firstObject], NSString))
            {
                errorMessage = [errorObject firstObject];
            }else if (VALID_NOTEMPTY([[errorObject firstObject] objectForKey:@"message"], NSString)) {
                errorMessage = [[errorObject firstObject] objectForKey:@"message"];
            }
        }
        
        [self onErrorResponse:apiResponse messages:@[errorMessage] showAsMessage:YES selector:@selector(checkEmail) objects:nil];
        
        [self hideLoading];
    }];
}

- (NSString *)getEmail
{
    NSString* emailKeyForCountry = [NSString stringWithFormat:@"%@_%@", kRememberedEmail, [RIApi getCountryIsoInUse]];
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:emailKeyForCountry];
    if(VALID_NOTEMPTY(email, NSString))
    {
        return email;
    }
    return @"";
}

- (void)continueWithoutLogin
{
    if (![self isFirstCheckChecked]) {
        return;
    }
    [self showLoading];
    [RICustomer signUpAccount:self.emailTextField.textField.text successBlock:^(id object){
        
        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
        [self.emailTextField cleanError];
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:@"Checkout" forKey:kRIEventLocationKey];
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSignupSuccess]
                                                  data:trackingDictionary];
        
        [self hideLoading];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                            object:nil];
        
        NSDictionary *responseDictionary = (NSDictionary *)object;
        NSString* nextStep = [responseDictionary objectForKey:@"next_step"];
        
        [self.navigationController popViewControllerAnimated:NO];
        
        [JAUtils goToNextStep:nextStep
                     userInfo:nil];
        
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorObject) {
        
        NSString *errorMessage = @"invalid email";
        if (VALID_NOTEMPTY([errorObject firstObject], NSString))
        {
            errorMessage = [errorObject firstObject];
        }else if (VALID_NOTEMPTY([[errorObject firstObject] objectForKey:@"message"], NSString)) {
            errorMessage = [[errorObject firstObject] objectForKey:@"message"];
        }
        [self.emailTextField setError:errorMessage];
        
        [self onErrorResponse:apiResponse messages:@[errorMessage] showAsMessage:YES selector:@selector(continueWithoutLogin) objects:nil];
        
        [self hideLoading];
    }];
}

- (BOOL)isFirstCheckChecked
{
    if (!VALID_NOTEMPTY(self.emailTextField.textField.text, NSString)) {
        [self.emailTextField.textField setDelegate:self];
        NSString *errorMessage = @"invalid email";
        [self.emailTextField setError:@""];
        [self onErrorResponse:RIApiResponseSuccess messages:@[errorMessage] showAsMessage:YES selector:nil objects:nil];
        return NO;
    }
    return YES;
}

+ (void)goToCheckoutWithBlock:(void (^)(void))authenticatedBlock
{
    [self authenticateAndExecuteBlock:authenticatedBlock showBackButtonForAuthentication:YES showContinueWithoutLogin:YES];
}

+ (void)authenticateAndExecuteBlock:(void (^)(void))authenticatedBlock showBackButtonForAuthentication:(BOOL)backButton
{
    [self authenticateAndExecuteBlock:authenticatedBlock showBackButtonForAuthentication:backButton showContinueWithoutLogin:NO];
}

+ (void)authenticateAndExecuteBlock:(void (^)(void))authenticatedBlock showBackButtonForAuthentication:(BOOL)backButton showContinueWithoutLogin:(BOOL)continueButton
{
    if([RICustomer checkIfUserIsLogged])
    {
        authenticatedBlock();
    }else{
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:[NSNumber numberWithBool:continueButton] forKey:@"continue_button"];
        [userInfo setObject:[NSNumber numberWithBool:backButton] forKey:@"shows_back_button"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification object:authenticatedBlock userInfo:userInfo];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.emailTextField.hasError) {
        [self.emailTextField cleanError];
    }
    return YES;
}

@end
