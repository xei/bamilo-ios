//
//  JAForgotPasswordViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 14/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAForgotPasswordViewController.h"
#import "RIForm.h"
#import "RICustomer.h"

@interface JAForgotPasswordViewController ()

@property (strong, nonatomic) JADynamicForm *dynamicForm;

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *firstLabel;
@property (strong, nonatomic) UILabel *secondLabel;
@property (strong, nonatomic) UIButton *forgotPasswordButton;
@property (assign, nonatomic) CGFloat forgotPasswordViewCurrentY;
@property (assign, nonatomic) RIApiResponse apiResponse;

@end

@implementation JAForgotPasswordViewController

#pragma mark - View lifecycle

- (void)showErrorView:(BOOL)isNoInternetConnection startingY:(CGFloat)startingY selector:(SEL)selector objects:(NSArray*)objects;
{
    [self.contentView removeFromSuperview];
    
    [super showErrorView:isNoInternetConnection startingY:startingY selector:selector objects:objects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.apiResponse = RIApiResponseSuccess;
    
    self.screenName = @"ForgotPassword";
    
    self.navBarLayout.showLogo = NO;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(6.0f,
                                                                6.0f,
                                                                self.scrollView.frame.size.width - 12.0f,
                                                                self.scrollView.frame.size.height - 12.0f)];
    self.contentView.layer.cornerRadius = 5.0f;
    [self.contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.contentView setHidden:YES];
    [self.scrollView addSubview:self.contentView];

    self.firstLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.firstLabel setFont:[UIFont fontWithName:kFontBoldName size:13.0f]];
    [self.firstLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.firstLabel setText:STRING_TYPE_YOUR_EMAIL];
    [self.firstLabel setBackgroundColor:[UIColor clearColor]];
    [self.firstLabel setTextAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.firstLabel];
    
    self.secondLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.secondLabel setFont:[UIFont fontWithName:kFontRegularName size:13.0f]];
    [self.secondLabel setTextColor:UIColorFromRGB(0x666666)];
    [self.secondLabel setText:STRING_WE_WILL_SEND_PASSWORD];
    [self.secondLabel setBackgroundColor:[UIColor clearColor]];
    [self.secondLabel setNumberOfLines:2];
    [self.secondLabel setTextAlignment:NSTextAlignmentLeft];
    [self.contentView addSubview:self.secondLabel];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getForgotPasswordForm];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance]trackScreenWithName:@"ForgotPass"];
}

- (void) getForgotPasswordForm
{
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    [self.scrollView setHidden:YES];
    
    [self.scrollView addSubview:self.contentView];
 
    [RIForm getForm:@"forgot_password"
       successBlock:^(RIForm *form)
     {
         self.dynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:0.0f];
         
         for(UIView *view in self.dynamicForm.formViews)
         {
             [self.contentView addSubview:view];
         }
         
         [self setupViews:self.view.frame.size.width height:self.view.frame.size.height toInterfaceOrientation:self.interfaceOrientation];
         [self removeErrorView];
         [self hideLoading];
     }
       failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
     {
         self.apiResponse = apiResponse;
         [self hideLoading];
         
         if (RIApiResponseNoInternetConnection == apiResponse)
         {
             if(VALID_NOTEMPTY(self.dynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.dynamicForm.formViews, NSMutableArray))
             {
                 [self showMessage:STRING_NO_CONNECTION success:NO];
                 [self finishedFormLoading:self.interfaceOrientation];
             }
             else
             {
                 [self showErrorView:YES startingY:0.0f selector:@selector(getForgotPasswordForm) objects:nil];
             }
         }
         else
         {                 if(VALID_NOTEMPTY(self.dynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.dynamicForm.formViews, NSMutableArray))
         {
             [self showMessage:STRING_ERROR success:NO];
             [self finishedFormLoading:self.interfaceOrientation];
         }
         else
         {
             [self showErrorView:NO startingY:0.0f selector:@selector(getForgotPasswordForm) objects:nil];
         }
         }
     }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews:(CGFloat)width height:(CGFloat)height toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.scrollView setFrame:CGRectMake(0.0f,
                                         0.0f,
                                         width,
                                         height)];
    
    [self.contentView setFrame:CGRectMake(6.0f,
                                          6.0f,
                                          self.scrollView.frame.size.width - 12.0f,
                                          self.scrollView.frame.size.height - 12.0f)];
    
    CGFloat horizontalMargin = 6.0f;
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM() && UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        horizontalMargin = 128.0f;
    }
    
    CGRect firstLabelRect = [self.firstLabel.text boundingRectWithSize:CGSizeMake(self.contentView.frame.size.width - (2*horizontalMargin), self.scrollView.frame.size.height)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{NSFontAttributeName:self.firstLabel.font} context:nil];
    [self.firstLabel setFrame:CGRectMake(horizontalMargin,
                                         11.0f,
                                         self.contentView.frame.size.width - (2 * horizontalMargin),
                                         ceilf(firstLabelRect.size.height))];
    
    CGRect secondLabelRect = [self.secondLabel.text boundingRectWithSize:CGSizeMake(self.contentView.frame.size.width - (2*horizontalMargin), self.scrollView.frame.size.height)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{NSFontAttributeName:self.secondLabel.font} context:nil];
    [self.secondLabel setFrame:CGRectMake(horizontalMargin,
                                          CGRectGetMaxY(self.firstLabel.frame) + 1.0f,
                                          self.contentView.frame.size.width - (2 * horizontalMargin),
                                          ceilf(secondLabelRect.size.height))];
    
    self.forgotPasswordViewCurrentY = CGRectGetMaxY(self.secondLabel.frame) + 11.0f;
    
    for(UIView *view in self.dynamicForm.formViews)
    {
        [view setFrame:CGRectMake(horizontalMargin,
                                  self.forgotPasswordViewCurrentY,
                                  self.contentView.frame.size.width - (2 * horizontalMargin),
                                  view.frame.size.height)];
        self.forgotPasswordViewCurrentY += view.frame.size.height;
    }
    
    [self finishedFormLoading:toInterfaceOrientation];
}

