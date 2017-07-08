//
//  SignInViewController.m
//  Bamilo
//
//  Created by Ali Saeedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AuthenticationDataManager.h"
#import "SignInViewController.h"
#import "InputTextFieldControl.h"
#import "UIScrollView+Extension.h"
#import "EmarsysPredictManager.h"
#import "PushWooshTracker.h"
#import "EmarsysMobileEngage.h"
#import <Crashlytics/Crashlytics.h>

//Legacy importing
#import "RICustomer.h"
#import "JAUtils.h"

#import "Bamilo-Swift.h"

#define cLoginMethodEmail @"email"
#define cLoginMethodGoogle @"sso-google"

@interface SignInViewController ()
@property (weak, nonatomic) IBOutlet InputTextFieldControl *emailControl;
@property (weak, nonatomic) IBOutlet InputTextFieldControl *passwordControl;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *continueWithoutLoginBtn;
@property (weak, nonatomic) id ali;
@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    self.scrollView.delegate = self;
}

- (void)setupView {

    FormItemModel *emailControlModel = [FormItemModel emailWithFieldName:@"login[email]"];
    emailControlModel.icon = [UIImage imageNamed:@"Email"];
    [self.emailControl setModel: emailControlModel];
    
    FormItemModel *passwordControlModel = [FormItemModel passWordWithFieldName:@"login[password]"];
    passwordControlModel.icon = [UIImage imageNamed:@"Password"];
    [self.passwordControl setModel: passwordControlModel];
    
    [self.continueWithoutLoginBtn setHidden: !self.showContinueWithoutLogin];

    self.emailControl.input.textField.delegate = self;
    self.passwordControl.input.textField.delegate = self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self submitLogin:nil];
    return YES;
}

#pragma mark - submission form
- (IBAction)submitLogin:(id)sender {
    [self.view endEditing:YES];
    
    if (![self.emailControl isValid] || ![self.passwordControl isValid]) {
        [self.emailControl checkValidation];
        [self.passwordControl checkValidation];
        return;
    }
    
    [DataAggregator loginUser:self username:[self.emailControl getStringValue] password:[self.passwordControl getStringValue] completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            
            //EVENT: LOGIN / SUCCESS

            
            RICustomer *customer = [RICustomer getCurrentCustomer];
            [TrackerManager postEventWithSelector:[EventSelectors loginEventSelector] attributes:[EventAttributes loginWithLoginMethod:cLoginMethodEmail user:customer]];
            [[EmarsysMobileEngage sharedInstance] sendLogin:[[PushNotificationManager pushManager] getPushToken] completion:nil];
            [EmarsysPredictManager setCustomer:customer];
        
            [[PushWooshTracker sharedTracker] setUserID:customer.email];
            [[Crashlytics sharedInstance] setUserEmail:customer.email];
            
            if (self.completion) {
                self.completion(AUTHENTICATION_FINISHED_WITH_LOGIN);
            } else {
                [((UIViewController *)self.delegate).navigationController popViewControllerAnimated:YES];
            }
        } else {
            //EVENT: LOGIN / FAILURE
            BaseViewController *baseViewController = (BaseViewController *)self.delegate;
            if(![baseViewController showNotificationBar:error isSuccess:NO]) {
                for(NSDictionary* errorField in [error.userInfo objectForKey:@"errorMessages"]) {
                    NSString *fieldName = errorField[@"field"];
                    if ([fieldName isEqualToString:@"password"]) {
                        [self.passwordControl showErrorMsg:errorField[@"message"]];
                    } else if ([fieldName isEqualToString:@"email"]) {
                        [self.emailControl showErrorMsg:errorField[@"message"]];
                    }
                }
            }
        }
    }];
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    
    // Legacy actions after login
    [RICustomer resetCustomerAsGuest];
    NSDictionary *metadata = ((ApiResponseData *)data).metadata;
    if ([metadata isKindOfClass:[NSDictionary class]]) {
        RICustomer *customerObject = [RICustomer parseCustomerWithJson:[metadata objectForKey:@"customer_entity"]];
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
    }
}

- (IBAction)forgotPasswordButtonPressed:(id)sender {
    if([self.delegate respondsToSelector:@selector(wantsToShowForgetPassword)]) {
        [self.delegate wantsToShowForgetPassword];
    }
}

- (IBAction)continueWithoutLoginBtnTapped:(id)sender {
    if([self.delegate respondsToSelector:@selector(wantsToContinueWithoutLogin)]) {
        [self.delegate wantsToContinueWithoutLogin];
    }
}

@end
