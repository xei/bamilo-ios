//
//  SignInViewController.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "DataManager.h"
#import "SignInViewController.h"
#import "InputTextFieldControl.h"
#import "UIScrollView+Extension.h"

//Legacy importing
#import "RICustomer.h"
#import "JAUtils.h"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet InputTextFieldControl *emailControl;
@property (weak, nonatomic) IBOutlet InputTextFieldControl *passwordControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UITextField *activeField;
@property (weak, nonatomic) IBOutlet UIButton *continueWithoutLoginBtn;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    self.scrollView.delegate = self;
}

- (void)setupView {
    
    FormItemValidation *emailValidation = [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter: [NSString emailRegxPattern]];
    FormItemModel *emailControlModel = [[FormItemModel alloc]
                                        initWithTitle:nil
                                        andIcon:[UIImage imageNamed:@"Email"]
                                        placeholder:@"ایمیل"
                                        type:InputTextFieldControlTypeEmail
                                        validation:emailValidation];
    
    [self.emailControl setModel: emailControlModel];
    
    FormItemValidation *passValidation = [[FormItemValidation alloc] initWithRequired:YES max:50 min:6 withRegxPatter:nil];
    FormItemModel *passwordControlModel = [[FormItemModel alloc]
                                           initWithTitle:nil
                                           andIcon:[UIImage imageNamed:@"Password"]
                                           placeholder:@"کلمه عبور"
                                           type:InputTextFieldControlTypePassword
                                           validation:passValidation];
    
    [self.passwordControl setModel: passwordControlModel];
    
    [self.continueWithoutLoginBtn setHidden: !self.showContinueWithoutLogin];

    self.emailControl.input.textField.delegate = self;
    self.passwordControl.input.textField.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [self registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self unregisterForKeyboardNotifications];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - keyboard notifications

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, self.activeField.frame.origin) ) {
        [self.scrollView scrollRectToVisible:self.activeField.frame animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

#pragma mark - TextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.activeField = nil;
}


- (IBAction)submitLogin:(id)sender {
    
    [self.view endEditing:YES];
    
    if (![self.emailControl isValid] || ![self.passwordControl isValid]) {
        return;
    }
    
    [[DataManager sharedInstance] loginUser:self withUsername:[self.emailControl getStringValue] password:[self.passwordControl getStringValue] completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
        } else {
            for(NSDictionary* errorField in [error.userInfo objectForKey:@"errorMessages"]) {
                NSString *fieldName = errorField[@"field"];
                if ([fieldName isEqualToString:@"password"]) {
                    [self.passwordControl showErrorMsg:errorField[@"message"]];
                } else if ([fieldName isEqualToString:@"email"]) {
                    [self.emailControl showErrorMsg:errorField[@"message"]];
                }
            }
        }
    }];
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    
    // Legacy actions after login
    [RICustomer resetCustomerAsGuest];
    if ([data isKindOfClass:[NSDictionary class]]) {
        NSDictionary* responseDictionary = (NSDictionary*)data;
        
        RICustomer *customerObject = [responseDictionary objectForKey:@"customer"];
        
        NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
        [trackingDictionary setValue:customerObject.customerId forKey:kRIEventLabelKey];
        [trackingDictionary setValue:@"LoginSuccess" forKey:kRIEventActionKey];
        [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
        [trackingDictionary setValue:customerObject.customerId forKey:kRIEventUserIdKey];
        [trackingDictionary setValue:customerObject.firstName forKey:kRIEventUserFirstNameKey];
        [trackingDictionary setValue:customerObject.lastName forKey:kRIEventUserLastNameKey];
        [trackingDictionary setValue:customerObject.birthday forKey:kRIEventBirthDayKey];
        [trackingDictionary setValue:[RIApi getCountryIsoInUse] forKey:kRIEventShopCountryKey];
        [trackingDictionary setValue:[JAUtils getDeviceModel] forKey:kRILaunchEventDeviceModelDataKey];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        [trackingDictionary setValue:[infoDictionary valueForKey:@"CFBundleVersion"] forKey:kRILaunchEventAppVersionDataKey];
        if(self.fromSideMenu) {
            [trackingDictionary setValue:@"Side menu" forKey:kRIEventLocationKey];
        } else {
            [trackingDictionary setValue:@"My account" forKey:kRIEventLocationKey];
        }
        
        [trackingDictionary setValue:customerObject.gender forKey:kRIEventGenderKey];
        [trackingDictionary setValue:customerObject.createdAt forKey:kRIEventAccountDateKey];
        
        if (customerObject.birthday) {
            NSDate* now = [NSDate date];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSDate *dateOfBirth = [dateFormatter dateFromString:customerObject.birthday];
            NSDateComponents* ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:0];
            [trackingDictionary setValue:[NSNumber numberWithInteger:[ageComponents year]] forKey:kRIEventAgeKey];
        }
        
        NSNumber *numberOfPurchases = [[NSUserDefaults standardUserDefaults] objectForKey:kRIEventAmountTransactions];
        [trackingDictionary setValue:numberOfPurchases forKey:kRIEventAmountTransactions];
        
        [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventLoginSuccess]
                                                  data:[trackingDictionary copy]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification
                                                            object:customerObject.wishlistProducts];
        
        NSMutableDictionary *userInfo = [NSMutableDictionary new];
        if (self.fromSideMenu) {
            [userInfo setObject:@YES forKey:@"from_side_menu"];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kRunBlockAfterAuthenticationNotification object:self.nextStepBlock userInfo:userInfo];
    }
}


- (IBAction)forgotPasswordButtonPressed:(id)sender {
    [self.delegate wantsToShowForgetPassword];
}

- (IBAction)continueWithoutLoginBtnTapped:(id)sender {
    [self.delegate wantsToContinueWithoutLogin];
}
@end
