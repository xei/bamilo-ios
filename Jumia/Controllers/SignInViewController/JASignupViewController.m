//
//  JASignupViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 13/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JASignupViewController.h"
#import "JAUtils.h"
#import "JAPicker.h"
#import "JADatePicker.h"
#import "RIForm.h"
#import "RIField.h"
#import "RIFieldDataSetComponent.h"
#import "RICustomer.h"
#import "RINewsletterCategory.h"

@interface JASignupViewController ()
<
JADynamicFormDelegate,
JAPickerDelegate,
JADatePickerDelegate
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
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) JADatePicker *datePicker;

@property (nonatomic, assign)BOOL isOpeningPicker;

@end

@implementation JASignupViewController

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
    
    self.screenName = @"Register";
    
    self.isOpeningPicker = NO;
    
    self.A4SViewControllerAlias = @"ACCOUNT";
    
    self.navBarLayout.title = STRING_CREATE_ACCOUNT;
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    [self.contentScrollView setShowsHorizontalScrollIndicator:NO];
    [self.contentScrollView setShowsVerticalScrollIndicator:NO];
    [self.view addSubview:self.contentScrollView];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView setBackgroundColor:UIColorFromRGB(0xffffff)];
    self.contentView.layer.cornerRadius = 5.0f;
    [self.contentScrollView addSubview:self.contentView];
    
    self.headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13.0f]];
    [self.headerLabel setTextColor:UIColorFromRGB(0x4e4e4e)];
    [self.headerLabel setText:STRING_ACCOUNT_DATA];
    [self.headerLabel setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:self.headerLabel];
    
    self.headerSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    [self.headerSeparator setBackgroundColor:UIColorFromRGB(0xfaa41a)];
    [self.contentView addSubview:self.headerSeparator];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.registerButton setFrame:CGRectZero];
    [self.registerButton setTitle:STRING_REGISTER forState:UIControlStateNormal];
    [self.registerButton setTitleColor:UIColorFromRGB(0x4e4e4e) forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(registerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.registerButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16.0f]];
    [self.contentView addSubview:self.registerButton];
    
    self.registerViewCurrentY = CGRectGetMaxY(self.registerButton.frame) + 5.0f;
    // Forgot Password
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setFrame:CGRectZero];
    [self.loginButton setBackgroundColor:[UIColor clearColor]];
    [self.loginButton setTitle:STRING_LOGIN forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0x55a1ff) forState:UIControlStateNormal];
    [self.loginButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateSelected];
    [self.loginButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.loginButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:11.0f]];
    [self.contentView addSubview:self.loginButton];
    self.registerViewCurrentY = CGRectGetMaxY(self.loginButton.frame) + 3.0f;
    
    [self showLoading];
    
    [self getRegisterForm];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self removeViews];
    
    [self showLoading];
    
    CGFloat newWidth = self.view.frame.size.height + self.view.frame.origin.y;
    CGFloat newHeight = self.view.frame.size.width + self.view.frame.origin.x;
    
    [self setupViews:newWidth height:newHeight toInterfaceOrientation:toInterfaceOrientation];
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self hideLoading];
    
    [self hideKeyboard];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void) hideKeyboard
{
    [self.dynamicForm resignResponder];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)getRegisterForm
{
    [RIForm getForm:@"register"
       successBlock:^(RIForm *form) {
           [self hideLoading];
           
           self.dynamicForm = [[JADynamicForm alloc] initWithForm:form startingPosition:self.registerViewCurrentY];
           [self.dynamicForm setDelegate:self];
           
           for(UIView *view in self.dynamicForm.formViews)
           {
               [self.contentView addSubview:view];
           }
           
         [self setupViews:self.view.frame.size.width height:self.view.frame.size.height toInterfaceOrientation:self.interfaceOrientation];
           
       } failureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
           
           if(RIApiResponseMaintenancePage == apiResponse)
           {
               [self showMaintenancePage:@selector(getRegisterForm) objects:nil];
           }
           else
           {
               BOOL noConnection = NO;
               if (RIApiResponseNoInternetConnection == apiResponse)
               {
                   noConnection = YES;
               }
               [self showErrorView:noConnection startingY:0.0f selector:@selector(getRegisterForm) objects:nil];
           }
           
           [self hideLoading];
       }];
}

- (void)removeViews
{
    if(VALID_NOTEMPTY(self.picker, JAPicker))
    {
        [self.picker removeFromSuperview];
        self.picker = nil;
    }
    
    if(VALID_NOTEMPTY(self.datePicker, JADatePicker))
    {
        [self.datePicker removeFromSuperview];
        self.datePicker = nil;
    }
}

