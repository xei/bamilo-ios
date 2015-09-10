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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "UIView+Mirror.h"
#import "UIImage+Mirror.h"

@interface JALoginViewController ()

@property (assign, nonatomic) BOOL isAnimationRunning;
@property (assign, nonatomic) NSInteger numberOfFormsToLoad;

// Steps
@property (weak, nonatomic) IBOutlet UIImageView *stepBackground;
@property (weak, nonatomic) IBOutlet UIView *stepView;
@property (weak, nonatomic) IBOutlet UIImageView *stepIcon;
@property (weak, nonatomic) IBOutlet UILabel *stepLabel;

// Login
@property (strong, nonatomic) JADynamicForm *loginDynamicForm;
@property (strong, nonatomic) UIView *loginView;
@property (strong, nonatomic) UIView *loginSeparator;
@property (strong, nonatomic) UILabel *loginLabel;
@property (strong, nonatomic) UIImageView *loginArrow;
@property (strong, nonatomic) UIView *loginFormView;

@property (assign, nonatomic) CGFloat initialLoginFormHeight;
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
@property (strong, nonatomic) UIView *signUpView;
@property (strong, nonatomic) UIView *signUpSeparator;
@property (strong, nonatomic) UILabel *signUpLabel;
@property (strong, nonatomic) UIImageView *signUpArrow;
@property (strong, nonatomic) NSLayoutConstraint *signUpViewConstrains;
@property (strong, nonatomic) UIView *signUpFormView;
@property (strong, nonatomic)  NSLayoutConstraint *signUpViewFormConstrains;
@property (assign, nonatomic) CGFloat initialSignupFormHeight;
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
@property (assign, nonatomic) CGFloat orderSummaryOriginalHeight;

@property (strong, nonatomic) UIView *viewToScroll;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) CGFloat scrollViewOriginalHeight;
@property (strong, nonatomic) JACheckBoxComponent* checkBoxComponent;
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
    
    self.stepBackground.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepView.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepIcon.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepLabel.translatesAutoresizingMaskIntoConstraints = YES;
    self.stepLabel.font = [UIFont fontWithName:kFontBoldName size:self.stepLabel.font.pointSize];
    [self.stepLabel setText:STRING_CHECKOUT_ABOUT_YOU];
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.viewToScroll = [[UIView alloc] init];
    
    UITapGestureRecognizer *showLoginViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(showLogin)];
    
    self.loginView = [[UIView alloc] init];
    [self.loginView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.loginView.layer.cornerRadius = 5.0f;
    [self.loginView addGestureRecognizer:showLoginViewTap];
    
    self.loginLabel = [[UILabel alloc] init];
    [self.loginLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.loginLabel setBackgroundColor:[UIColor clearColor]];
    [self.loginLabel setText:STRING_LOGIN];
    [self.loginLabel setFont:[UIFont fontWithName:kFontLightName size:13.0f]];
    [self.loginLabel sizeToFit];
    [self.loginView addSubview:self.loginLabel];
    
    self.loginArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowOrangeClosed"]];
    if (RI_IS_RTL) {
        [self.loginArrow flipViewImage];
    }
    [self.loginView addSubview:self.loginArrow];
    
    self.loginSeparator = [[UIImageView alloc] init];
    [self.loginSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.loginSeparator setHidden:YES];
    [self.loginView addSubview:self.loginSeparator];
    
    self.loginFormView = [[UIView alloc] init];
    [self.loginFormView setHidden: YES];
    [self.loginView addSubview:self.loginFormView];
    [self.viewToScroll addSubview:self.loginView];
    
    UITapGestureRecognizer *showSignupViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(showSignup)];
    
    self.signUpView = [[UIView alloc]init];
    [self.signUpView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.signUpView.layer.cornerRadius = 5.0f;
    [self.signUpView addGestureRecognizer:showSignupViewTap];
    
    [self.signUpSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    
    
    self.signUpLabel = [[UILabel alloc] init];
    [self.signUpLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.signUpLabel setBackgroundColor:[UIColor clearColor]];
    [self.signUpLabel setText:STRING_SIGNUP];
    self.signUpLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    [self.signUpLabel sizeToFit];
    [self.signUpView addSubview:self.signUpLabel];
    
    self.signUpArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowOrangeClosed"]];
    if (RI_IS_RTL) {
        [self.signUpArrow flipViewImage];
    }
    [self.signUpView addSubview:self.signUpArrow];
    
    self.signUpSeparator = [[UIImageView alloc] init];
    [self.signUpSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.signUpView addSubview:self.signUpSeparator];
    
    self.signUpFormView = [[UIView alloc] init];
    [self.signUpFormView setHidden:YES];
    [self.signUpView addSubview:self.signUpFormView];
    [self.viewToScroll addSubview:self.signUpView];
    
    [self.scrollView addSubview:self.viewToScroll];
    
    self.orderSummaryView = [[JAOrderSummaryView alloc] init];
    [self.view addSubview:self.orderSummaryView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self didRotateFromInterfaceOrientation:0];
    
    [self getForms];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"CheckoutSignUp"];
}

