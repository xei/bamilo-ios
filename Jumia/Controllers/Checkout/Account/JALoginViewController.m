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
#import "JAOrderSummaryView.h"
#import <FacebookSDK/FacebookSDK.h>

@interface JALoginViewController ()
<
FBLoginViewDelegate
>

@property (assign, nonatomic) BOOL isAnimationRunning;
@property (assign, nonatomic) NSInteger numberOfFormsToLoad;

// Steps
@property (weak, nonatomic) IBOutlet UIImageView *stepBackground;
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

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
@property (strong, nonatomic) UIButton *facebookLoginButton;

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
@property (strong, nonatomic) UIButton *facebookSingupButton;

@property (assign, nonatomic) BOOL loadFailed;
@property (assign, nonatomic) RIApiResponse apiResponse;

@property (nonatomic, strong)JAOrderSummaryView* orderSummaryView;

@property (nonatomic, assign)CGRect mainLandscapeRect;
@property (nonatomic, assign)CGRect subLandscapeRect;
@property (nonatomic, assign)CGRect mainPortraitRect;

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
    
    self.stepBackground.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepView.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepIcon.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepLabel.translatesAutoresizingMaskIntoConstraints = YES;
    [self.stepLabel setText:STRING_CHECKOUT_ABOUT_YOU];
    self.loginView.layer.cornerRadius = 5.0f;
    
    self.loginView.translatesAutoresizingMaskIntoConstraints = YES;
    
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat margin = 6.0f;
    CGFloat orderSummaryY = self.stepBackground.frame.size.height + margin;
    CGFloat orderSummaryWidth = 250.0f;
    CGFloat orderSummaryX = 768.0f;
    self.orderSummaryView = [[JAOrderSummaryView alloc] initWithFrame:CGRectMake(orderSummaryX,
                                                                                 orderSummaryY,
                                                                                 orderSummaryWidth,
                                                                                 self.view.frame.size.height - orderSummaryY)];
    if (VALID_NOTEMPTY(self.cart, RICart)) {
        [self.orderSummaryView loadWithCart:self.cart];
    } else {
        [self getCart];
    }
    [self.view addSubview:self.orderSummaryView];
    
    [self setupViews:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    
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
           if(!self.loadFailed)
           {
               self.apiResponse = apiResponse;
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
           if(!self.loadFailed)
           {
               self.apiResponse = apiResponse;
           }
           
           self.loadFailed = YES;
           self.numberOfFormsToLoad--;
       }];
}