- (void)setupViews:(CGFloat)width height:(CGFloat)height toInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    [self.contentScrollView setFrame:CGRectMake(0.0f, 0.0f, width, height)];
    self.originalFrame = self.contentScrollView.frame;
    
    [self.contentView setFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.contentScrollView.frame.size.height)];
    
    self.registerViewCurrentY = 0.0f;
    
    [self.headerLabel setFrame:CGRectMake(6.0f, self.registerViewCurrentY, self.contentView.frame.size.width - 12.0f, 25.0f)];
    self.registerViewCurrentY = CGRectGetMaxY(self.headerLabel.frame);
    
    [self.headerSeparator setFrame:CGRectMake(0.0f, self.registerViewCurrentY, self.contentView.frame.size.width, 1.0f)];
    self.registerViewCurrentY = CGRectGetMaxY(self.headerSeparator.frame) + 6.0f;
    
    NSString *signupImageNameFormatter = @"orangeMedium_%@";
    if(UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())
    {
        signupImageNameFormatter = @"orangeMediumPortrait_%@";
        
        if(UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
        {
            signupImageNameFormatter = @"orangeFullPortrait_%@";
        }
    }
    
    UIImage *signupNormalImage = [UIImage imageNamed:[NSString stringWithFormat:signupImageNameFormatter, @"normal"]];
    
    for(UIView *view in self.dynamicForm.formViews)
    {
        CGRect dynamicFormFieldViewFrame = view.frame;
        dynamicFormFieldViewFrame.origin.x = (self.contentView.frame.size.width - signupNormalImage.size.width) / 2;
        dynamicFormFieldViewFrame.origin.y = self.registerViewCurrentY;
        dynamicFormFieldViewFrame.size.width = signupNormalImage.size.width;
        view.frame = dynamicFormFieldViewFrame;
        self.registerViewCurrentY = CGRectGetMaxY(view.frame);
    }
    
    [self.registerButton setBackgroundImage:signupNormalImage forState:UIControlStateNormal];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:signupImageNameFormatter, @"highlighted"]] forState:UIControlStateHighlighted];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:signupImageNameFormatter, @"highlighted"]] forState:UIControlStateSelected];
    [self.registerButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:signupImageNameFormatter, @"disabled"]] forState:UIControlStateDisabled];
    [self.registerButton setFrame:CGRectMake((self.contentView.frame.size.width - signupNormalImage.size.width) / 2,
                                             self.registerViewCurrentY,
                                             signupNormalImage.size.width,
                                             signupNormalImage.size.height)];
    
    self.registerViewCurrentY = CGRectGetMaxY(self.registerButton.frame) + 5.0f;
    // Forgot Password
    [self.loginButton setFrame:CGRectMake(self.registerButton.frame.origin.x,
                                          self.registerViewCurrentY,
                                          self.registerButton.frame.size.width,
                                          30.0f)];
    self.registerViewCurrentY = CGRectGetMaxY(self.loginButton.frame) + 3.0f;
    
    [self.contentView setFrame:CGRectMake(6.0f, 6.0f, self.contentScrollView.frame.size.width - 12.0f, self.registerViewCurrentY)];
    [self.contentScrollView setContentSize:CGSizeMake(self.contentScrollView.frame.size.width, self.contentView.frame.origin.y + self.contentView.frame.size.height + 6.0f)];
    
    [self hideLoading];
    
    [self finishedFormLoading];
}

- (void)finishedFormLoading
{
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInteger:RIEventRegisterStart] data:nil];
    
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

#pragma mark - Actions

- (void)registerButtonPressed:(id)sender
{
    [self continueRegister];
}

- (void)continueRegister
{
    [self hideKeyboard];
    
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
        if(self.fromSideMenu)
        {
            [trackingDictionary setValue:@"Side menu" forKey:kRIEventLocationKey];
        }
        else
        {
            [trackingDictionary setValue:@"My account" forKey:kRIEventLocationKey];
        }
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRegisterSuccess]
                                                  data:[trackingDictionary copy]];
        
        NSArray *newsletterOption = [RINewsletterCategory getNewsletter];
        if(VALID_NOTEMPTY(newsletterOption, NSArray))
        {
            trackingDictionary = [[NSMutableDictionary alloc] init];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventLabelKey];
            [trackingDictionary setValue:@"SubscribeNewsletter" forKey:kRIEventActionKey];
            [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
            [trackingDictionary setValue:[RICustomer getCustomerId] forKey:kRIEventUserIdKey];
            [trackingDictionary setValue:@"Register" forKey:kRIEventLocationKey];
            
            [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventNewsletter]
                                                      data:[trackingDictionary copy]];
        }
        
        [self.dynamicForm resetValues];
        
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
        [trackingDictionary setValue:@"CreateFailed" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
        if(self.fromSideMenu)
        {
            [trackingDictionary setValue:@"Side menu" forKey:kRIEventLocationKey];
        }
        else
        {
            [trackingDictionary setValue:@"My account" forKey:kRIEventLocationKey];
        }
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRegisterFail]
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

- (void)loginButtonPressed:(id)sender
{
    [self hideKeyboard];
    
    NSMutableDictionary *userInfo = nil;
    
    if(VALID_NOTEMPTY(self.nextNotification, NSNotification))
    {
        userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:self.nextNotification forKey:@"notification"];
        [userInfo setObject:[NSNumber numberWithBool:self.fromSideMenu] forKey:@"from_side_menu"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowSignInScreenNotification
                                                        object:nil
                                                      userInfo:userInfo];
}

#pragma mark JADynamicFormDelegate

