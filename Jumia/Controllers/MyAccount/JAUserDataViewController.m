//
//  JAUserDataViewController.m
//  Jumia
//
//  Created by lucianoduarte on 15/12/15.
//  Copyright © 2015 Rocket Internet. All rights reserved.
//

#import "JAUserDataViewController.h"
#import "JADynamicForm.h"
#import "JAPicker.h"
#import "JADatePicker.h"
#import "JAProductInfoHeaderLine.h"
#import "RIForm.h"
#import "RIField.h"
#import "JABottomBar.h"
#import "RIPhonePrefix.h"
#import "RICustomer.h"
#import "JAUtils.h"

#define kSideMargin 16.f
#define kButtonsMargin 16.f
#define kPasswordHeaderMargin 20.f
#define kPasswordMargin 16.f
#define kIconToTextFieldMargin 10.f

@interface JAUserDataViewController ()
<
    JADynamicFormDelegate,
    JAPickerDelegate,
    JADatePickerDelegate
>
{
    UIView *_firstResponder;
    UIImageView *_userIconView;
}

//main view
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (assign, nonatomic) CGRect mainScrollViewInitialRect;

//user form
@property (strong, nonatomic) JAProductInfoHeaderLine *personalDataHeader;
@property (strong, nonatomic) JADynamicForm *userForm;
@property (strong, nonatomic) JABottomBar *saveButton;

//user form components
@property (strong, nonatomic) JABirthDateComponent *birthdayComponent;
@property (strong, nonatomic) JADatePicker *datePicker;
@property (strong, nonatomic) JAPicker *picker;
@property (strong, nonatomic) JARadioComponent *radioComponent;
@property (nonatomic, assign) BOOL isOpeningPicker;
@property (strong, nonatomic) NSArray *phonePrefixes;
@property (strong, nonatomic) NSArray *genders;

//password form
@property (strong, nonatomic) JAProductInfoHeaderLine *passwordHeader;
@property (strong, nonatomic) JADynamicForm *changePasswordForm;
@property (strong, nonatomic) JABottomBar *changePasswordButton;
@property (strong, nonatomic) UIView* changePasswordView;

@property (assign, nonatomic) RIApiResponse apiResponse;
@property (assign, nonatomic) CGFloat currentY;


@end

@implementation JAUserDataViewController

- (UIScrollView *)mainScrollView
{
    if (!VALID(_mainScrollView, UIScrollView)) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(
                                                                         0,
                                                                         self.viewBounds.origin.y,
                                                                         self.viewBounds.size.width,
                                                                         self.viewBounds.size.height)];
        [_mainScrollView setShowsHorizontalScrollIndicator:NO];
        [_mainScrollView setShowsVerticalScrollIndicator:NO];
        [_mainScrollView setContentSize:_mainScrollView.bounds.size];
        
        [self.mainScrollView addSubview:self.personalDataHeader];
    }
    return _mainScrollView;
}

- (JAProductInfoHeaderLine *)personalDataHeader
{
    if (!VALID_NOTEMPTY(_personalDataHeader, JAProductInfoHeaderLine)) {
        _personalDataHeader = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(
                                                                                        0,
                                                                                        0,
                                                                                        self.viewBounds.size.width,
                                                                                        kProductInfoHeaderLineHeight)];
        [_personalDataHeader setTitle:[STRING_YOUR_PERSONAL_DATA uppercaseString]];
    }
    return _personalDataHeader;
}

- (JABottomBar *)saveButton
{
    if (!VALID_NOTEMPTY(_saveButton, JABottomBar)) {
        _saveButton = [[JABottomBar alloc] initWithFrame:CGRectMake(
                                                                    kSideMargin,
                                                                    CGRectGetMaxY(self.personalDataHeader.frame) + kButtonsMargin,
                                                                    self.viewBounds.size.width - (2 * kSideMargin),
                                                                    kBottomDefaultHeight)];
        [_saveButton addButton:[STRING_SAVE_LABEL uppercaseString] target:self action:@selector(saveButtonPressed)];
    }
    return _saveButton;
}

- (JAProductInfoHeaderLine *)passwordHeader
{
    if (!VALID_NOTEMPTY(_passwordHeader, JAProductInfoHeaderLine)) {
        _passwordHeader = [[JAProductInfoHeaderLine alloc] initWithFrame:CGRectMake(
                                                                                    0,
                                                                                    0,
                                                                                    self.viewBounds.size.width,
                                                                                    kProductInfoHeaderLineHeight)];
        [_passwordHeader setTitle:[STRING_PASSWORD uppercaseString]];
    }
    return _passwordHeader;
}