- (void)getForms
{
    if(!self.apiResponse)
    {
        [self showLoading];
    }
    
    self.loadFailed = NO; //resetting to NO, it is turned to YES if it fails
    
    self.numberOfFormsToLoad = 2;
    [RIForm getForm:@"login"
       successBlock:^(RIForm *form) {
           
           self.loginDynamicForm = [[JADynamicForm alloc] initWithForm:form values:[self getEmail] startingPosition:7.0f hasFieldNavigation:YES];
           
           self.initialLoginFormHeight = 0.0f;
           
           for(UIView *view in self.loginDynamicForm.formViews)
           {
               [self.loginFormView addSubview:view];
               if(CGRectGetMaxY(view.frame) > self.initialLoginFormHeight)
               {
                   self.initialLoginFormHeight = CGRectGetMaxY(view.frame);
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
           self.initialSignupFormHeight = 0.0f;
           
           for(UIView *view in self.signupDynamicForm.formViews)
           {
               [self.signUpFormView addSubview:view];
               if(CGRectGetMaxY(view.frame) > self.initialSignupFormHeight)
               {
                   self.initialSignupFormHeight = CGRectGetMaxY(view.frame);
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

- (void)setup
{
    self.isAnimationRunning = NO;
    
    [self setupStepView:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    
    [self setupViews:self.view.frame.size.width toInterfaceOrientation:self.interfaceOrientation];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
        [self.checkBoxComponent flipViewPositionInsideSuperview];
    }
}

- (void) setupViews:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat margin = 6.0f;
    
    [self.scrollView setFrame:CGRectMake(0.0f,
                                         CGRectGetMaxY(self.stepView.frame),
                                         self.view.frame.size.width,
                                         self.view.frame.size.height - CGRectGetMaxY(self.stepView.frame))];
    
    self.scrollViewOriginalHeight = self.scrollView.frame.size.height;
    
    if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        self.orderSummaryView.hidden = NO;
    } else {
        self.orderSummaryView.hidden = YES;
    }
    
    self.loginView.frame = CGRectMake(margin,
                                      margin,
                                      self.viewToScroll.frame.size.width-margin*2,
                                      self.loginView.frame.size.height);
    
    self.loginLabel.frame = CGRectMake(margin,
                                       4.0f,
                                       self.loginView.frame.size.width - self.loginArrow.frame.size.width - margin*2,
                                       self.loginLabel.frame.size.height);
    self.loginLabel.textAlignment = NSTextAlignmentLeft;
    
    self.loginArrow.frame = CGRectMake(self.loginView.frame.size.width - self.loginArrow.frame.size.width - 6.0f,
                                       margin,
                                       self.loginArrow.frame.size.width,
                                       self.loginArrow.frame.size.height);
    
    self.loginSeparator.frame = CGRectMake(0.0f,
                                           26.0f,
                                           self.loginView.frame.size.width,
                                           1.0f);
    
    self.signUpView.frame = CGRectMake(margin,
                                       CGRectGetMaxY(self.loginView.frame) + margin,
                                       self.viewToScroll.frame.size.width-margin*2,
                                       self.signUpView.frame.size.height);
    
    self.signUpLabel.frame = CGRectMake(margin,
                                        4.0f,
                                        self.signUpView.frame.size.width - self.signUpArrow.frame.size.width - margin*2,
                                        self.signUpLabel.frame.size.height);
    self.signUpLabel.textAlignment = NSTextAlignmentLeft;
    
    [self.signUpArrow setFrame:CGRectMake(self.signUpView.frame.size.width - self.signUpArrow.frame.size.width - margin,
                                          margin,
                                          self.signUpArrow.frame.size.width,
                                          self.signUpArrow.frame.size.height)];
    
    self.signUpSeparator.frame = CGRectMake(0.0f,
                                            26.0f,
                                            self.signUpView.frame.size.width,
                                            1.0f);
    
    CGFloat componentWidth;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        componentWidth = 756.0f;
    } else {
        componentWidth = 308.0f;
    }
    [self.loginFormView setFrame:CGRectMake(self.loginFormView.frame.origin.x,
                                            CGRectGetMaxY(self.loginSeparator.frame),
                                            self.loginView.frame.size.width,
                                            self.loginView.frame.size.height)];
    
    [self.signUpFormView setFrame:CGRectMake(self.loginFormView.frame.origin.x,
                                             CGRectGetMaxY(self.signUpSeparator.frame),
                                             self.loginView.frame.size.width,
                                             self.loginView.frame.size.height)];
    
    for(UIView *view in self.loginDynamicForm.formViews) {
        [view setFrame:CGRectMake(view.frame.origin.x,
                                  view.frame.origin.y,
                                  componentWidth,
                                  view.frame.size.height)];
    }
    
    for(UIView *view in self.signupDynamicForm.formViews) {
        [view setFrame:CGRectMake(view.frame.origin.x,
                                  view.frame.origin.y,
                                  componentWidth,
                                  view.frame.size.height)];
    }
    
    
    CGFloat buttonWidth = componentWidth - margin*2;
    self.loginFormHeight = self.initialLoginFormHeight;
    self.loginFormHeight += 10.0f;
    [self.checkBoxComponent setFrame:CGRectMake(6.0f,
                                                self.loginFormHeight,
                                                self.checkBoxComponent.frame.size.width - 6.0f,
                                                self.checkBoxComponent.frame.size.height)];
    self.loginFormHeight += self.checkBoxComponent.frame.size.height + 10.0f;
    [self.loginButton setFrame:CGRectMake(6.0f, self.loginFormHeight, buttonWidth, 44.0f)];
    self.loginFormHeight += self.loginButton.frame.size.height;
    self.loginFormHeight += 5.0f;
    [self.forgotButton setFrame:CGRectMake(6.0f, self.loginFormHeight, buttonWidth, 30.0f)];
    self.loginFormHeight += self.forgotButton.frame.size.height;
    
    NSString *facebookImageNameFormatter = @"facebookMedium_%@";

    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        facebookImageNameFormatter = @"facebookMediumPortrait_%@";
        
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            facebookImageNameFormatter = @"facebookFullPortrait_%@";
        }
    }
    
    UIImage *facebookNormalImage = [UIImage imageNamed:[NSString stringWithFormat:facebookImageNameFormatter, @"normal"]];
    UIImage *facebookHighlightImage = [UIImage imageNamed:[NSString stringWithFormat:facebookImageNameFormatter, @"highlighted"]];
    
    CGFloat centerWidth = 54.0f;
    CGFloat halfSeparatorWidth = (buttonWidth - centerWidth) / 2;
    if ([[RICountryConfiguration getCurrentConfiguration].facebookAvailable boolValue]){
        [self.facebookLoginSeparator setFrame:CGRectMake(6.0f, self.loginFormHeight, buttonWidth, self.facebookLoginSeparatorLabel.frame.size.height)];
        CGFloat separatorWidth = self.facebookLoginSeparator.width/2 - self.facebookLoginSeparatorLabel.width/2 - 15;
        [self.facebookLoginSeparatorLeftView setFrame:CGRectMake(0.0f, (self.facebookLoginSeparatorLabel.frame.size.height - 1.0f) / 2.0f, separatorWidth, 1.0f)];
        [self.facebookLoginSeparatorLabel setFrame:CGRectMake(CGRectGetMaxX(self.facebookLoginSeparatorLeftView.frame) + 15.0f, 0.0f, self.facebookLoginSeparatorLabel.frame.size.width, self.facebookLoginSeparatorLabel.frame.size.height)];
        [self.facebookLoginSeparatorRightView setFrame:CGRectMake(self.facebookLoginSeparator.width - separatorWidth, (self.facebookLoginSeparatorLabel.frame.size.height - 1.0f) / 2.0f, separatorWidth, 1.0f)];
        self.loginFormHeight += self.facebookLoginSeparator.frame.size.height;
        
        self.loginFormHeight += 11.0f;
        
        [self.facebookLoginButton setFrame:CGRectMake(6.0f, self.loginFormHeight, buttonWidth, 44.0f)];
        [self.facebookLoginButton setBackgroundImage:facebookNormalImage forState:UIControlStateNormal];
        [self.facebookLoginButton setBackgroundImage:facebookHighlightImage forState:UIControlStateHighlighted];
        [self.facebookLoginButton setBackgroundImage:facebookHighlightImage forState:UIControlStateSelected];
        self.loginFormHeight += self.facebookLoginButton.frame.size.height;
    }
    
    self.signupFormHeight = self.initialSignupFormHeight;
    self.signupFormHeight += 15.0f;
    [self.signUpButton setFrame:CGRectMake(6.0f, self.signupFormHeight, buttonWidth, 44.0f)];
    self.signupFormHeight += self.signUpButton.frame.size.height;
    self.signupFormHeight += 12.0f;
    
    if ([[RICountryConfiguration getCurrentConfiguration].facebookAvailable boolValue]){
        
        [self.facebookSignupSeparator setFrame:CGRectMake(6.0f, self.signupFormHeight, buttonWidth, self.facebookSignupSeparatorLabel.frame.size.height)];
        CGFloat separatorWidth = self.facebookSignupSeparator.width/2 - self.facebookSignupSeparatorLabel.width/2 - 15;
        [self.facebookSignupSeparatorLeftView setFrame:CGRectMake(0.0f, (self.facebookSignupSeparatorLabel.frame.size.height - 1.0f) / 2.0f, separatorWidth, 1.0f)];
        [self.facebookSignupSeparatorLabel setFrame:CGRectMake(CGRectGetMaxX(self.facebookSignupSeparatorLeftView.frame) + 15.0f, 0.0f, self.facebookSignupSeparatorLabel.frame.size.width, self.facebookSignupSeparatorLabel.frame.size.height)];
        [self.facebookSignupSeparatorRightView setFrame:CGRectMake(self.facebookSignupSeparator.width - separatorWidth, (self.facebookSignupSeparatorLabel.frame.size.height - 1.0f) / 2.0f, separatorWidth, 1.0f)];
        self.signupFormHeight += self.facebookSignupSeparator.frame.size.height;
        self.signupFormHeight += 11.0f;
        [self.facebookSingupButton setFrame:CGRectMake(6.0f, self.signupFormHeight, buttonWidth, 44.0f)];
        [self.facebookSingupButton setBackgroundImage:facebookNormalImage forState:UIControlStateNormal];
        [self.facebookSingupButton setBackgroundImage:facebookHighlightImage forState:UIControlStateHighlighted];
        [self.facebookSingupButton setBackgroundImage:facebookHighlightImage forState:UIControlStateSelected];
        self.signupFormHeight += self.facebookSingupButton.frame.size.height;
    }
    
    [self.viewToScroll setFrame:CGRectMake(0.0f,
                                           0.0f,
                                           componentWidth + margin*2,
                                           CGRectGetMaxY(self.signUpView.frame) + 6.0f)];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             self.viewToScroll.frame.size.height);
    
    CGFloat orderSummaryY = self.stepBackground.frame.size.height;
    CGFloat orderSummaryWidth = 250.0f;
    CGFloat orderSummaryX = 768.0f;
    self.orderSummaryView.frame = CGRectMake(orderSummaryX,
                                             orderSummaryY,
                                             orderSummaryWidth,
                                             self.view.frame.size.height - orderSummaryY);
    self.orderSummaryOriginalHeight = self.orderSummaryView.frame.size.height;
    if (VALID_NOTEMPTY(self.cart, RICart)) {
        [self.orderSummaryView loadWithCart:self.cart];
    } else {
        [self getCart];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self showLoading];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setup];
    
    [self hideLoading];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self hideKeyboard];
}

