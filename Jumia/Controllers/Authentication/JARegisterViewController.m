//
//  JARegisterViewController.m
//  Jumia
//
//  Created by Jose Mota on 01/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JARegisterViewController.h"
#import "JAUtils.h"
#import "JAPicker.h"
#import "JADatePicker.h"
#import "RIForm.h"
#import "RIField.h"
#import "RIFieldDataSetComponent.h"
#import "RICustomer.h"
#import "JABottomBar.h"
#import "JATextFieldComponent.h"
#import "RIPhonePrefix.h"
#import "JAAuthenticationViewController.h"

#define kTopMargin 36.f
#define kLateralMargin 16.f
#define kHeaderToTopMess 6.f
#define kTopMessToDynamicForm 36.f

@interface JARegisterViewController ()
<
JADynamicFormDelegate,
JAPickerDelegate,
JADatePickerDelegate,
JADynamicFormDelegate
>
{
    UIView *_firstResponder;
    CGFloat o;
    UIImageView *_userIconView;
}

@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (nonatomic) UILabel *headerLabel;
@property (nonatomic) UILabel *topMessageLabel;
@property (strong, nonatomic) JABottomBar *registerButton;
@property (strong, nonatomic) JADynamicForm *dynamicForm;

@property (strong, nonatomic) JABirthDateComponent *birthdayComponent;
@property (strong, nonatomic) JARadioComponent *radioComponent;
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) JADatePicker *datePicker;
@property (strong, nonatomic) JACheckBoxComponent *checkBoxComponent;

@property (nonatomic, assign)BOOL isOpeningPicker;

@property (assign, nonatomic) RIApiResponse apiResponse;

@property (nonatomic) CGFloat contentScrollOriginalHeight;

@property (nonatomic) NSArray *phonePrefixes;

@end

@implementation JARegisterViewController

- (UIScrollView *)mainScrollView
{
    if (!VALID(_mainScrollView, UIScrollView)) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(kLateralMargin, self.viewBounds.origin.y, self.viewBounds.size.width - 2*kLateralMargin, self.viewBounds.size.height)];
        [_mainScrollView setShowsHorizontalScrollIndicator:NO];
        [_mainScrollView setShowsVerticalScrollIndicator:NO];
        [_mainScrollView setContentSize:_mainScrollView.bounds.size];
    }
    return _mainScrollView;
}

- (UILabel *)headerLabel
{
    if (!VALID_NOTEMPTY(_headerLabel, UILabel)) {
        _headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kTopMargin, self.mainScrollView.width, 200)];
        [_headerLabel setNumberOfLines:0];
        [_headerLabel setTextAlignment:NSTextAlignmentCenter];
        [_headerLabel setFont:JADisplay2Font];
        [_headerLabel setTextColor:JABlackColor];
        [_headerLabel setText:STRING_WELCOME];
        [_headerLabel sizeToFit];
        [_headerLabel setWidth:self.view.width - 2*kLateralMargin];
    }
    return _headerLabel;
}

- (UILabel *)topMessageLabel
{
    if (!VALID_NOTEMPTY(_topMessageLabel, UILabel)) {
        _topMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerLabel.frame) + kHeaderToTopMess, self.mainScrollView.width, 200)];
        [_topMessageLabel setNumberOfLines:0];
        [_topMessageLabel setTextAlignment:NSTextAlignmentCenter];
        [_topMessageLabel setFont:JACaptionFont];
        [_topMessageLabel setTextColor:JABlack800Color];
        [_topMessageLabel setText:STRING_NEW_TO_JUMIA];
        [_topMessageLabel sizeToFit];
        [_topMessageLabel setWidth:self.view.width - 2*kLateralMargin];
    }
    return _topMessageLabel;
}

- (JACheckBoxComponent *)checkBoxComponent
{
    if (!VALID_NOTEMPTY(_checkBoxComponent, JACheckBoxComponent)) {
        _checkBoxComponent = [JACheckBoxComponent getNewJACheckBoxComponent];
#warning TODO FONT
        _checkBoxComponent.labelText.font = [UIFont fontWithName:kFontRegularName size:_checkBoxComponent.labelText.font.pointSize];
        [_checkBoxComponent.labelText setText:STRING_REMEMBER_EMAIL];
        [_checkBoxComponent setHidden:YES];
        [_checkBoxComponent.switchComponent setOn:NO];
    }
    return _checkBoxComponent;
}