- (JABottomBar *)changePasswordButton
{
    if (!VALID_NOTEMPTY(_changePasswordButton, JABottomBar)) {
        _changePasswordButton = [[JABottomBar alloc] initWithFrame:CGRectMake(
                                                                    kSideMargin,
                                                                    CGRectGetMaxY(self.passwordHeader.frame) + kButtonsMargin,
                                                                    self.viewBounds.size.width - (2 * kSideMargin),
                                                                    kBottomDefaultHeight)];
        [_changePasswordButton addButton:[STRING_CHANGE_PASSWORD uppercaseString] target:self action:@selector(changePasswordButtonPressed)];
    }
    return _changePasswordButton;
}

- (UIView *)changePasswordView {
    if (!VALID_NOTEMPTY(_changePasswordView, UIView)) {
        _changePasswordView = [UIView new];
    }
    return _changePasswordView;
}

#pragma mark viewLifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.apiResponse == RIApiResponseMaintenancePage || self.apiResponse == RIApiResponseKickoutView || self.apiResponse == RIApiResponseSuccess) {
        [self showLoading];
    }
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
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
    self.screenName = STRING_PROFILE;
    self.navBarLayout.title = STRING_PROFILE;
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showCartButton = YES;
    self.navBarLayout.showSearchButton = YES;
    self.isOpeningPicker = NO;
    
    [self.view addSubview:self.mainScrollView];
    
    //requests user form and when it is finished
    //requests change pass form
    [self requestUserEditForm];
    
    if (self.firstLoading) {
        NSNumber *timeInMillis = [NSNumber numberWithInteger:([self.startLoadingTime timeIntervalSinceNow] * -1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName];
        self.firstLoading = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self hideKeyboard];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[RITrackingWrapper sharedInstance] trackScreenWithName:@"UserData"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onOrientationChanged
{
    [super onOrientationChanged];
    
    [self closePickers];
    [self setupUserEditFormViews];
    [self setupChangePasswordFormViews];
    [self setupFixedElements];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

#pragma mark actions
- (void)requestUserEditForm
{
    [RIForm getForm:@"edit"
       successBlock:^(RIForm *form) {
           self.userForm = [[JADynamicForm alloc] initWithForm:form
                                              startingPosition:CGRectGetMaxY(self.personalDataHeader.frame)
                                                     widthSize:self.mainScrollView.width - (kSideMargin * 2)
                                            hasFieldNavigation:YES];
           [self.userForm setDelegate:self];
           
           for (UIView *view in self.userForm.formViews) {
               [self.mainScrollView addSubview:view];
           }
           
           [self.mainScrollView addSubview:self.saveButton];
           
           [self setupUserEditFormViews];
           [self requestChangePasswordForm];
           [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
       } failureBlock:^(RIApiResponse apiResponse, NSArray *errorMessage) {
           self.apiResponse = apiResponse;
           [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(requestUserEditForm) objects:nil];
           [self hideLoading];
       }];
}

- (void)requestChangePasswordForm
{
    if (!([RICustomer checkIfUserIsLoggedByFacebook] || [RICustomer checkIfUserIsLoggedAsGuest])) {
        
        [RIForm getForm:@"change_password" successBlock:^(RIForm *form)
         {
             self.changePasswordForm = [[JADynamicForm alloc] initWithForm:form
                                                          startingPosition:CGRectGetMaxY(self.passwordHeader.frame) + kPasswordMargin
                                                                 widthSize:self.mainScrollView.width - (kSideMargin * 2)
                                                        hasFieldNavigation:YES];
             self.changePasswordForm.delegate = self;
             
             for (UIView *view in self.changePasswordForm.formViews) {
                 [self.changePasswordView addSubview:view];
             }
             
             [self.mainScrollView addSubview:self.changePasswordView];
             [self.changePasswordView addSubview:self.passwordHeader];
             [self.changePasswordView addSubview:self.changePasswordButton];
             
             [self setupChangePasswordFormViews];
             [self setupFixedElements];
             [self onSuccessResponse:RIApiResponseSuccess messages:nil showMessage:NO];
         } failureBlock:^(RIApiResponse apiResponse,  NSArray *errorMessage) {
             self.apiResponse = apiResponse;
             [self onErrorResponse:apiResponse messages:nil showAsMessage:NO selector:@selector(requestUserEditForm) objects:nil];
             [self hideLoading];
         }];
    }
}

- (void)saveButtonPressed
{
    [self showLoading];
    [self hideKeyboard];
    
    if ([self.userForm checkErrors]) {
        [self onErrorResponse:RIApiResponseSuccess messages:@[self.userForm.firstErrorInFields] showAsMessage:YES selector:@selector(saveButtonPressed) objects:nil];
        [self hideLoading];
        return;
    }
    
    [RIForm sendForm:[self.userForm form]
          parameters:[self.userForm getValues]
        successBlock:^(id object) {
        [self onSuccessResponse:RIApiResponseSuccess messages:@[STRING_USER_DATA_EDITED_SUCCESS] showMessage:YES];
        [self hideLoading];
    } andFailureBlock:^(RIApiResponse apiResponse,  id errorObject) {
        if (VALID_NOTEMPTY(errorObject, NSDictionary)) {
            [self.userForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                [self onErrorResponse:RIApiResponseUnknownError messages:@[message] showAsMessage:YES selector:@selector(saveButtonPressed) objects:nil];
            }];
        } else if(VALID_NOTEMPTY(errorObject, NSArray)) {
            [self.userForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                [self onErrorResponse:RIApiResponseUnknownError messages:@[message] showAsMessage:YES selector:@selector(saveButtonPressed) objects:nil];
            }];
        } else {
            [self onErrorResponse:RIApiResponseUnknownError messages:@[STRING_ERROR] showAsMessage:YES selector:@selector(saveButtonPressed) objects:nil];
        }
        [self hideLoading];
    }];
}

- (void)changePasswordButtonPressed
{
    [self showLoading];
    [self hideKeyboard];
    
    if ([self.changePasswordForm checkErrors]) {
        [self onErrorResponse:RIApiResponseSuccess messages:@[self.changePasswordForm.firstErrorInFields] showAsMessage:YES selector:@selector(changePasswordButtonPressed) objects:nil];
        [self hideLoading];
        return;
    }
    
    [RIForm sendForm:[self.changePasswordForm form]
          parameters:[self.changePasswordForm getValues]
        successBlock:^(id object) {
         [self onSuccessResponse:RIApiResponseSuccess messages:@[STRING_CHANGED_PASSWORD_SUCCESS] showMessage:YES];
         [self hideLoading];
         [self resetValues:self.changePasswordForm];
     } andFailureBlock:^(RIApiResponse apiResponse, id errorObject) {
         if (VALID_NOTEMPTY(errorObject, NSDictionary)) {
             [self.changePasswordForm validateFieldWithErrorDictionary:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(changePasswordButtonPressed) objects:nil];
             }];
         } else if(VALID_NOTEMPTY(errorObject, NSArray)) {
             [self.changePasswordForm validateFieldsWithErrorArray:errorObject finishBlock:^(NSString *message) {
                 [self onErrorResponse:apiResponse messages:@[message] showAsMessage:YES selector:@selector(changePasswordButtonPressed) objects:nil];
             }];
         } else {
             [self onErrorResponse:apiResponse messages:@[STRING_ERROR] showAsMessage:YES selector:@selector(changePasswordButtonPressed) objects:nil];
         }
         [self hideLoading];
     }];
}