- (void) hideKeyboard
{
    [self.loginDynamicForm resignResponder];
    [self.signupDynamicForm resignResponder];
}

- (void) setupStepView:(CGFloat)width toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat stepViewLeftMargin = 18.0f;
    NSString *stepBackgroundImageName = @"headerCheckoutStep1";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            stepViewLeftMargin =  303.0f;
            stepBackgroundImageName = @"headerCheckoutStep1Landscape";
        }
        else
        {
            stepViewLeftMargin = 175.0f;
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
                                       (stepBackgroundImage.size.height - self.stepView.frame.size.height) / 2,
                                       self.stepView.frame.size.width,
                                       stepBackgroundImage.size.height)];
    [self.stepLabel sizeToFit];
    
    CGFloat horizontalMargin = 6.0f;
    CGFloat marginBetweenIconAndLabel = 5.0f;
    CGFloat realWidth = self.stepIcon.frame.size.width + marginBetweenIconAndLabel + self.stepLabel.frame.size.width - (2 * horizontalMargin);
    
    if(self.stepView.frame.size.width >= realWidth)
    {
        CGFloat xStepIconValue = ((self.stepView.frame.size.width - realWidth) / 2) - horizontalMargin;
        [self.stepIcon setFrame:CGRectMake(xStepIconValue,
                                           ceilf(((self.stepView.frame.size.height - self.stepIcon.frame.size.height) / 2) - 1.0f),
                                           self.stepIcon.frame.size.width,
                                           self.stepIcon.frame.size.height)];
        
        [self.stepLabel setFrame:CGRectMake(CGRectGetMaxX(self.stepIcon.frame) + marginBetweenIconAndLabel,
                                            4.0f,
                                            self.stepLabel.frame.size.width,
                                            12.0f)];
    }
    else
    {
        [self.stepIcon setFrame:CGRectMake(horizontalMargin,
                                           ceilf(((self.stepView.frame.size.height - self.stepIcon.frame.size.height) / 2) - 1.0f),
                                           self.stepIcon.frame.size.width,
                                           self.stepIcon.frame.size.height)];
        
        [self.stepLabel setFrame:CGRectMake(CGRectGetMaxX(self.stepIcon.frame) + marginBetweenIconAndLabel,
                                            4.0f,
                                            (self.stepView.frame.size.width - self.stepIcon.frame.size.width - marginBetweenIconAndLabel - (2 * horizontalMargin)),
                                            12.0f)];
    }
    
    if(RI_IS_RTL){
        
        [self.stepBackground setImage:[stepBackgroundImage flipImageWithOrientation:UIImageOrientationUpMirrored]];
    }
}