- (JABottomBar *)registerButton
{
    if (!VALID_NOTEMPTY(_registerButton, JABottomBar)) {
        _registerButton = [[JABottomBar alloc] initWithFrame:CGRectMake(6.f, self.view.height, self.view.width - 2*6.f, kBottomDefaultHeight)];
        [_registerButton addButton:[STRING_CONTINUE uppercaseString] target:self action:@selector(registerButtonPressed:)];
    }
    return _registerButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideKeyboard) name:kOpenMenuNotification object:nil];
    self.apiResponse = RIApiResponseSuccess;
    self.screenName = @"Register";
    self.isOpeningPicker = NO;
    self.A4SViewControllerAlias = @"ACCOUNT";
    self.navBarLayout.title = STRING_CREATE_ACCOUNT;
    
    [self.view addSubview:self.mainScrollView];
    [self.mainScrollView addSubview:self.headerLabel];
    [self.mainScrollView addSubview:self.topMessageLabel];
    [self.mainScrollView addSubview:self.checkBoxComponent];
    [self.view addSubview:self.registerButton];
    
    if(self.apiResponse==RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess)
    {
        [self showLoading];
    }
    
    [self getRegisterForm];
}

- (void)onOrientationChanged
{
    [super onOrientationChanged];
    [self closePickers];
    [self setupViews];
}

- (void)getRegisterForm
{
    [RIForm getForm:@"register"
       successBlock:^(RIForm *form) {
           [self hideLoading];
           
           self.dynamicForm = [[JADynamicForm alloc] initWithForm:form values:@{@"email" : self.authenticationEmail} startingPosition:CGRectGetMaxY(self.topMessageLabel.frame) + kTopMessToDynamicForm  hasFieldNavigation:YES];
           [self.dynamicForm setDelegate:self];
           for(UIView *view in self.dynamicForm.formViews)
           {
               [self.mainScrollView addSubview:view];
           }
           
           [self setupViews];
           [self.mainScrollView setHidden:NO];
           [self removeErrorView];
       } failureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
           self.apiResponse = apiResponse;
           if(RIApiResponseMaintenancePage == apiResponse)
           {
               [self showMaintenancePage:@selector(getRegisterForm) objects:nil];
           }
           else if(RIApiResponseKickoutView == apiResponse)
           {
               [self showKickoutView:@selector(getRegisterForm) objects:nil];
           }
           else
           {
               BOOL noConnection = NO;
               if (RIApiResponseNoInternetConnection == apiResponse)
               {
                   noConnection = YES;
               }
               [self.mainScrollView setHidden:YES];
               [self showErrorView:noConnection startingY:0.0f selector:@selector(getRegisterForm) objects:nil];
           }
           
           [self hideLoading];
       }];
}

- (void)setupViews
{
    CGFloat y = self.mainScrollView.contentOffset.y;
    [self.mainScrollView setWidth:self.viewBounds.size.width - 2*kLateralMargin];
    [self.headerLabel setWidth:self.mainScrollView.width];
    [self.topMessageLabel setWidth:self.mainScrollView.width];
    CGFloat xOffset = 40;
    CGFloat imageSpace = 30;
    for(JADynamicField *view in self.dynamicForm.formViews)
    {
        [view setFrame:CGRectMake(xOffset, view.y, self.mainScrollView.width - xOffset, view.height)];
        if (view.iconImageView) {
            [view.iconImageView setX:(imageSpace-view.iconImageView.width)/2];
            if (!view.iconImageView.superview) {
                [self.mainScrollView addSubview:view.iconImageView];
            }
        }else{
            if ([view isKindOfClass:[JATextFieldComponent class]] && [view.field.key isEqualToString:@"last_name"]) {
                JATextFieldComponent *textFieldComponent = (JATextFieldComponent *)view;
                UIImage *iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"ic_user_form"]];
                CGFloat imageY = textFieldComponent.y + textFieldComponent.textField.y - iconImage.size.height;
                if (!_userIconView) {
                    _userIconView = [[UIImageView alloc] initWithImage:iconImage];
                    [self.mainScrollView addSubview:_userIconView];
                }
                [_userIconView setFrame:CGRectMake((imageSpace-iconImage.size.width)/2, imageY, iconImage.size.width, iconImage.size.height)];
            }
        }
    }
    
    CGFloat yOffset = CGRectGetMaxY([(UIView *)[self.dynamicForm.formViews lastObject] frame]) + 10.f;
    
    [self.checkBoxComponent setFrame:CGRectMake(0,
                                                yOffset,
                                                self.mainScrollView.width,
                                                self.checkBoxComponent.frame.size.height)];
    
    yOffset = CGRectGetMaxY(self.checkBoxComponent.frame) + 10.0f;
    [self.registerButton setFrame:CGRectMake(0,
                                             self.viewBounds.size.height - self.registerButton.height,
                                             self.view.width,
                                             self.registerButton.height)];
    
    [self.mainScrollView setFrame:CGRectMake(kLateralMargin, 0.f, self.viewBounds.size.width - 2*kLateralMargin, self.registerButton.y)];
    
    self.contentScrollOriginalHeight = self.mainScrollView.frame.size.height;
    
    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.frame.size.width, yOffset + o)];
    [self.mainScrollView setContentOffset:CGPointMake(self.mainScrollView.contentOffset.x, y)];
    
    [self hideLoading];
    
    [self finishedFormLoading];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
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