-(void)finishedFormLoading:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat horizontalMargin = 6.0f;
    NSString *orangeButtonName = @"orangeMedium_%@";
    
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            horizontalMargin = 128.0f;
            orangeButtonName = @"orangeFullPortrait_%@";
        }
        else
        {
            orangeButtonName = @"orangeMediumPortrait_%@";
        }
    }
    
    if(VALID_NOTEMPTY(self.forgotPasswordButton, UIButton))
    {
        [self.forgotPasswordButton removeFromSuperview];
    }
    
    UIImage *forgotPasswordButtonImage = [UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"normal"]];
    self.forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgotPasswordButton setFrame:CGRectMake(horizontalMargin,
                                                   self.forgotPasswordViewCurrentY + 30.0f,
                                                   forgotPasswordButtonImage.size.width,
                                                   forgotPasswordButtonImage.size.height)];
    
    
    [self.forgotPasswordButton setBackgroundImage:forgotPasswordButtonImage forState:UIControlStateNormal];
    [self.forgotPasswordButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]]forState:UIControlStateHighlighted];
    [self.forgotPasswordButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"highlighted"]]forState:UIControlStateSelected];
    [self.forgotPasswordButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:orangeButtonName, @"disabled"]]forState:UIControlStateDisabled];
    [self.forgotPasswordButton setTitle:STRING_SUBMIT forState:UIControlStateNormal];
    [self.forgotPasswordButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.forgotPasswordButton addTarget:self action:@selector(forgotPasswordButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.forgotPasswordButton.titleLabel setFont:[UIFont fontWithName:kFontRegularName size:16.0f]];
    [self.contentView addSubview:self.forgotPasswordButton];
    
    self.forgotPasswordViewCurrentY = CGRectGetMaxY(self.forgotPasswordButton.frame) + 6.0f;
    
    [self.contentView setFrame:CGRectMake(self.contentView.frame.origin.x,
                                          self.contentView.frame.origin.y,
                                          self.contentView.frame.size.width,
                                          CGRectGetMaxY(self.forgotPasswordButton.frame) + 6.0f)];
    
    [self.contentView setHidden:NO];
    [self.scrollView setHidden:NO];

    if(self.firstLoading)
    {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
}

#pragma mark - Action

- (void)forgotPasswordButtonPressed:(id)sender
{
    [self continueForgotPassword];
}

- (void)continueForgotPassword
{
    [self.dynamicForm resignResponder];
    
    [self showLoading];
    
    if ([self.dynamicForm checkErrors]) {
        [self showMessage:self.dynamicForm.firstErrorInFields success:NO];
        [self hideLoading];
        return;
    }
    
    [RIForm sendForm:[self.dynamicForm form]
          parameters:[self.dynamicForm getValues]
        successBlock:^(id object)
     {
         [self.dynamicForm resetValues];
         [self hideLoading];
         
         [self showMessage:STRING_EMAIL_SENT success:YES];
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
     {
         [self hideLoading];
         
         if (RIApiResponseNoInternetConnection == apiResponse)
         {
             [self showMessage:STRING_NO_CONNECTION success:NO];
         }
         else if(VALID_NOTEMPTY(errorObject, NSDictionary))
         {
             [self.dynamicForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                 [self showMessage:message success:NO];
             }];
         }
         else if(VALID_NOTEMPTY(errorObject, NSArray))
         {
             [self.dynamicForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                 [self showMessage:message success:NO];
             }];
         }
         else
         {
             [self.dynamicForm checkErrors];
             
             [self showMessage:STRING_ERROR success:NO];
         }
     }];
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

- (void) hideKeyboard
{
    [self.dynamicForm resignResponder];
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