- (void) finishedFormsLoading
{
    [self hideLoading];
    
    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
    
    if(!self.loadFailed)
    {
        [self removeErrorView];
        [self finishingSetupViews];
        [self setup];
        [self.checkBoxComponent setHidden:YES];
        [self showLogin];
    }
    else
    {
        if(RIApiResponseMaintenancePage == self.apiResponse)
        {
            [self showMaintenancePage:@selector(getForms) objects:nil];
        }
        else if(RIApiResponseKickoutView == self.apiResponse)
        {
            [self showKickoutView:@selector(getForms) objects:nil];
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
}

- (void) finishingSetupViews
{
    CGFloat componentWidth;
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM()) {
        componentWidth = 740.0f;
    } else {
        componentWidth = 296.0f;
    }
    self.checkBoxComponent = [JACheckBoxComponent getNewJACheckBoxComponent];
    self.checkBoxComponent.labelText.font = [UIFont fontWithName:kFontRegularName size:self.checkBoxComponent.labelText.font.pointSize];
    [self.checkBoxComponent.labelText setText:STRING_REMEMBER_EMAIL];
    [self.checkBoxComponent.switchComponent setOn:YES];
    [self.loginFormView addSubview:self.checkBoxComponent];
    
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
    
    [self.loginButton setTitle:STRING_LOGIN forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(loginButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:16.0f]];
    [self.loginFormView addSubview:self.loginButton];
    
    // Forgot Password
    self.forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotButton setBackgroundColor:[UIColor clearColor]];
    [self.forgotButton setTitle:STRING_FORGOT_PASSWORD forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
    [self.forgotButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.forgotButton addTarget:self action:@selector(forgotButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:11.0f]];
    [self.loginFormView addSubview:self.forgotButton];
    
    if ([[RICountryConfiguration getCurrentConfiguration].facebookAvailable boolValue]){
        
        // Separator
        
        self.facebookLoginSeparator = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.facebookLoginSeparatorLabel = [[UILabel alloc] init];
        [self.facebookLoginSeparatorLabel setText:STRING_OR];
        [self.facebookLoginSeparatorLabel setTextColor:UIColorFromRGB(0xcccccc)];
        [self.facebookLoginSeparatorLabel setFont:[UIFont fontWithName:kFontRegularName size:16.0f]];
        [self.facebookLoginSeparatorLabel sizeToFit];
        
        self.facebookLoginSeparatorLeftView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.facebookLoginSeparatorLeftView setBackgroundColor:UIColorFromRGB(0xcccccc)];
        
        self.facebookLoginSeparatorRightView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.facebookLoginSeparatorRightView setBackgroundColor:UIColorFromRGB(0xcccccc)];
        
        [self.facebookLoginSeparator addSubview:self.facebookLoginSeparatorLeftView];
        [self.facebookLoginSeparator addSubview:self.facebookLoginSeparatorLabel];
        [self.facebookLoginSeparator addSubview:self.facebookLoginSeparatorRightView];
        
        [self.loginFormView addSubview:self.facebookLoginSeparator];
        
        self.facebookLoginButton = [UIButton new];
        [self.facebookLoginButton setTitle:STRING_LOGIN_WITH_FACEBOOK forState:UIControlStateNormal];
        [self.facebookLoginButton addTarget:self action:@selector(facebookLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.facebookLoginButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:self.facebookLoginButton.titleLabel.font.pointSize]];
        [self.loginFormView addSubview:self.facebookLoginButton];
    }
    // Signup
    self.signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    [self.signUpButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:16.0f]];
    [self.signUpFormView addSubview:self.signUpButton];
    
    if ([[RICountryConfiguration getCurrentConfiguration].facebookAvailable boolValue]){
        // Separator
        self.facebookSignupSeparator = [[UIView alloc] initWithFrame:CGRectZero];
        
        self.facebookSignupSeparatorLabel = [[UILabel alloc] init];
        [self.facebookSignupSeparatorLabel setText:STRING_OR];
        [self.facebookSignupSeparatorLabel setTextColor:UIColorFromRGB(0xcccccc)];
        [self.facebookSignupSeparatorLabel setFont:[UIFont fontWithName:kFontRegularName size:16.0f]];
        [self.facebookSignupSeparatorLabel sizeToFit];
        
        self.facebookSignupSeparatorLeftView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.facebookSignupSeparatorLeftView setBackgroundColor:UIColorFromRGB(0xcccccc)];
        
        self.facebookSignupSeparatorRightView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.facebookSignupSeparatorRightView setBackgroundColor:UIColorFromRGB(0xcccccc)];
        
        [self.facebookSignupSeparator addSubview:self.facebookSignupSeparatorLeftView];
        [self.facebookSignupSeparator addSubview:self.facebookSignupSeparatorLabel];
        [self.facebookSignupSeparator addSubview:self.facebookSignupSeparatorRightView];
        
        [self.signUpFormView addSubview:self.facebookSignupSeparator];
        
        // Facebook Signup
        self.facebookSingupButton = [UIButton new];
        [self.facebookSingupButton setTitle:STRING_SIGNUP_WITH_FACEBOOK forState:UIControlStateNormal];
        [self.facebookSingupButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:self.facebookSingupButton.titleLabel.font.pointSize]];
        [self.facebookSingupButton addTarget:self action:@selector(facebookLoginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.signUpFormView addSubview:self.facebookSingupButton];
    }
}

