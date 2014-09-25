//
//  JASignupViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASignupViewController.h"
#import "JAUtils.h"
#import "RIForm.h"
#import "RIField.h"
#import "RIFieldDataSetComponent.h"
#import "RICustomer.h"

@interface JASignupViewController ()
<
JADynamicFormDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
JANoConnectionViewDelegate
>

@property (strong, nonatomic) UIScrollView *contentScrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) UILabel *headerLabel;
@property (strong, nonatomic) UIView *headerSeparator;
@property (strong, nonatomic) UIButton *loginButton;
@property (strong, nonatomic) UIButton *registerButton;
@property (strong, nonatomic) JADynamicForm *dynamicForm;
@property (assign, nonatomic) CGRect originalFrame;
@property (assign, nonatomic) CGFloat registerViewCurrentY;

@property (strong, nonatomic) JABirthDateComponent *birthdayComponent;
@property (strong, nonatomic) JARadioComponent *radioComponent;
@property (strong, nonatomic) UIView *pickerBackgroundView;
@property (strong, nonatomic) UIToolbar *pickerToolbar;
@property (strong, nonatomic) UIDatePicker *datePickerView;
@property (strong, nonatomic) UIPickerView *pickerView;

@end

@implementation JASignupViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.A4SViewControllerAlias = @"ACCOUNT";
    
    self.navBarLayout.title = STRING_CREATE_ACCOUNT;
    
    self.registerViewCurrentY = 0.0f;
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - 64.0f)];
    [self.contentScrollView setShowsHorizontalScrollIndicator:NO];
    [self.contentScrollView setShowsVerticalScrollIndicator:NO];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.contentScrollView.frame.size.height)];
    [self.contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.contentView.layer.cornerRadius = 5.0f;
    
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(6.0f, self.registerViewCurrentY, self.contentView.frame.size.width - 12.0f, 25.0f)];
    [self.headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.headerLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.headerLabel setText:STRING_ACCOUNT_DATA];
    [self.headerLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.headerLabel];
    self.registerViewCurrentY = CGRectGetMaxY(self.headerLabel.frame);
    
    self.headerSeparator = [[UIView alloc] initWithFrame:CGRectMake(0.0f, self.registerViewCurrentY, self.contentView.frame.size.width, 1.0f)];
    [self.headerSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.contentView addSubview:self.headerSeparator];
    self.registerViewCurrentY = CGRectGetMaxY(self.headerSeparator.frame) + 6.0f;
    
    [self.contentScrollView addSubview:self.contentView];
    [self.view addSubview:self.contentScrollView];
    
    self.originalFrame = self.contentScrollView.frame;
    
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInteger:RIEventRegisterStart] data:nil];
    
    [self showLoading];
    
    [RIForm getForm:@"register"
       successBlock:^(RIForm *form) {
           [self hideLoading];
           
           self.dynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:self.registerViewCurrentY];
           [self.dynamicForm setDelegate:self];
           
           for(UIView *view in self.dynamicForm.formViews)
           {
               [self.contentView addSubview:view];
               self.registerViewCurrentY = CGRectGetMaxY(view.frame);
           }
           
           [self finishedFormLoading];
           
       } failureBlock:^(NSArray *errorMessage) {
           
           [self finishedFormLoading];
           
           JAErrorView *errorView = [JAErrorView getNewJAErrorView];
           [errorView setErrorTitle:STRING_ERROR
                           andAddTo:self];
       }];
}

- (void)finishedFormLoading
{
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.registerButton setFrame:CGRectMake(6.0f, self.registerViewCurrentY, 296.0f, 44.0f)];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_normal"] forState:UIControlStateNormal];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateHighlighted];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_highlighted"] forState:UIControlStateSelected];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:@"orangeBig_disabled"] forState:UIControlStateDisabled];
    [self.registerButton setTitle:STRING_REGISTER forState:UIControlStateNormal];
    [self.registerButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(registerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.contentView addSubview:self.registerButton];
    
    self.registerViewCurrentY = CGRectGetMaxY(self.registerButton.frame) + 5.0f;
    // Forgot Password
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setFrame:CGRectMake(6.0f, self.registerViewCurrentY, 296.0f, 30.0f)];
    [self.loginButton setBackgroundColor:[UIColor clearColor]];
    [self.loginButton setTitle:STRING_LOGIN forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateSelected];
    [self.loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.contentView addSubview:self.loginButton];
    self.registerViewCurrentY = CGRectGetMaxY(self.loginButton.frame) + 3.0f;
    
    [self.contentView setFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.registerViewCurrentY)];
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, self.contentView.frame.origin.y + self.contentView.frame.size.height + 6.0f)];
    
    [self hideLoading];
    
    // notify the InAppNotification SDK that this the active view controller
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_APPEAR object:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    // notify the InAppNotification SDK that this view controller in no more active
    [[NSNotificationCenter defaultCenter] postNotificationName:A4S_INAPP_NOTIF_VIEW_DID_DISAPPEAR object:self];
}