- (void)getCart
{
    [self showLoading];
    [RICart getCartWithSuccessBlock:^(RICart *cartData) {
        if (VALID_NOTEMPTY(self.orderSummaryView, JAOrderSummaryView) && VALID_NOTEMPTY(cartData.cartItems, NSArray)) {
            [self.orderSummaryView loadWithCart:cartData];
        }
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
        [self hideLoading];
    }];
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    self.isAnimationRunning = NO;
    
    [self setupStepView:width toInterfaceOrientation:toInterfaceOrientation];
    
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.orderSummaryView.hidden = NO;
    } else {
        self.orderSummaryView.hidden = YES;
    }

    CGFloat margin = 6.0f;
    CGFloat componentWidth;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        componentWidth = 744.0f;
    } else {
        componentWidth = 296.0f;
    }
    
    for(UIView *view in self.loginDynamicForm.formViews) {
        [view setFrame:CGRectMake(view.frame.origin.x,
                                  view.frame.origin.y,
                                  componentWidth + margin*2, //form already has its own margins
                                  view.frame.size.height)];
    }
    
    for(UIView *view in self.signupDynamicForm.formViews) {
        [view setFrame:CGRectMake(view.frame.origin.x,
                                  view.frame.origin.y,
                                  componentWidth + margin*2, //form already has its own margins
                                  view.frame.size.height)];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    CGFloat newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        newWidth = self.view.frame.size.width;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:toInterfaceOrientation];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    CGFloat newWidth = self.view.frame.size.width;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    }
    
    [self setupViews:newWidth toInterfaceOrientation:self.interfaceOrientation];
        
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void) setupStepView:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat stepViewLeftMargin = 25.0f;
    NSString *stepBackgroundImageName = @"headerCheckoutStep1";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            stepViewLeftMargin =  329.0f;
            stepBackgroundImageName = @"headerCheckoutStep1Landscape";
        }
        else
        {
            stepViewLeftMargin = 202.0f;
            stepBackgroundImageName = @"headerCheckoutStep1Portrait";
        }
    }
    UIImage *stepBackgroundImage = [UIImage imageNamed:stepBackgroundImageName];
    
    [self.stepBackground setImage:stepBackgroundImage];
    [self.stepBackground setFrame:CGRectMake(self.stepBackground.frame.origin.x,
                                             self.stepBackground.frame.origin.y,
                                             stepBackgroundImage.size.width,
                                             stepBackgroundImage.size.height)];
    
    [self.stepView setFrame:CGRectMake(stepViewLeftMargin,
                                       self.stepView.frame.origin.y,
                                       self.stepView.frame.size.width,
                                       self.stepView.frame.size.height)];
    [self.stepLabel sizeToFit];
    
    CGFloat horizontalMargin = 6.0f;
    CGFloat marginBetweenIconAndLabel = 5.0f;
    CGFloat realWidth = self.stepIcon.frame.size.width + marginBetweenIconAndLabel + self.stepLabel.frame.size.width - (2 * horizontalMargin);
    
    if(self.stepView.frame.size.width >= realWidth)
    {
        CGFloat xStepIconValue = ((self.stepView.frame.size.width - realWidth) / 2) - horizontalMargin;
        [self.stepIcon setFrame:CGRectMake(xStepIconValue,
                                           self.stepIcon.frame.origin.y,
                                           self.stepIcon.frame.size.width,
                                           self.stepIcon.frame.size.height)];
        
        [self.stepLabel setFrame:CGRectMake(CGRectGetMaxX(self.stepIcon.frame) + marginBetweenIconAndLabel,
                                            0.0f,
                                            self.stepLabel.frame.size.width,
                                            self.stepView.frame.size.height)];
    }
    else
    {
        [self.stepIcon setFrame:CGRectMake(horizontalMargin,
                                           self.stepIcon.frame.origin.y,
                                           self.stepIcon.frame.size.width,
                                           self.stepIcon.frame.size.height)];
        
        [self.stepLabel setFrame:CGRectMake(CGRectGetMaxX(self.stepIcon.frame) + marginBetweenIconAndLabel,
                                            0.0f,
                                            (self.stepView.frame.size.width - self.stepIcon.frame.size.width - marginBetweenIconAndLabel - (2 * horizontalMargin)),
                                            self.stepView.frame.size.height)];
    }
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
        if(RIApiResponseMaintenancePage == self.apiResponse)
        {
            [self showMaintenancePage:@selector(getForms) objects:nil];
        }
        else
        {
            BOOL hasNoConnection = NO;
            if(RIApiResponseNoInternetConnection == self.apiResponse)
            {
                hasNoConnection = YES;
            }
            [self showErrorView:hasNoConnection startingY:0.0f selector:@selector(getForms) objects:nil];
        }
    }
    
    [self hideLoading];
}