- (void) showLogin
{
    if(!self.isAnimationRunning)
    {
        self.isAnimationRunning = YES;
        [self hideSignup];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            
            [self.loginFormView setFrame:CGRectMake(self.loginFormView.frame.origin.x,
                                                    self.loginFormView.frame.origin.y,
                                                    self.loginFormView.frame.size.width,
                                                    self.loginFormHeight)];
            
            [self.loginView setFrame:CGRectMake(self.loginView.frame.origin.x,
                                                6.0,
                                                self.loginView.frame.size.width,
                                                27.0f + self.loginFormHeight + 6.0f)];
        } completion:^(BOOL finished) {
            [self.loginArrow setImage:[UIImage imageNamed:@"arrowOrangeOpened"]];
            [self.loginFormView setHidden:NO];
            [self.loginSeparator setHidden:NO];
            [self.checkBoxComponent setHidden:NO];
            self.isAnimationRunning = NO;
            [self.signUpSeparator setHidden:YES];
            
            [self.viewToScroll setFrame:CGRectMake(self.viewToScroll.frame.origin.x,
                                                   self.viewToScroll.frame.origin.y,
                                                   self.viewToScroll.frame.size.width,
                                                   CGRectGetMaxY(self.signUpView.frame)+6.0f)];
            
            [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(self.signUpView.frame)+6.0f)];
        }];
    }
}