#pragma mark geometryFunctions
- (void)setupUserEditFormViews
{
    [self.mainScrollView setWidth:self.viewBounds.size.width];
    [self.personalDataHeader setWidth:self.mainScrollView.width];
    
    CGFloat maxY = CGRectGetMaxY(self.personalDataHeader.frame);
    
    CGFloat xOffset = 56;
    CGFloat imageSpace = 30;
    
    for (JADynamicField *view in self.userForm.formViews) {
        [view setFrame:CGRectMake(xOffset,
                                  view.y,
                                  self.mainScrollView.width - xOffset - kSideMargin,
                                  view.height)];
        
        if (view.iconImageView) {
            [view.iconImageView setX:kSideMargin + ((imageSpace - view.iconImageView.width) / 2)];
            
            if (!view.iconImageView.superview) {
                [self.mainScrollView addSubview:view.iconImageView];
            }
        } else if ([view isKindOfClass:[JATextFieldComponent class]] && [view.field.key isEqualToString:@"last_name"]) {
            JATextFieldComponent *textFieldComponent = (JATextFieldComponent *)view;
            UIImage *iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"ic_user_form"]];
            CGFloat imageY = textFieldComponent.y + textFieldComponent.textField.y - iconImage.size.height;
            
            if (!_userIconView) {
                _userIconView = [[UIImageView alloc] initWithImage:iconImage];
                [self.mainScrollView addSubview:_userIconView];
            }
            
            [_userIconView setFrame:CGRectMake(
                                               kSideMargin + ((imageSpace - iconImage.size.width) / 2),
                                               imageY,
                                               iconImage.size.width,
                                               iconImage.size.height)];
        }
        
        maxY = CGRectGetMaxY(view.frame);
    }
    
    [self.saveButton setY:maxY + kButtonsMargin];
}

