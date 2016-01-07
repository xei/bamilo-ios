//
//  JAForgotPasswordViewController.m
//  Jumia
//
//  Created by lucianoduarte on 01/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAForgotPasswordViewController.h"
#import "RIForm.h"
#import "RICustomer.h"
#import "JABottomBar.h"

#define kSideMargin 16
#define kTopMargin 36
#define kSubTitleMargin 6
#define kEmailMargin 32
#define kIPadWidth 289

@interface JAForgotPasswordViewController () <JADynamicFormDelegate>
{
    CGFloat _elementsWidth;
}

@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subTitleLabel;
@property (strong, nonatomic) JABottomBar *forgotPasswordButton;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (assign, nonatomic) RIApiResponse apiResponse;
@property (assign, nonatomic) CGFloat contentScrollOriginalHeight;

@end

@implementation JAForgotPasswordViewController


- (UIScrollView *)mainScrollView
{
    if (!VALID_NOTEMPTY(_mainScrollView, UIScrollView)) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:self.viewBounds];
        [_mainScrollView setBackgroundColor:[UIColor whiteColor]];
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
        [_titleLabel setText:STRING_TYPE_YOUR_EMAIL];
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
                                                                   _subTitleLabel.height)];
        [_subTitleLabel setTextAlignment:NSTextAlignmentCenter];
        [_subTitleLabel setFont:JACaptionFont];
        [_subTitleLabel setTextColor:JABlack800Color];
        [_subTitleLabel setText:STRING_WE_WILL_SEND_PASSWORD];
        [_subTitleLabel setNumberOfLines:0];
        [_subTitleLabel sizeToFit];
        [_subTitleLabel setWidth:_elementsWidth];
    }
    return _subTitleLabel;
}

- (JABottomBar *)forgotPasswordButton
{
    if (!VALID_NOTEMPTY(_forgotPasswordButton, JABottomBar)) {
        _forgotPasswordButton = [[JABottomBar alloc] initWithFrame:CGRectMake(
                                                                              0,
                                                                              self.view.height, //CGRectGetMaxY(self.viewBounds) - kBottomDefaultHeight,
                                                                              self.view.width,
                                                                              kBottomDefaultHeight)];
        [_forgotPasswordButton addButton:[STRING_SUBMIT uppercaseString] target:self action:@selector(forgotPasswordButtonPressed:)];
    }
    return _forgotPasswordButton;
}