- (void)changedFocus:(UIView *)view
{
    //    CGPoint scrollPoint = CGPointMake(0.0, view.frame.origin.y);
    //    [self.contentScrollView setContentOffset:scrollPoint
    //                                    animated:YES];
}

- (void) lostFocus
{
    //    [UIView animateWithDuration:0.5f
    //                     animations:^{
    //                         self.contentScrollView.frame = self.originalFrame;
    //                     }];
}

- (void)openDatePicker:(JABirthDateComponent *)birthdayComponent
{
    if(!self.isOpeningPicker)
    {
        self.isOpeningPicker = YES;
        
        if(VALID_NOTEMPTY(self.datePicker, JADatePicker))
        {
            [self.datePicker removeFromSuperview];
            self.datePicker = nil;
        }
        
        if(VALID_NOTEMPTY(self.picker, JAPicker))
        {
            [self.picker removeFromSuperview];
            self.picker = nil;
        }
        
        self.birthdayComponent = birthdayComponent;
        
        self.datePicker = [[JADatePicker alloc] initWithFrame:self.view.frame];
        [self.datePicker setDelegate:self];
        
        [self.datePicker setDate:VALID_NOTEMPTY([birthdayComponent getDate], NSDate) ? [birthdayComponent getDate] : [NSDate date]];
        
        
        CGFloat pickerViewHeight = self.view.frame.size.height;
        CGFloat pickerViewWidth = self.view.frame.size.width;
        [self.datePicker setFrame:CGRectMake(0.0f,
                                             pickerViewHeight,
                                             pickerViewWidth,
                                             pickerViewHeight)];
        [self.view addSubview:self.datePicker];
        
        [UIView animateWithDuration:0.4f
                         animations:^{
                             [self.datePicker setFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  pickerViewWidth,
                                                                  pickerViewHeight)];
                         } completion:^(BOOL finished) {
                             self.isOpeningPicker = NO;
                         }];
    }
}

- (void)openPicker:(JARadioComponent *)radioComponent
{
    if(!self.isOpeningPicker)
    {
        self.isOpeningPicker = YES;
        if(VALID_NOTEMPTY(self.picker, JAPicker))
        {
            [self.picker removeFromSuperview];
            self.picker = nil;
        }
        
        if(VALID_NOTEMPTY(self.datePicker, JADatePicker))
        {
            [self.datePicker removeFromSuperview];
            self.datePicker = nil;
        }
        
        self.radioComponent = radioComponent;
        
        self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
        [self.picker setDelegate:self];
        
        NSMutableArray *dataSource = [[NSMutableArray alloc] init];
        if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent) && VALID_NOTEMPTY([self.radioComponent dataset], NSArray))
        {
            dataSource = [[self.radioComponent dataset] copy];
        }
        
        NSString *selectedValue = [radioComponent getSelectedValue];
        
        [self.picker setDataSourceArray:[dataSource copy]
                           previousText:selectedValue];
        
        CGFloat pickerViewHeight = self.view.frame.size.height;
        CGFloat pickerViewWidth = self.view.frame.size.width;
        [self.picker setFrame:CGRectMake(0.0f,
                                         pickerViewHeight,
                                         pickerViewWidth,
                                         pickerViewHeight)];
        [self.view addSubview:self.picker];
        
        [UIView animateWithDuration:0.4f
                         animations:^{
                             [self.picker setFrame:CGRectMake(0.0f,
                                                              0.0f,
                                                              pickerViewWidth,
                                                              pickerViewHeight)];
                         } completion:^(BOOL finished) {
                             self.isOpeningPicker = NO;
                         }];
    }
}


#pragma mark JAPickerDelegate
-(void)selectedRow:(NSInteger)selectedRow
{
    if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent))
    {
        if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent) && VALID_NOTEMPTY([self.radioComponent dataset], NSArray) && selectedRow < [[self.radioComponent dataset] count])
        {
            [self.radioComponent setValue:[[self.radioComponent dataset] objectAtIndex:selectedRow]];
        }
    }
    
    [self closePicker];
}

- (void)closePicker
{
    CGRect frame = self.picker.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.picker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.picker removeFromSuperview];
                         self.picker = nil;
                     }];
}
#pragma mark JADatePickerDelegate
- (void)selectedDate:(NSDate*)selectedDate
{
    if(VALID_NOTEMPTY(self.birthdayComponent, JABirthDateComponent))
    {
        [self.birthdayComponent setValue:selectedDate];
    }
    
    [self closeDatePicker];
}

- (void)closeDatePicker
{
    CGRect frame = self.datePicker.frame;
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.datePicker.frame = frame;
                     } completion:^(BOOL finished) {
                         [self.datePicker removeFromSuperview];
                         self.datePicker = nil;
                     }];
}

#pragma mark - Keyboard notifications

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat height = kbSize.height;
    if(self.view.frame.size.width == kbSize.height)
    {
        height = kbSize.width;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentScrollView setFrame:CGRectMake(self.view.bounds.origin.x,
                                                    self.view.bounds.origin.y,
                                                    self.view.bounds.size.width,
                                                    self.view.bounds.size.height - height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.contentScrollView setFrame:self.view.bounds];
    }];
}

@end