- (void)setupChangePasswordFormViews
{
    CGFloat maxY = CGRectGetMaxY(self.saveButton.frame);
    [self.changePasswordView setFrame:CGRectMake(0.f, maxY, self.mainScrollView.width, 0.f)];
    
    [self.passwordHeader setY:kPasswordHeaderMargin];
    [self.passwordHeader setWidth:self.mainScrollView.width];
    
    CGFloat formCurrY = 0.0f;
    for (JADynamicField *view in self.changePasswordForm.formViews) {
        [view setFrame:CGRectMake(
                                  kSideMargin,
                                  view.y,
                                  self.mainScrollView.width - (2 * kSideMargin),
                                  view.height)];
        formCurrY = CGRectGetMaxY(view.frame);
    }
    [self.changePasswordButton setY:formCurrY + kButtonsMargin];
    [self.changePasswordView setHeight:CGRectGetMaxY(self.changePasswordButton.frame)];
}

- (void)setupFixedElements
{
    [self.mainScrollView setFrame:CGRectMake(
                                             0,
                                             self.viewBounds.origin.y,
                                             self.viewBounds.size.width,
                                             self.viewBounds.size.height)];
    
    [self.mainScrollView setContentSize:CGSizeMake(
                                                   self.mainScrollView.width,
                                                   CGRectGetMaxY(self.changePasswordButton.frame))];
    
    self.mainScrollViewInitialRect = self.mainScrollView.frame;
    
    [self.saveButton setWidth:self.mainScrollView.width - (kSideMargin * 2)];
    [self.changePasswordButton setWidth:self.mainScrollView.width - (kSideMargin * 2)];
    
    if (RI_IS_RTL) {
        [self.view flipAllSubviews];
    }
}