- (void) finishingSetupViews
{
    CGFloat componentWidth;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        componentWidth = 744.0f;
    } else {
        componentWidth = 296.0f;
    }
    
    
    self.loginFormHeight += 15.0f;
    // Login
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeFullPortrait_normal"] forState:UIControlStateNormal];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeFullPortrait_highlighted"] forState:UIControlStateHighlighted];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeFullPortrait_highlighted"] forState:UIControlStateSelected];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeFullPortrait_disabled"] forState:UIControlStateDisabled];
    } else {
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
        [self.loginButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    }
    [self.loginButton setFrame:CGRectMake(6.0f, self.loginFormHeight, componentWidth, 44.0f)];
    
    [self.loginButton setTitle:STRING_LOGIN forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.loginFormView addSubview:self.loginButton];
    self.loginFormHeight += self.loginButton.frame.size.height;
    
    self.loginFormHeight += 5.0f;
    // Forgot Password
    self.forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotButton setFrame:CGRectMake(6.0f, self.loginFormHeight, componentWidth, 30.0f)];
    [self.forgotButton setBackgroundColor:[UIColor clearColor]];
    [self.forgotButton setTitle:STRING_FORGOT_PASSWORD forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.forgotButton addTarget:self action:@selector(forgotButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.loginFormView addSubview:self.forgotButton];
    self.loginFormHeight += self.forgotButton.frame.size.height;
    
    // Separator
    CGFloat centerWidth = 54.0f;
    CGFloat halfSeparatorWidth = (componentWidth - centerWidth) / 2;
    
    self.facebookLoginSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.facebookLoginSeparatorLabel = [[UILabel alloc] init];
    [self.facebookLoginSeparatorLabel setText:STRING_OR];
    [self.facebookLoginSeparatorLabel setTextColor:UIColorFromRGB(0xcccccc)];
    [self.facebookLoginSeparatorLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.facebookLoginSeparatorLabel sizeToFit];
    
    self.facebookLoginSeparatorLeftView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.facebookLoginSeparatorLeftView setBackgroundColor:UIColorFromRGB(0xcccccc)];
    
    
    [self.facebookLoginSeparatorLeftView setFrame:CGRectMake(0.0f, (self.facebookLoginSeparatorLabel.frame.size.height - 1.0f) / 2.0f, halfSeparatorWidth, 1.0f)];
    
    [self.facebookLoginSeparatorLabel setFrame:CGRectMake(CGRectGetMaxX(self.facebookLoginSeparatorLeftView.frame) + 15.0f, 0.0f, self.facebookLoginSeparatorLabel.frame.size.width, self.facebookLoginSeparatorLabel.frame.size.height)];
    
    self.facebookLoginSeparatorRightView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.facebookLoginSeparatorRightView setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self.facebookLoginSeparatorRightView setFrame:CGRectMake(halfSeparatorWidth + centerWidth, (self.facebookLoginSeparatorLabel.frame.size.height - 1.0f) / 2.0f, halfSeparatorWidth, 1.0f)];
    
    [self.facebookLoginSeparator addSubview:self.facebookLoginSeparatorLeftView];
    [self.facebookLoginSeparator addSubview:self.facebookLoginSeparatorLabel];
    [self.facebookLoginSeparator addSubview:self.facebookLoginSeparatorRightView];
    
    [self.facebookLoginSeparator setFrame:CGRectMake(6.0f, self.loginFormHeight, componentWidth, self.facebookLoginSeparatorLabel.frame.size.height)];
    [self.loginFormView addSubview:self.facebookLoginSeparator];
    self.loginFormHeight += self.facebookLoginSeparator.frame.size.height;
    
    self.loginFormHeight += 11.0f;
    // Facebook Login
    self.facebookLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookLoginButton setFrame:CGRectMake(6.0f, self.loginFormHeight, componentWidth, 44.0f)];
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"facebookFullPortrait_normal"] forState:UIControlStateNormal];
        [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"facebookFullPortrait_highlighted"] forState:UIControlStateHighlighted];
        [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"facebookFullPortrait_highlighted"] forState:UIControlStateSelected];
    } else {
        [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"facebookMedium_normal"] forState:UIControlStateNormal];
        [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"facebookMedium_highlighted"] forState:UIControlStateHighlighted];
        [self.facebookLoginButton setBackgroundImage:[UIImage imageNamed:@"facebookMedium_highlighted"] forState:UIControlStateSelected];
    }
    [self.facebookLoginButton setTitle:STRING_LOGIN_WITH_FACEBOOK forState:UIControlStateNormal];
    [self.facebookLoginButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.facebookLoginButton addTarget:self action:@selector(facebookLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookLoginButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];

    [self.loginFormView addSubview:self.facebookLoginButton];
    self.loginFormHeight += self.facebookLoginButton.frame.size.height;
    
    self.signupFormHeight += 15.0f;
    // Signup
    self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.signUpButton setFrame:CGRectMake(6.0f, self.signupFormHeight, componentWidth, 44.0f)];
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeFullPortrait_normal"] forState:UIControlStateNormal];
        [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeFullPortrait_highlighted"] forState:UIControlStateHighlighted];
        [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeFullPortrait_highlighted"] forState:UIControlStateSelected];
        [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeFullPortrait_disabled"] forState:UIControlStateDisabled];
    } else {
        [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
        [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
        [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
        [self.signUpButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    }
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
    [self.facebookSignupSeparatorLeftView setFrame:CGRectMake(0.0f, (self.facebookSignupSeparatorLabel.frame.size.height - 1.0f) / 2.0f, halfSeparatorWidth, 1.0f)];
    
    [self.facebookSignupSeparatorLabel setFrame:CGRectMake(CGRectGetMaxX(self.facebookSignupSeparatorLeftView.frame) + 15.0f, 0.0f, self.facebookSignupSeparatorLabel.frame.size.width, self.facebookSignupSeparatorLabel.frame.size.height)];
    
    self.facebookSignupSeparatorRightView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.facebookSignupSeparatorRightView setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self.facebookSignupSeparatorRightView setFrame:CGRectMake(halfSeparatorWidth + centerWidth, (self.facebookSignupSeparatorLabel.frame.size.height - 1.0f) / 2.0f, halfSeparatorWidth, 1.0f)];
    
    [self.facebookSignupSeparator addSubview:self.facebookSignupSeparatorLeftView];
    [self.facebookSignupSeparator addSubview:self.facebookSignupSeparatorLabel];
    [self.facebookSignupSeparator addSubview:self.facebookSignupSeparatorRightView];
    
    [self.facebookSignupSeparator setFrame:CGRectMake(6.0f, self.signupFormHeight, componentWidth, self.facebookSignupSeparatorLabel.frame.size.height)];
    [self.signUpFormView addSubview:self.facebookSignupSeparator];
    self.signupFormHeight += self.facebookSignupSeparator.frame.size.height;
    
    self.signupFormHeight += 11.0f;
    // Facebook Signup
    self.facebookSingupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.facebookSingupButton setFrame:CGRectMake(6.0f, self.signupFormHeight, componentWidth, 44.0f)];
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        [self.facebookSingupButton setBackgroundImage:[UIImage imageNamed:@"facebookFullPortrait_normal"] forState:UIControlStateNormal];
        [self.facebookSingupButton setBackgroundImage:[UIImage imageNamed:@"facebookFullPortrait_highlighted"] forState:UIControlStateHighlighted];
        [self.facebookSingupButton setBackgroundImage:[UIImage imageNamed:@"facebookFullPortrait_highlighted"] forState:UIControlStateSelected];
    } else {
        [self.facebookSingupButton setBackgroundImage:[UIImage imageNamed:@"facebookMedium_normal"] forState:UIControlStateNormal];
        [self.facebookSingupButton setBackgroundImage:[UIImage imageNamed:@"facebookMedium_highlighted"] forState:UIControlStateHighlighted];
        [self.facebookSingupButton setBackgroundImage:[UIImage imageNamed:@"facebookMedium_highlighted"] forState:UIControlStateSelected];
    }
    [self.facebookSingupButton setTitle:STRING_SIGNUP_WITH_FACEBOOK forState:UIControlStateNormal];
    [self.facebookSingupButton setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
    [self.facebookSingupButton addTarget:self action:@selector(facebookLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.facebookSingupButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    
    [self.signUpFormView addSubview:self.facebookSingupButton];
    self.signupFormHeight += self.facebookSingupButton.frame.size.height;
    
    [self setupViews:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
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

- (void)facebookLoginButtonPressed:(id)sender
{
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
                                                          
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                                                              object:nil];
                                                          
                                                          if([nextStep isEqualToString:@"createAddress"])
                                                          {
                                                              NSDictionary *userInfo = [NSDictionary dictionaryWithObjects:@[[NSNumber numberWithBool:YES], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO]] forKeys:@[@"is_billing_address", @"is_shipping_address", @"show_back_button"]];
                                                              
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddAddressScreenNotification
                                                                                                                  object:nil
                                                                                                                userInfo:userInfo];
                                                          }
                                                          else
                                                          {
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:kShowCheckoutAddressesScreenNotification
                                                                                                                  object:nil
                                                                                                                userInfo:nil];
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
         else
         {
             [self showMessage:[error description] success:NO];
         }
     }];
    
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

@end