- (void) hideLogin
{
    [self.loginFormView setHidden:YES];
    
    [self.loginFormView setFrame:CGRectMake(self.loginFormView.frame.origin.x,
                                            self.loginFormView.frame.origin.y,
                                            self.loginFormView.frame.size.width,
                                            0.0f)];
    
    [self.loginView setFrame:CGRectMake(self.loginView.frame.origin.x,
                                        6.0f,
                                        self.loginView.frame.size.width,
                                        26.0f)];
    [self.checkBoxComponent setHidden:YES];
    [self.loginSeparator setHidden:YES];
    [self.loginArrow setImage:[UIImage imageNamed:@"arrowOrangeClosed"]];
    if (RI_IS_RTL) {
        [self.loginArrow flipViewImage];
    }
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
            
            [self.signUpView setFrame:CGRectMake(self.signUpView.frame.origin.x,
                                                 37.0f,
                                                 self.signUpView.frame.size.width,
                                                 26.0f + self.signupFormHeight + 6.0f)];
            [self.signUpSeparator setFrame:CGRectMake(0,
                                                      26.0f,
                                                      self.signUpView.frame.size.width,
                                                      1.0f)];
        } completion:^(BOOL finished) {
            [self.signUpArrow setImage:[UIImage imageNamed:@"arrowOrangeOpened"]];
            [self.signUpFormView setHidden:NO];
            self.isAnimationRunning = NO;
            [self.signUpSeparator setHidden:NO];
            
            [self.viewToScroll setFrame:CGRectMake(self.viewToScroll.frame.origin.x,
                                                   self.viewToScroll.frame.origin.y,
                                                   self.viewToScroll.frame.size.width,
                                                   CGRectGetMaxY(self.signUpView.frame)+6.0f)];
            
            [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(self.signUpView.frame)+6.0f)];
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
    
    [self.signUpView setFrame:CGRectMake(self.signUpView.frame.origin.x,
                                         33.0f + self.loginFormHeight + 12.0f,
                                         self.signUpView.frame.size.width,
                                         26.0f)];
    [self.signUpSeparator setHidden:YES];
    [self.signUpArrow setImage:[UIImage imageNamed:@"arrowOrangeClosed"]];
    if (RI_IS_RTL) {
        [self.signUpArrow flipViewImage];
    }
}