#pragma mark - Keyboard events
/*
 alternative keyboard scroll
    in case we think that the old one should be replaced
 */
- (void)keyboardChanged:(NSNotification *)notification
{
//    // get the size of the keyboard
//    CGFloat keyboardY = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y - self.view.y;
//    
//    CGFloat scrollOffset = 0;
//    UIView *firstResponder = [self findFirstResponder];
//    if (firstResponder) {
//        //    CGFloat firstResponderEnds = -[_firstResponder convertPoint:CGPointMake(0, CGRectGetMaxY(_firstResponder.frame)) fromView:nil].y;
//        CGFloat firstResponderEnds = CGRectGetMaxY(_firstResponder.frame);
//        
//        scrollOffset = firstResponderEnds - keyboardY;
//        
//        if (scrollOffset < 0) {
//            scrollOffset = 0;
//        }
//    }
//    NSLog(@"offset: %f", scrollOffset);
//    [self.mainScrollView setContentOffset:CGPointMake(0, scrollOffset) animated:YES];
//    
//    
//    CGFloat keyboardStartY = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].origin.y - self.view.y;
//    CGFloat keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//    o = keyboardStartY - keyboardY;
//    if (o == -keyboardHeight) {
//        o = 0;
//    }
//    NSLog(@"o: %f", o);
//    [self.mainScrollView setContentSize:CGSizeMake(self.mainScrollView.width, self.mainScrollView.height + o)];
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
        [self.mainScrollView setFrame:CGRectMake(self.mainScrollView.frame.origin.x,
                                                    self.mainScrollView.frame.origin.y,
                                                    self.mainScrollView.frame.size.width,
                                                    self.contentScrollOriginalHeight - height)];
    }];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainScrollView setFrame:CGRectMake(self.mainScrollView.frame.origin.x,
                                                    self.mainScrollView.frame.origin.y,
                                                    self.mainScrollView.frame.size.width,
                                                    self.contentScrollOriginalHeight)];
    }];
}

- (void)hideKeyboard
{
    [[self findFirstResponder] resignFirstResponder];
}

#pragma mark - DynamicForms delegate

- (void)changedFocus:(UIView *)view
{
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
        
        RICustomer *customerObject = [(NSDictionary*)object objectForKey:@"customer"];
        
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
        [trackingDictionary setValue:@"CreateSuccess" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
        [trackingDictionary setValue:customerObject.idCustomer forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:customerObject.firstName forKey:kRIEventUserFirstNameKey];
        [trackingDictionary setValue:customerObject.lastName forKey:kRIEventUserLastNameKey];
        [trackingDictionary setValue:customerObject.gender forKey:kRIEventGenderKey];
        [trackingDictionary setValue:customerObject.birthday forKey:kRIEventBirthDayKey];
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
        
        [self.dynamicForm resetValues];
        
        [self hideLoading];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                            object:nil];

        
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
            [self showMessage:STRING_NO_CONNECTION success:NO];
        }
        else if (VALID_NOTEMPTY(errorObject, NSDictionary))
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