#pragma mark - No connection delegate

- (void)retryConnection
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self continueRegister];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self continueRegister];
    }
}

#pragma mark - Actions

- (void)registerButtonPressed:(id)sender
{
    if (NotReachable == [[Reachability reachabilityForInternetConnection] currentReachabilityStatus])
    {
        JANoConnectionView *lostConnection = [JANoConnectionView getNewJANoConnectionView];
        [lostConnection setupNoConnectionViewForNoInternetConnection:YES];
        lostConnection.delegate = self;
        [lostConnection setRetryBlock:^(BOOL dismiss) {
            [self continueRegister];
        }];
        
        [self.view addSubview:lostConnection];
    }
    else
    {
        [self continueRegister];
    }
}

- (void)continueRegister
{
    [self.dynamicForm resignResponder];
    
    [self showLoading];
    
    [RIForm sendForm:[self.dynamicForm form] parameters:[self.dynamicForm getValues]  successBlock:^(id object) {
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:((RICustomer *)object).idCustomer forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"CreateSuccess" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
        [trackingDictionary setValue:((RICustomer *)object).idCustomer forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:((RICustomer *)object).gender forKey:kRIEventGenderKey];
        [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRegisterSuccess]
                                                  data:[trackingDictionary copy]];
        
        [self.dynamicForm resetValues];
        
        [self hideLoading];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMenuDidSelectOptionNotification
                                                            object:@{@"index": @(0),
                                                                     @"name": STRING_HOME}];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                            object:nil];
        
    } andFailureBlock:^(id errorObject) {
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:@"CreateFailed" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRegisterFail]
                                                  data:[trackingDictionary copy]];
        
        [self hideLoading];
        
        if(VALID_NOTEMPTY(errorObject, NSDictionary))
        {
            [self.dynamicForm validateFields:errorObject];
            
            JAErrorView *errorView = [JAErrorView getNewJAErrorView];
            [errorView setErrorTitle:STRING_ERROR_INVALID_FIELDS
                            andAddTo:self];
        }
        else if(VALID_NOTEMPTY(errorObject, NSArray))
        {
            [self.dynamicForm checkErrors];
            
            JAErrorView *errorView = [JAErrorView getNewJAErrorView];
            [errorView setErrorTitle:[errorObject componentsJoinedByString:@","]
                            andAddTo:self];
        }
        else
        {
            [self.dynamicForm checkErrors];
            
            JAErrorView *errorView = [JAErrorView getNewJAErrorView];
            [errorView setErrorTitle:STRING_ERROR
                            andAddTo:self];
        }
    }];
}

- (void)loginButtonPressed:(id)sender
{
    [self.dynamicForm resignResponder];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification
                                                        object:nil
                                                      userInfo:nil];
}

- (void)birthdayChanged:(id)sender
{
    if(VALID_NOTEMPTY(self.birthdayComponent, JABirthDateComponent))
    {
        [self.birthdayComponent setValue:[self.datePickerView date]];
    }
    
    [self removePickerView];
}

- (void)radioOptionChanged:(id)sender
{
    if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent))
    {
        NSInteger selectedRow = [self.pickerView selectedRowInComponent:0];
        if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent) && VALID_NOTEMPTY([self.radioComponent dataset], NSArray) && selectedRow < [[self.radioComponent dataset] count])
        {
            [self.radioComponent setValue:[[self.radioComponent dataset] objectAtIndex:selectedRow]];
        }
    }
    
    [self removePickerView];
}

-(void)removePickerView
{
    if(VALID_NOTEMPTY(self.pickerToolbar, UIToolbar))
    {
        [self.pickerToolbar removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.pickerView, UIPickerView))
    {
        [self.pickerView removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.datePickerView, UIDatePicker))
    {
        [self.datePickerView removeFromSuperview];
    }
    
    if(VALID_NOTEMPTY(self.pickerBackgroundView, UIView))
    {
        [self.pickerBackgroundView removeFromSuperview];
    }
    
    self.pickerView = nil;
    self.datePickerView = nil;
    self.pickerBackgroundView = nil;
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    CGPoint scrollPoint = CGPointMake(0.0, view.frame.origin.y);
    [self.contentScrollView setContentOffset:scrollPoint
                                    animated:YES];
}