#pragma mark FBSDKLoginButtonDelegate


#pragma mark Facebook Login
- (void)facebookLoginButtonPressed:(id)sender
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_birthday"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
        if (!error) {
            
            NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
            [parameters setValue:@"id,name, first_name, last_name, email, gender, birthday" forKey:@"fields"];
            FBSDKGraphRequest *requestMe = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:parameters];
            FBSDKGraphRequestConnection *connection = [[FBSDKGraphRequestConnection alloc] init];
            [connection addRequest:requestMe
                 completionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                     //TODO: process me information@
                     
                     if (!error)
                     {
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
                                                                      [trackingDictionary setValue:[NSNumber numberWithInteger:[ageComponents year]] forKey:kRIEventAgeKey];
                                                                      [trackingDictionary setValue:@"Checkou" forKey:kRIEventLocationKey];
                                                                      NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                                                                      [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
                                                                      
                                                                      NSNumber *numberOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountTransactions];
                                                                      [trackingDictionary setValue:numberOfPurchases forKey:kRIEventAmountTransactions];
                                                                      
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
                                                                      
                                                                      [JAUtils goToNextStep:nextStep];
                                                                      
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
            [connection start];
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
        
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary* responseDictionary = (NSDictionary*)object;
            
            RICustomer *customerObject = [responseDictionary objectForKey:@"customer"];
            NSString* nextStep = [responseDictionary objectForKey:@"next_step"];
            
            NSString* emailKeyForCountry = [NSString stringWithFormat:@"%@_%@", kRememberedEmail, [RIApi getCountryIsoInUse]];
            
            if(self.checkBoxComponent.switchComponent.isOn)
            {
                [[NSUserDefaults standardUserDefaults] setObject:customerObject.email forKey:emailKeyForCountry];
            }else
            {
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:emailKeyForCountry];
            }
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:customerObject.idCustomer forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"LoginSuccess" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
            [trackingDictionary setValue:customerObject.idCustomer forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:customerObject.firstName forKey:kRIEventUserFirstNameKey];
            [trackingDictionary setValue:customerObject.lastName forKey:kRIEventUserLastNameKey];
            [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
            [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
            [trackingDictionary setValue:@"Checkout" forKey:kRIEventLocationKey];
            [trackingDictionary setValue:customerObject.gender forKey:kRIEventGenderKey];
            [trackingDictionary setValue:customerObject.createdAt forKey:kRIEventAccountDateKey];
            [trackingDictionary setValue:customerObject.birthday forKey:kRIEventBirthDayKey];
            
            NSDate* now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *dateOfBirth = [dateFormatter dateFromString:customerObject.birthday];
            NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:dateOfBirth toDate:now options:0];
            [trackingDictionary setValue:[NSNumber numberWithInteger:[ageComponents year]] forKey:kRIEventAgeKey];
            
            NSNumber *numberOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountTransactions];
            [trackingDictionary setValue:numberOfPurchases forKey:kRIEventAmountTransactions];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLoginSuccess]
                                                      data:[trackingDictionary copy]];
            
            trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"CheckoutAboutYou" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"NativeCheckout" forKey:kRIEventCategoryKey];
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventCheckoutAboutYou]
                                                      data:[trackingDictionary copy]];
            
            [self.loginDynamicForm resetValues];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                                object:nil];
            
            [JAUtils goToNextStep:nextStep];
        }
        
        [self hideLoading];
        
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
        
        NSDictionary *responseDictionary = (NSDictionary *)object;
        NSString* nextStep = [responseDictionary objectForKey:@"next_step"];
        
        [JAUtils goToNextStep:nextStep];
        
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