- (void)doneClicked:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark JADatePickerDelegate
- (void)selectedDate:(NSDate*)selectedDate
{
    if(VALID_NOTEMPTY(self.birthdayComponent, JABirthDateComponent))
    {
        [self.birthdayComponent setValue:selectedDate];
    }
    
    [self closePickers];
}

- (void)closePickers
{
    CGRect frameDatePicker = self.datePicker.frame;
    CGRect framePhonePrefix = self.picker.frame;
    frameDatePicker.origin.y = self.view.frame.size.height;
    framePhonePrefix.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.4f
                     animations:^{
                         self.datePicker.frame = frameDatePicker;
                         self.picker.frame = framePhonePrefix;
                     } completion:^(BOOL finished) {
                         [self.datePicker removeFromSuperview];
                         [self.picker removeFromSuperview];
                         self.datePicker = nil;
                         self.picker = nil;
                     }];
}

- (void)selectedRow:(NSInteger)selectedRow
{
    if(VALID_NOTEMPTY(self.radioComponent, JARadioComponent))
    {
        RIPhonePrefix *prefix = (RIPhonePrefix *)[self.phonePrefixes objectAtIndex:selectedRow];
        
        
        [self.radioComponent setValue:[prefix.value stringValue]];
        [self.radioComponent.textField setText:[prefix label]];
    }
    [self closePickers];
}

- (void)openPicker:(JARadioComponent *)radioComponent
{
    if (VALID_NOTEMPTY(self.phonePrefixes, NSArray)) {
        if (VALID(self.picker, JAPicker)) {
            [self.picker removeFromSuperview];
        }
        
        
        self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
        [self.view addSubview:self.picker];
        [self.picker setDelegate:self];
        
        NSMutableArray *dataSource = [[NSMutableArray alloc] init];
        for(id currentObject in self.phonePrefixes)
        {
            NSString *title = @"";
            if(VALID_NOTEMPTY(currentObject, RIPhonePrefix))
            {
                title = ((RIPhonePrefix*) currentObject).label;
            }
            [dataSource addObject:title];
        }
        
        [self.picker setDataSourceArray:[dataSource copy]
                           previousText:[self getPickerSelectedRow]
                        leftButtonTitle:nil];
        
        CGFloat pickerViewHeight = self.view.frame.size.height;
        CGFloat pickerViewWidth = self.view.frame.size.width;
        [self.picker setFrame:CGRectMake(0.0f,
                                         pickerViewHeight,
                                         pickerViewWidth,
                                         pickerViewHeight)];
        
        [UIView animateWithDuration:0.4f
                         animations:^{
                             [self.picker setFrame:CGRectMake(0.0f,
                                                              0.0f,
                                                              pickerViewWidth,
                                                              pickerViewHeight)];
                         }];
    }
}

-(NSString*)getPickerSelectedRow
{
    NSString *selectedValue = [self.radioComponent getSelectedValue];
    NSString *selectedRow = @"";
    if(VALID_NOTEMPTY(selectedValue, NSString))
    {
        if(VALID_NOTEMPTY(self.phonePrefixes, NSArray))
        {
            for (int i = 0; i < [self.phonePrefixes count]; i++)
            {
                RIPhonePrefix* selectedObject = [self.phonePrefixes objectAtIndex:i];
                if(VALID_NOTEMPTY(selectedObject, RIPhonePrefix))
                {
                    if([selectedValue isEqualToString:[selectedObject.value stringValue]])
                    {
                        selectedRow = selectedObject.label;
                        break;
                    }
                }
            }
        }
    }
    return selectedRow;
}

- (void)downloadLocalesForComponents:(NSDictionary *)componentDictionary
{
    if (VALID_NOTEMPTY([componentDictionary objectForKey:@"phonePrefixComponent"], JARadioComponent))
    {
        self.radioComponent = [componentDictionary objectForKey:@"phonePrefixComponent"];
        [RICountry getCountryPhonePrefixesWithSuccessBlock:^(NSArray *prefixes) {
            for (RIPhonePrefix *phonePrefix in prefixes) {
                if (phonePrefix.isDefault) {
                    [self.radioComponent setValue:[phonePrefix.value stringValue]];
                    [self.radioComponent.textField setText:phonePrefix.label];
                    [self.radioComponent.textField setEnabled:YES];
                }
            }
            self.phonePrefixes = prefixes;
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            
        }];
        
    }
}

@end