#pragma mark - View lifecycle

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
    
    self.screenName = @"ForgotPassword";
    self.navBarLayout.showLogo = NO;
    self.navBarLayout.title = STRING_PASSWORD_RECOVERY;
    
    _elementsWidth = self.viewBounds.size.width - (kSideMargin * 2);
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.titleLabel];
    [self.mainScrollView addSubview:self.subTitleLabel];
    [self.view addSubview:self.forgotPasswordButton];
    
    if (self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess) {
        [self showLoading];
    }
    
    [self getForgotPasswordForm];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self setupViewsVertically];
    [self.mainScrollView setXCenterAligned];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[RITrackingWrapper sharedInstance]trackScreenWithName:@"ForgotPass"];
}
 
 - (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Action

- (void) getForgotPasswordForm
{
    [RIForm getForm:@"forgot_password"
       successBlock:^(RIForm *form)
     {
         
         if (self.loginEmail== nil) {
             [self onErrorResponse:RIApiResponseSuccess messages:@[STRING_ERROR] showAsMessage:YES selector:nil objects:nil];
             [self finishedFormLoading];
         } else {
             [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
             self.dynamicForm = [[JADynamicForm alloc] initWithForm:form values:@{@"email" : self.loginEmail} startingPosition:CGRectGetMaxY(self.subTitleLabel.frame) + kEmailMargin hasFieldNavigation:YES];
             [self.dynamicForm setDelegate:self];

             for (UIView *formView in self.dynamicForm.formViews) {
                 [self.mainScrollView addSubview:formView];
             }

             self.contentScrollOriginalHeight = self.mainScrollView.height;

             [self setupViewsVertically];
         }
         [self hideLoading];
    }
       failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage)
    {
        self.apiResponse = apiResponse;
        [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:nil objects:nil];
        if (VALID_NOTEMPTY(self.dynamicForm, JADynamicForm) && VALID_NOTEMPTY(self.dynamicForm.formViews, NSMutableArray)) {
            [self finishedFormLoading];
        }
        [self hideLoading];
    }];
}

- (void)finishedFormLoading
{
    if (self.firstLoading) {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
}

- (void)forgotPasswordButtonPressed:(id)sender
{
    [self continueForgotPassword];
}

- (void)continueForgotPassword
{
    [self.dynamicForm resignResponder];
    
    [self showLoading];
    
    if ([self.dynamicForm checkErrors]) {
        [self onErrorResponse:RIApiResponseSuccess messages:@[self.dynamicForm.firstErrorInFields] showAsMessage:YES selector:nil objects:nil];
        [self hideLoading];
        return;
    }
    
    [RIForm sendForm:[self.dynamicForm form]
          parameters:[self.dynamicForm getValues]
        successBlock:^(id object)
     {
         [self onSuccessResponse:RIApiResponseSuccess messages:@[STRING_EMAIL_SENT] showMessage:YES];
         [self hideLoading];
     } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject)
     {
         if(VALID_NOTEMPTY(errorObject, NSDictionary)) {
             [self.dynamicForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:nil objects:nil];
             }];
         } else if(VALID_NOTEMPTY(errorObject, NSArray)) {
             [self.dynamicForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:nil objects:nil];
             }];
         }else{
             [self.dynamicForm checkErrors];
             [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:nil objects:nil];
         }
         [self hideLoading];
     }];
}

- (void)setupViewsVertically
{
    if (self.forgotPasswordButton.y != self.viewBounds.size.height - self.forgotPasswordButton.height) {
        for (UIView *view in self.dynamicForm.formViews) {
            [view setY:CGRectGetMaxY(self.subTitleLabel.frame) + kEmailMargin];
        }
        
        [self.forgotPasswordButton setY:self.viewBounds.size.height - self.forgotPasswordButton.height];
        
        self.contentScrollOriginalHeight = self.mainScrollView.height;
    }
    
    [self setupViewsHorizontally];
}

- (void)setupViewsHorizontally
{
    [self.titleLabel sizeToFit];
    [self.subTitleLabel sizeToFit];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        CGFloat middleX = (self.mainScrollView.width / 2);
        
        [self.titleLabel setWidth:kIPadWidth];
        [self.titleLabel setX:middleX - (self.titleLabel.width / 2)];
        
        [self.subTitleLabel setWidth:kIPadWidth];
        [self.subTitleLabel setX:middleX - (self.subTitleLabel.width / 2)];
        
        for (UIView *view in self.dynamicForm.formViews) {
            [view setWidth:kIPadWidth];
            [view setX:middleX - (view.width / 2)];
        }
        
    } else if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [self.titleLabel setWidth:_elementsWidth];
        [self.titleLabel setX:kSideMargin];
        
        [self.subTitleLabel setWidth:_elementsWidth];
        [self.subTitleLabel setX:kSideMargin];
        
        for (UIView *view in self.dynamicForm.formViews) {
            [view setWidth:_elementsWidth];
            [view setX:kSideMargin];
        }
        
    }
    
    [self.forgotPasswordButton setWidth:self.viewBounds.size.width];
    [self.forgotPasswordButton setX:0];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

#pragma mark - Keyboard notifications

- (void) hideKeyboard
{
    [self.dynamicForm resignResponder];
}

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat height = kbSize.height;
    
    if(self.view.frame.size.width == kbSize.height) {
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