#pragma mark Observers
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
        [self.orderSummaryView setFrame:CGRectMake(self.orderSummaryView.frame.origin.x,
                                                   self.orderSummaryView.frame.origin.y,
                                                   self.orderSummaryView.frame.size.width,
                                                   self.orderSummaryOriginalHeight - height)];
        
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x,
                                             self.scrollView.frame.origin.y,
                                             self.scrollView.frame.size.width,
                                             self.scrollViewOriginalHeight - height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.orderSummaryView setFrame:CGRectMake(self.orderSummaryView.frame.origin.x,
                                                   self.orderSummaryView.frame.origin.y,
                                                   self.orderSummaryView.frame.size.width,
                                                   self.orderSummaryOriginalHeight)];
        [self.scrollView setFrame:CGRectMake(self.scrollView.frame.origin.x,
                                             self.scrollView.frame.origin.y,
                                             self.scrollView.frame.size.width,
                                             self.scrollViewOriginalHeight)];
    }];
}

-(NSDictionary *)getEmail
{
    NSString* emailKeyForCountry = [NSString stringWithFormat:@"%@_%@", kRememberedEmail, [RIApi getCountryIsoInUse]];
    NSMutableDictionary *values = [[NSMutableDictionary alloc] init];
    NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:emailKeyForCountry];
    if(VALID_NOTEMPTY(email, NSString))
    {
        [values setObject:email forKey:@"email"];
    }
    return values;
}
@end
