//
//  SignUpViewController.m
//  Bamilo
//
//  Created by Ali saiedifar on 2/8/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "SignUpViewController.h"

//Lagacy importing
#import "RICustomer.h"
#import "JAUtils.h"

#define cSignUpMethodEmail @"email"
#define cSignUpMethodGoogle @"sso-google"

@interface SignUpViewController()
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) FormViewControl *formController;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formController = [[FormViewControl alloc] init];
    self.formController.delegate = self;
    
    [self.tableView setContentInset: UIEdgeInsetsMake(28, 0, 0, 0)];
    self.formController.tableView = self.tableView;

    FormItemModel *melliCode = [[FormItemModel alloc]
                                initWithTextValue:nil
                                fieldName: @"customer[national_id]"
                                andIcon:nil
                                placeholder:@"کد ملی"
                                type:InputTextFieldControlTypeNumerical
                                validation: [[FormItemValidation alloc] initWithRequired:YES max:10 min:10 withRegxPatter:nil]
                                selectOptions:nil];
    
    
    FormItemModel *email = [FormItemModel emailWithFieldName:@"customer[email]"];
    FormItemModel *firstName = [FormItemModel firstNameFieldWithFiedName:@"customer[first_name]"];
    FormItemModel *lastName = [FormItemModel lastNameWithFieldName:@"customer[last_name]"];
    FormItemModel *phone = [FormItemModel phoneWithFieldName:@"customer[phone]"];
    FormItemModel *password = [FormItemModel passWordWithFieldName:@"customer[password]"];
    
    self.formController.submitTitle = @"ثبت نام";
    self.title = STRING_SIGNUP;
    self.formController.formModelList = [NSMutableArray arrayWithArray:@[ melliCode, firstName, lastName, email, password, phone]];
    
    [self.formController setupTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.formController registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.formController unregisterForKeyboardNotifications];
}

#pragma mark - formControlDelegate
- (void)formSubmitButtonTapped {
    if (![self.formController isFormValid]) {
        [self.formController showAnyErrorInForm];
        return;
    }
    
    [[AuthenticationDataManager sharedInstance] signupUser:self withFieldsDictionary:[self.formController getMutableDictionaryOfForm] completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
            
            //EVENT: SIGNUP / SUCCESS
            [TrackerManager postEvent:[EventFactory signup:cSignUpMethodEmail success:YES] forName:[SignUpEvent name]];
            
            if (self.completion) {
                self.completion(AUTHENTICATION_FINISHED_WITH_REGISTER);
            } else {
                [((UIViewController *)self.delegate).navigationController popViewControllerAnimated:YES];
            }
        } else {
            //EVENT: SIGNUP / FAILURE
            [TrackerManager postEvent:[EventFactory signup:cSignUpMethodEmail success:NO] forName:[SignUpEvent name]];
            
            BaseViewController *baseViewController = (BaseViewController *)self.delegate;
            if(![baseViewController showNotificationBar:error isSuccess:NO]) {
                for(NSDictionary* errorField in [error.userInfo objectForKey:kErrorMessages]) {
                    NSString *fieldName = [NSString stringWithFormat:@"customer[%@]", errorField[@"field"]];
                    [self.formController showErrorMessageForField:fieldName errorMsg:errorField[kMessage]];
                }
            }
        }
    }];
}

#pragma mark - DataServiceProtocol
- (void)bind:(id)data forRequestId:(int)rid {
    
    
    
    // --------------- Legacy actions --------------
    RICustomer *customerObject = [(NSDictionary*)data objectForKey:@"customer"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableDictionary *trackingDictionary = [[NSMutableDictionary alloc] init];
    [trackingDictionary setValue:customerObject.customerId forKey:kRIEventLabelKey];
    [trackingDictionary setValue:@"CreateSuccess" forKey:kRIEventActionKey];
    [trackingDictionary setValue:@"Account" forKey:kRIEventCategoryKey];
    [trackingDictionary setValue:customerObject.customerId forKey:kRIEventUserIdKey];
    [trackingDictionary setValue:customerObject.firstName forKey:kRIEventUserFirstNameKey];
    [trackingDictionary setValue:customerObject.lastName forKey:kRIEventUserLastNameKey];
    [trackingDictionary setValue:customerObject.gender forKey:kRIEventGenderKey];
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
    [[RITrackingWrapper sharedInstance] trackEvent:[NSNumber numberWithInt:RIEventRegisterSuccess] data:[trackingDictionary copy]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kUserLoggedInNotification object:nil];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if (self.fromSideMenu) {
        [userInfo setObject:@YES forKey:@"from_side_menu"];
    }
}

#pragma mark - PerformanceTrackerProtocol
-(NSString *)getPerformanceTrackerScreenName {
    return @"SignUp";
}

@end