#pragma mark - Done button
- (IBAction)doneClicked:(id)sender
{
    [self.view endEditing:YES];
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

#pragma mark JADatePickerDelegate
- (void)openDatePicker:(JABirthDateComponent *)birthdayComponent
{
    [self hideKeyboard];
    if (!self.isOpeningPicker) {
        self.isOpeningPicker = YES;
        
        if (VALID_NOTEMPTY(self.datePicker, JADatePicker)) {
            [self.datePicker removeFromSuperview];
            self.datePicker = nil;
        }
        
        if (VALID_NOTEMPTY(self.picker, JAPicker)) {
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
        [UIView animateWithDuration:0.4f
                         animations:^{
                             [self.datePicker setFrame:CGRectMake(0.0f,
                                                                  0.0f,
                                                                  pickerViewWidth,
                                                                  pickerViewHeight)];
                         } completion:^(BOOL finished) {
                             self.isOpeningPicker = NO;
                         }];
        [self.view addSubview:self.datePicker];
    }
}

- (void)selectedDate:(NSDate*)selectedDate
{
    if (VALID_NOTEMPTY(self.birthdayComponent, JABirthDateComponent)) {
        [self.birthdayComponent setValue:selectedDate];
    }
    
    [self closePickers];
}

#pragma mark JAPickerDelegate
- (void)openPicker:(JARadioComponent *)radioComponent
{
    [self hideKeyboard];
    
    self.radioComponent = radioComponent;
    
    if (VALID_NOTEMPTY(self.datePicker, JADatePicker)) {
        [self.datePicker removeFromSuperview];
        self.datePicker = nil;
    }
    
    if (VALID(self.picker, JAPicker)) {
        [self.picker removeFromSuperview];
        self.picker = nil;
    }
    
    self.picker = [[JAPicker alloc] initWithFrame:self.view.frame];
    [self.picker setDelegate:self];
    
    NSMutableArray *dataSource = [[NSMutableArray alloc] init];
    
    if ([radioComponent isComponentWithKey:@"gender"]
        && VALID_NOTEMPTY(radioComponent, JARadioComponent)
        && VALID_NOTEMPTY([radioComponent options], NSArray)) {
        
        for (id currentObject in [radioComponent options]) {
            if (VALID_NOTEMPTY(currentObject, NSString)) {
                [dataSource addObject:currentObject];
            }
        }
        self.genders = dataSource;
    } else if (VALID_NOTEMPTY(self.radioComponent, JARadioComponent)
               && VALID_NOTEMPTY(self.phonePrefixes, NSArray)) {
        
        for (id currentObject in self.phonePrefixes) {
            if (VALID_NOTEMPTY(currentObject, RIPhonePrefix)) {
                [dataSource addObject:((RIPhonePrefix*) currentObject).label];
            }
        }
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
    [self.view addSubview:self.picker];
}

- (void)selectedRow:(NSInteger)selectedRow
{   
    if (VALID_NOTEMPTY(self.radioComponent, JARadioComponent)) {
        if ([self.radioComponent isComponentWithKey:@"gender"]) {
            NSString *selectedValue = [self.genders objectAtIndex:selectedRow];
            [self.radioComponent setValue:selectedValue];
            [self.radioComponent.textField setText:selectedValue];
        } else {
            RIPhonePrefix *prefix = (RIPhonePrefix *)[self.phonePrefixes objectAtIndex:selectedRow];
            [self.radioComponent setValue:[prefix.value stringValue]];
            [self.radioComponent.textField setText:[prefix label]];
        }
    }
    
    [self closePickers];
}

- (NSString*)getPickerSelectedRow
{
    NSString *selectedValue = [self.radioComponent getSelectedValue];
    NSString *selectedRow = @"";
    if (VALID_NOTEMPTY(selectedValue, NSString)) {
        if ([self.radioComponent isComponentWithKey:@"gender"]) {
            selectedRow = [self.radioComponent getSelectedValue];
        } else {
            if (VALID_NOTEMPTY(self.phonePrefixes, NSArray)) {
                for (int i = 0; i < [self.phonePrefixes count]; i++) {
                    RIPhonePrefix* selectedObject = [self.phonePrefixes objectAtIndex:i];
                    if (VALID_NOTEMPTY(selectedObject, RIPhonePrefix) && [selectedValue isEqualToString:[selectedObject.value stringValue]]) {
                        selectedRow = selectedObject.label;
                        break;
                    }
                }
            }
        }
    }
    return selectedRow;
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

- (void)downloadLocalesForComponents:(NSDictionary *)componentDictionary
{
    if (VALID_NOTEMPTY([componentDictionary objectForKey:@"phonePrefixComponent"], JARadioComponent)) {
        self.radioComponent = [componentDictionary objectForKey:@"phonePrefixComponent"];
        
        [RICountry getCountryPhonePrefixesWithSuccessBlock:^(NSArray *prefixes) {
            for (RIPhonePrefix *phonePrefix in prefixes) {
                if ([self.radioComponent.field.value isEqualToString:[phonePrefix.value stringValue]]) {
                    [self.radioComponent setValue:[phonePrefix.value stringValue]];
                    [self.radioComponent.textField setText:phonePrefix.label];
                    [self.radioComponent.textField setEnabled:YES];
                    break;
                }
            }
            self.phonePrefixes = prefixes;
            
            [self hideLoading];
        } andFailureBlock:^(RIApiResponse apiResponse, NSArray *errorMessages) {
            
        }];
    } else if (VALID_NOTEMPTY([componentDictionary objectForKey:@"genderComponent"], JARadioComponent)) {
        self.radioComponent = [componentDictionary objectForKey:@"genderComponent"];
    }
}

#pragma mark - Keyboard notifications
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGFloat height = kbSize.height;
    if (self.view.frame.size.width == kbSize.height) {
        height = kbSize.width;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainScrollView setFrame:CGRectMake(self.mainScrollViewInitialRect.origin.x,
                                             self.mainScrollViewInitialRect.origin.y,
                                             self.mainScrollViewInitialRect.size.width,
                                             self.mainScrollViewInitialRect.size.height - height)];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.mainScrollView setFrame:self.mainScrollViewInitialRect];
    }];
}

- (void)hideKeyboard
{
    [self.userForm resignResponder];
    [self.changePasswordForm resignResponder];
}

#pragma mark - Helper functions
- (void)resetValues:(JADynamicForm *)form
{
    if (VALID_NOTEMPTY(form.formViews, NSMutableArray)) {
        for (UIView *view in form.formViews) {
            if ([view isKindOfClass:[JATextFieldComponent class]]) {
                JATextFieldComponent *textFieldComponent = (JATextFieldComponent *)view;
                [textFieldComponent.textField setText:@""];
            }
        }
    }
}

@end