- (void) lostFocus
{
    [UIView animateWithDuration:0.5f
                     animations:^{
                         self.contentScrollView.frame = self.originalFrame;
                     }];
}

- (void)openDatePicker:(JABirthDateComponent *)birthdayComponent
{
    [self removePickerView];
    
    self.birthdayComponent = birthdayComponent;
    self.pickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    UITapGestureRecognizer *removePickerViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(removePickerView)];
    [self.pickerBackgroundView addGestureRecognizer:removePickerViewTap];
    
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
    [self.datePickerView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.datePickerView setAlpha:0.9];
    self.datePickerView.datePickerMode = UIDatePickerModeDate;
    
    self.datePickerView.date = VALID_NOTEMPTY([birthdayComponent getDate], NSDate) ? [birthdayComponent getDate] : [NSDate date];
    [self.datePickerView setFrame:CGRectMake(0.0f,
                                             (self.pickerBackgroundView.frame.size.height - self.datePickerView.frame.size.height),
                                             self.datePickerView.frame.size.width,
                                             self.datePickerView.frame.size.height)];
    
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [self.pickerToolbar setTranslucent:NO];
    [self.pickerToolbar setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.pickerToolbar setAlpha:0.9];
    [self.pickerToolbar setFrame:CGRectMake(0.0f,
                                            CGRectGetMinY(self.datePickerView.frame) - 44.0f,
                                            320.0f,
                                            44.0f)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0f, 0.0f, 0.0f)];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [button setTitle:STRING_DONE forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(birthdayChanged:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.pickerToolbar setItems:[NSArray arrayWithObjects:flexibleItem, doneButton, nil]];
    [self.pickerBackgroundView addSubview:self.pickerToolbar];
    
    [self.pickerBackgroundView addSubview:self.datePickerView];
    [self.view addSubview:self.pickerBackgroundView];
}

- (void)openPicker:(JARadioComponent *)radioComponent
{
    [self removePickerView];
    
    self.radioComponent = radioComponent;
    self.pickerBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height)];
    UITapGestureRecognizer *removePickerViewTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(removePickerView)];
    [self.pickerBackgroundView addGestureRecognizer:removePickerViewTap];
    
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
    [self.pickerView setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.pickerView setAlpha:0.9];
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    
    NSString *selectedValue = [radioComponent getSelectedValue];
    if(VALID_NOTEMPTY(selectedValue, NSString))
    {
        NSInteger selectedRow = 0;
        if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent) && VALID_NOTEMPTY([self.radioComponent dataset], NSArray))
        {
            for (int i = 0; i < [[self.radioComponent dataset] count]; i++)
            {
                if([selectedValue isEqualToString:[[self.radioComponent dataset] objectAtIndex:i]])
                {
                    selectedRow = i;
                    break;
                }
            }
        }
        [self.pickerView selectRow:selectedRow inComponent:0 animated:NO];
    }
    
    [self.pickerView setFrame:CGRectMake(0.0f,
                                         (self.pickerBackgroundView.frame.size.height - self.pickerView.frame.size.height),
                                         self.pickerView.frame.size.width,
                                         self.pickerView.frame.size.height)];
    
    self.pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
    [self.pickerToolbar setTranslucent:NO];
    [self.pickerToolbar setBackgroundColor:UIColorFromRGB(0xffffff)];
    [self.pickerToolbar setAlpha:0.9];
    [self.pickerToolbar setFrame:CGRectMake(0.0f,
                                            CGRectGetMinY(self.pickerView.frame) - 44.0f,
                                            320.0f,
                                            44.0f)];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0.0, 0.0f, 0.0f, 0.0f)];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [button setTitle:STRING_DONE forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [button setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(radioOptionChanged:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    [self.pickerToolbar setItems:[NSArray arrayWithObjects:flexibleItem, doneButton, nil]];
    [self.pickerBackgroundView addSubview:self.pickerToolbar];
    
    [self.pickerBackgroundView addSubview:self.pickerView];
    [self.view addSubview:self.pickerBackgroundView];
}

#pragma mark UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numberOfRowsInComponent = 0;
    if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent) && VALID_NOTEMPTY([self.radioComponent dataset], NSArray))
    {
        numberOfRowsInComponent = [[self.radioComponent dataset] count];
    }
    return numberOfRowsInComponent;
}

#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *titleForRow = @"";
    if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent) && VALID_NOTEMPTY([self.radioComponent dataset], NSArray) && row < [[self.radioComponent dataset] count])
    {
        titleForRow = [[self.radioComponent dataset] objectAtIndex:row];
    }
    return  titleForRow;
}

@end
