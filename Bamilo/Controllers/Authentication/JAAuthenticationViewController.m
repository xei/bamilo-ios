////
////  JAAuthenticationViewController.m
////  Jumia
////
////  Created by Jose Mota on 26/11/15.
////  Copyright © 2015 Rocket Internet. All rights reserved.
////
//
//#import "JAAuthenticationViewController.h"
//#import "JAButton.h"
//#import "JATextFieldComponent.h"
//#import "RICustomer.h"
//#import "JAUtils.h"
//#import "JAAccountServicesView.h"
//
//#define kLateralMargin 16
//#define kTopMargin 30
//#define kUserIcon2TopMess 20
//#define kTopMess2AccountServices 20
//#define kAccountServices2Email 30
//#define kEmail2ContinueLogin 20
//#define kContinueLogin2OrMess 20
////#define kOrMess2FacebookButton 10 // reducing 10px to get button bigger and clickable
////#define kFacebookButton2ContinueWithout 20
//#define kWidth 288
//
//@interface JAAuthenticationViewController () <UITextFieldDelegate, JAAccountServicesProtocol>
//{
//    CGFloat _offset;
//}
//
//@property (nonatomic) UIScrollView *mainScrollView;
//@property (nonatomic) UIImageView *userIcon;
//@property (nonatomic) UILabel *casTitleLabel;
//@property (nonatomic) UILabel *topMessageLabel;
////@property (nonatomic) JAButton *facebookButton;
//@property (nonatomic) UIView *orView;
//@property (nonatomic) JAButton *continueWithoutLoginButton;
//@property (nonatomic) JAButton *continueToLoginButton;
//@property (nonatomic) JATextFieldComponent *emailTextField;
//
//@property (nonatomic) JAAccountServicesView *casAccountServicesImagesView;
//
//@end
//
//@implementation JAAuthenticationViewController
//
//- (UIScrollView *)mainScrollView
//{
//    if (!VALID_NOTEMPTY(_mainScrollView, UIScrollView)) {
//        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.viewBounds];
//    }
//    return _mainScrollView;
//}
//
//- (UIImageView *)userIcon {
//    if (!VALID_NOTEMPTY(_userIcon, UIImageView)) {
//        UIImage *image = [UIImage imageNamed:@"user_icon"];
//        _userIcon = [[UIImageView alloc] initWithImage:image];
//        [_userIcon setFrame:CGRectMake((self.view.width - image.size.width)/2, kTopMargin, image.size.width, image.size.height)];
//    }
//    return _userIcon;
//}
//
//- (UILabel *)casTitleLabel
//{
//    if (!VALID_NOTEMPTY(_casTitleLabel, UILabel)) {
//        _casTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.width - kWidth)/2, kTopMargin, kWidth, 50)];
//        [_casTitleLabel setTextAlignment:NSTextAlignmentCenter];
//        [_casTitleLabel setNumberOfLines:0];
//        [_casTitleLabel setFont:JADisplay2Font];
//        [_casTitleLabel setTextColor:JABlackColor];
//        [_casTitleLabel setHidden:YES];
//        if ([RICountryConfiguration getCurrentConfiguration].casIsActive.boolValue) {
//            if (VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].casTitle, NSString)) {
//                [_casTitleLabel setText:[RICountryConfiguration getCurrentConfiguration].casTitle];
//                [_casTitleLabel setHidden:NO];
//                [self.userIcon setHidden:YES];
//            }
//        }
//        [_casTitleLabel sizeHeightToFit];
//    }
//    return _casTitleLabel;
//}
//
//- (UILabel *)topMessageLabel
//{
//    if (!VALID_NOTEMPTY(_topMessageLabel, UILabel)) {
//        _topMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.width - kWidth)/2, CGRectGetMaxY(self.userIcon.frame) + kUserIcon2TopMess, kWidth, 50)];
//        [_topMessageLabel setTextAlignment:NSTextAlignmentCenter];
//        [_topMessageLabel setNumberOfLines:0];
//        [_topMessageLabel setFont:JABodyFont];
//        [_topMessageLabel setTextColor:JABlack800Color];
//        [_topMessageLabel setText:STRING_LOGIN_LONG_MESSAGE];
//        if ([RICountryConfiguration getCurrentConfiguration].casIsActive.boolValue) {
//            if (VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].casSubtitle, NSString)) {
//                if (VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].casTitle, NSString)) {
//                    [_topMessageLabel setY:CGRectGetMaxY(self.casTitleLabel.frame) + kUserIcon2TopMess];
//                }else{
//                    [_topMessageLabel setY:CGRectGetMaxY(self.userIcon.frame) + kUserIcon2TopMess];
//                }
//                [_topMessageLabel setText:[RICountryConfiguration getCurrentConfiguration].casSubtitle];
//            }
//        }
//        [_topMessageLabel sizeHeightToFit];
//    }
//    return _topMessageLabel;
//}
//
//- (JAAccountServicesView *)casAccountServicesImagesView {
//    if (!VALID_NOTEMPTY(_casAccountServicesImagesView, JAAccountServicesView)) {
//        _casAccountServicesImagesView = [[JAAccountServicesView alloc] initWithFrame:CGRectMake((self.view.width - kWidth)/2, CGRectGetMaxY(self.topMessageLabel.frame) + kTopMess2AccountServices, kWidth, 0.f)]; // view will define its height
//        [_casAccountServicesImagesView setHidden:YES];
//        if ([RICountryConfiguration getCurrentConfiguration].casIsActive.boolValue) {
//            if (VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].casImages, NSArray)) {
//                [_casAccountServicesImagesView setHidden:NO];
//                [_casAccountServicesImagesView setAccountServicesArray: [RICountryConfiguration getCurrentConfiguration].casImages];
//                _casAccountServicesImagesView.delegate = self;
//            }
//        }
//    }
//    return _casAccountServicesImagesView;
//}
//
//- (UIView *)orView {
//    if (!VALID_NOTEMPTY(_orView, UIView)) {
//        
//        CGRect frame = CGRectMake((self.view.width - kWidth)/2, CGRectGetMaxY(self.continueToLoginButton.frame) + kContinueLogin2OrMess, kWidth, 30);
//        _orView = [[UIView alloc] initWithFrame:frame];
//        
//        UILabel *orLabel = [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width/2 - 25, (frame.size.height-30)/2, 100, 30)];
//        [orLabel setTextAlignment:NSTextAlignmentCenter];
//        [orLabel setTextColor:JABlack800Color];
//        [orLabel setFont:JABodyFont];
//        [orLabel setText:STRING_OR];
//        [orLabel sizeToFit];
//        [_orView addSubview:orLabel];
//        
//        CGFloat textWidth = orLabel.width + 12.f;
//        
//        [orLabel setXCenterAligned];
//        [orLabel setYCenterAligned];
//        
//        UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height/2, frame.size.width/2 - textWidth/2, 1)];
//        [leftLine setBackgroundColor:JABlack400Color];
//        [_orView addSubview:leftLine];
//        
//        UIView *rightLine = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width/2 + textWidth/2, frame.size.height/2, frame.size.width/2 - textWidth/2, 1)];
//        [rightLine setBackgroundColor:JABlack400Color];
//        [_orView addSubview:rightLine];
//    }
//    return _orView;
//}
//
//- (JATextFieldComponent *)emailTextField {
//    if (!VALID_NOTEMPTY(_emailTextField, JATextFieldComponent)) {
//        CGFloat yOffset = CGRectGetMaxY(self.topMessageLabel.frame) + kAccountServices2Email;
//        
//        if ([RICountryConfiguration getCurrentConfiguration].casIsActive.boolValue) {
//            if (VALID_NOTEMPTY([RICountryConfiguration getCurrentConfiguration].casImages, NSArray)) {
//                yOffset = CGRectGetMaxY(self.casAccountServicesImagesView.frame) + kAccountServices2Email;
//            }
//        }
//        _emailTextField = [[JATextFieldComponent alloc] init];
//        [_emailTextField setFrame:CGRectMake((self.view.width - kWidth)/2, yOffset, kWidth, _emailTextField.height)];
//        [_emailTextField.textField setAutocorrectionType:UITextAutocorrectionTypeNo];
//        [_emailTextField.textField setReturnKeyType:UIReturnKeyNext];
//        [_emailTextField.textField setKeyboardType:UIKeyboardTypeEmailAddress];
//        [_emailTextField.textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//        [_emailTextField setupWithTitle:STRING_EMAIL_ADDRESS label:STRING_EMAIL_EXAMPLE value:[self getEmail] mandatory:NO];
//    }
//    return _emailTextField;
//}
//
//- (JAButton *)continueWithoutLoginButton
//{
//    if (!VALID_NOTEMPTY(_continueWithoutLoginButton, JAButton)) {
//        _continueWithoutLoginButton = [[JAButton alloc] initAlternativeButtonWithTitle:STRING_CONTINUE_WITHOUT_LOGIN target:self action:@selector(continueWithoutLogin)];
//        CGFloat yOffset = CGRectGetMaxY(self.continueToLoginButton.frame) + kContinueLogin2OrMess;
//        /*if ([[RICountryConfiguration getCurrentConfiguration].facebookAvailable boolValue]){
//            yOffset = CGRectGetMaxY(self.facebookButton.frame) + kFacebookButton2ContinueWithout;
//        }*/
//        [_continueWithoutLoginButton setFrame:CGRectMake((self.view.width - kWidth)/2, yOffset, kWidth, kBottomDefaultHeight)];
//        if (self.checkout)
//        {
//            [_continueWithoutLoginButton setHidden:NO];
//        }else{
//            [_continueWithoutLoginButton setHidden:YES];
//        }
//    }
//    return _continueWithoutLoginButton;
//}
//
//- (JAButton *)continueToLoginButton
//{
//    if (!VALID_NOTEMPTY(_continueToLoginButton, JAButton)) {
//        CGFloat yOffset = CGRectGetMaxY(self.emailTextField.frame) + kEmail2ContinueLogin;
//        _continueToLoginButton = [[JAButton alloc] initButtonWithTitle:[STRING_CONTINUE uppercaseString] target:self action:@selector(checkEmail)];
//        [_continueToLoginButton setFrame:CGRectMake((self.view.width - kWidth)/2, yOffset, kWidth, kBottomDefaultHeight)];
//    }
//    return _continueToLoginButton;
//}
//
//#pragma mark - view life cicle
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    self.navBarLayout.title = STRING_LOGIN;
//    self.navBarLayout.showCartButton = NO;
//    
//    [self.view setBackgroundColor:[UIColor whiteColor]];
//    
//    [self.view addSubview:self.mainScrollView];
//    [self.mainScrollView addSubview:self.userIcon];
//    [self.mainScrollView addSubview:self.casTitleLabel];
//    [self.mainScrollView addSubview:self.topMessageLabel];
//    [self.mainScrollView addSubview:self.casAccountServicesImagesView];
//    
//    [self.mainScrollView addSubview:self.emailTextField];
//    [self.mainScrollView addSubview:self.continueToLoginButton];
// 
//    [self.mainScrollView addSubview:self.continueWithoutLoginButton];
//    
//    CGFloat height = CGRectGetMaxY(self.continueToLoginButton.frame) + kContinueLogin2OrMess;
//    if (self.checkout) {
//        height = CGRectGetMaxY(self.continueWithoutLoginButton.frame) + kContinueLogin2OrMess;
//    }
//    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.width, height)];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(hideKeyboard)
//                                                 name:kOpenMenuNotification
//                                               object:nil];
//    
//    [self.emailTextField.textField setDelegate:self];
//}
//
//- (void)viewWillLayoutSubviews
//{
//    [self.mainScrollView setXCenterAligned];
//    [self.mainScrollView setFrame:CGRectMake(self.mainScrollView.x, self.viewBounds.origin.y, self.mainScrollView.width, self.viewBounds.size.height)];
//}
//
//#pragma mark - Keyboard events
//
//- (void)keyboardWillShow:(NSNotification *)notification
//{
//    // get the size of the keyboard
//    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    CGFloat keyboardY = self.viewBounds.size.height - keyboardSize.height;
//    
//    UIView *firstResponder = [self findFirstResponder];
//    if (!firstResponder) {
//        return;
//    }
//    
//    if (CGRectGetMaxY(firstResponder.frame) < keyboardY) {
//        return;
//    }
//    
//    _offset = keyboardY - (CGRectGetMaxY(firstResponder.frame) - 6.f);
//    [self.mainScrollView setContentOffset:CGPointMake(0, -_offset) animated:YES];
//}
//
//- (void)keyboardWillHide:(NSNotification *)notification
//{
//    [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//}
//
//- (void)hideKeyboard
//{
//    [[self findFirstResponder] resignFirstResponder];
//}
//
//#pragma mark - TextField delegate
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{
//    [textField resignFirstResponder];
//    return YES;
//}
//
//- (UIView *)findFirstResponder
//{
//    if ([self.emailTextField.textField isFirstResponder]) {
//        return self.emailTextField;
//    }
//    return nil;
//}
//
//#pragma mark - Button actions
//
//#pragma mark - Continue Button Action
//
//- (void)checkEmail
//{
//    if (![self isFirstCheckChecked]) {
//        return;
//    }
//    [self showLoading];
//    [RICustomer checkEmail:self.emailTextField.textField.text successBlock:^(BOOL knownEmail, RICustomer *customerAlreadyLoggedIn) {
//        
//        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
//        
//        [self.emailTextField cleanError];
//        
//        if (VALID_NOTEMPTY(customerAlreadyLoggedIn, RICustomer)) {
//            NSMutableDictionary *userInfo = [NSMutableDictionary new];
//            if (self.fromSideMenu) {
//                [userInfo setObject:@YES forKey:@"from_side_menu"];
//            }
//            [[NSNotificationCenter defaultCenter] postNotificationName:kRunBlockAfterAuthenticationNotification object:self.nextStepBlock userInfo:userInfo];
//            [self hideLoading];
//            return;
//        }
//        
//        NSMutableDictionary *userInfo;
//        if (!VALID_NOTEMPTY(self.userInfo, NSDictionary)) {
//            userInfo = [NSMutableDictionary new];
//        }else{
//            userInfo = [self.userInfo mutableCopy];
//        }
//        
//        [userInfo setObject: self.emailTextField.textField.text forKey:@"email"];
//        [userInfo setObject:[NSNumber numberWithBool:self.checkout] forKey:@"checkout"];
//        
//        if (knownEmail) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification object:self.nextStepBlock userInfo:userInfo];
//        } else {
//            [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignUpScreenNotification object:self.nextStepBlock userInfo:userInfo];
//        }
//        [self hideLoading];
//    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorObject) {
//        
//        NSString *errorMessage = @"invalid email";
//        if (VALID_NOTEMPTY(errorObject, NSArray)) {
//            if (VALID_NOTEMPTY([errorObject firstObject], NSString)) {
//                errorMessage = [errorObject firstObject];
//            }else if (VALID_NOTEMPTY([[errorObject firstObject] objectForKey:@"message"], NSString)) {
//                errorMessage = [[errorObject firstObject] objectForKey:@"message"];
//            }
//        }
//        
//        [self onErrorResponse:apiResponse messages:@[errorMessage] showAsMessage:YES selector:@selector(checkEmail) objects:nil];
//        
//        [self hideLoading];
//    }];
//}
//
//- (NSString *)getEmail
//{
//    NSString* emailKeyForCountry = [NSString stringWithFormat:@"%@_%@", kRememberedEmail, [RIApi getCountryIsoInUse]];
//    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:emailKeyForCountry];
//    if(VALID_NOTEMPTY(email, NSString))
//    {
//        return email;
//    }
//    return @"";
//}
//
//- (void)continueWithoutLogin
//{
//    if (![self isFirstCheckChecked]) {
//        return;
//    }
//    [self showLoading];
//    [RICustomer signUpAccount:self.emailTextField.textField.text successBlock:^(id object){
//        
//        [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
//        [self.emailTextField cleanError];
//        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
//        [trackingDictionary setValue:@"Checkout" forKey:kRIEventLocationKey];
//        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventSignupSuccess]
//                                                  data:trackingDictionary];
//        
//        [self hideLoading];
//        
////        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
//                                                            object:nil];
//        
//        NSDictionary *responseDictionary = (NSDictionary *)object;
//        NSString* nextStep = [responseDictionary objectForKey:@"next_step"];
//        
//        [self.navigationController popViewControllerAnimated:NO];
//        
//        [JAUtils goToNextStep:nextStep
//                     userInfo:nil];
//        
//    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorObject) {
//        
//        NSString *errorMessage = @"invalid email";
//        if (VALID_NOTEMPTY([errorObject firstObject], NSString))
//        {
//            errorMessage = [errorObject firstObject];
//        }else if (VALID_NOTEMPTY([[errorObject firstObject] objectForKey:@"message"], NSString)) {
//            errorMessage = [[errorObject firstObject] objectForKey:@"message"];
//        }
//        [self.emailTextField setError:errorMessage];
//        
//        [self onErrorResponse:apiResponse messages:@[errorMessage] showAsMessage:YES selector:@selector(continueWithoutLogin) objects:nil];
//        
//        [self hideLoading];
//    }];
//}
//
//- (BOOL)isFirstCheckChecked
//{
//    if (!VALID_NOTEMPTY(self.emailTextField.textField.text, NSString)) {
//        [self.emailTextField.textField setDelegate:self];
//        NSString *errorMessage = @"invalid email";
//        [self.emailTextField setError:@""];
//        [self onErrorResponse:RIApiResponseSuccess messages:@[errorMessage] showAsMessage:YES selector:nil objects:nil];
//        return NO;
//    }
//    return YES;
//}
//
//+ (void)goToCheckoutWithBlock:(void (^)(void))authenticatedBlock
//{
//    [self authenticateAndExecuteBlock:authenticatedBlock showBackButtonForAuthentication:YES showContinueWithoutLogin:YES];
//}
//
//+ (void)authenticateAndExecuteBlock:(void (^)(void))authenticatedBlock showBackButtonForAuthentication:(BOOL)backButton
//{
//    [self authenticateAndExecuteBlock:authenticatedBlock showBackButtonForAuthentication:backButton showContinueWithoutLogin:NO];
//}
//
//+ (void)authenticateAndExecuteBlock:(void (^)(void))authenticatedBlock showBackButtonForAuthentication:(BOOL)backButton showContinueWithoutLogin:(BOOL)continueButton {
//    if([RICustomer checkIfUserIsLogged]) {
//        authenticatedBlock();
//    } else {
//        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
//        [userInfo setObject:[NSNumber numberWithBool:continueButton] forKey:@"continue_button"];
//        [userInfo setObject:[NSNumber numberWithBool:backButton] forKey:@"shows_back_button"];
//        [[NSNotificationCenter defaultCenter] postNotificationName:kShowAuthenticationScreenNotification object:authenticatedBlock userInfo:userInfo];
//    }
//}
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    if (self.emailTextField.hasError) {
//        [self.emailTextField cleanError];
//    }
//    return YES;
//}
//
//- (void)accountServicesViewChange {
//    [self.emailTextField setYBottomOf:self.casAccountServicesImagesView at:kAccountServices2Email];
//    [self.continueToLoginButton setYBottomOf:self.emailTextField at:kEmail2ContinueLogin];
//    [self.orView setYBottomOf:self.continueToLoginButton at:kContinueLogin2OrMess];
//    //[self.facebookButton setYBottomOf:self.orView at:kOrMess2FacebookButton];
//    //[self.continueWithoutLoginButton setYBottomOf:self.facebookButton at:kFacebookButton2ContinueWithout];
//}
//
//#pragma mark - PerformanceTrackerProtocol
//-(NSString *)getPerformanceTrackerScreenName {
//    return @"Authentication";
//}
//
//@end
