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

@interface SignUpViewController()
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, strong) FormViewControl *formController;
@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.formController = [[FormViewControl alloc] init];
    self.formController.delegate = self;
    self.formController.tableView = self.tableView;

    FormItemModel *melliCode = [[FormItemModel alloc]
                                initWithTitle:nil
                                fieldName: @"customer[national_id]"
                                andIcon:nil
                                placeholder:@"کد ملی"
                                type:InputTextFieldControlTypeNumerical
                                validation: [[FormItemValidation alloc] initWithRequired:YES max:10 min:10 withRegxPatter:nil]
                                selectOptions:nil];
    
    
    FormItemModel *email = [[FormItemModel alloc]
                                initWithTitle:nil
                            fieldName: @"customer[email]"
                                andIcon:nil
                                placeholder:@"ایمیل"
                                type:InputTextFieldControlTypeEmail
                                validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:[NSString emailRegxPattern]]
                                selectOptions:nil];
    
    FormItemModel *name = [[FormItemModel alloc]
                            initWithTitle:nil
                           fieldName: @"customer[first_name]"
                            andIcon:nil
                            placeholder:@"نام"
                            type:InputTextFieldControlTypeString
                            validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]
                            selectOptions:nil];

    
    FormItemModel *lastname = [[FormItemModel alloc]
                              initWithTitle:nil
                               fieldName: @"customer[last_name]"
                              andIcon:nil
                              placeholder:@"نام خانوادگی"
                              type:InputTextFieldControlTypeString
                              validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:2 withRegxPatter:nil]
                              selectOptions:nil];

    
    FormItemModel *password = [[FormItemModel alloc]
                               initWithTitle:nil
                               fieldName: @"customer[password]"
                               andIcon:nil
                               placeholder:@"رمز عبور"
                               type:InputTextFieldControlTypePassword
                               validation: [[FormItemValidation alloc] initWithRequired:YES max:50 min:6 withRegxPatter:nil]
                               selectOptions:nil];
    
    FormItemModel *phone = [[FormItemModel alloc]
                               initWithTitle:nil
                            fieldName: @"customer[phone]"
                               andIcon:nil
                               placeholder:@"تلفن همراه"
                               type:InputTextFieldControlTypeNumerical
                               validation: [[FormItemValidation alloc] initWithRequired:YES max:0 min:0 withRegxPatter:nil]
                               selectOptions:nil];

    
    
    self.formController.submitTitle = @"ثبت نام";
    self.formController.formMessage = @"ظاهرا مشتری جدید بامیلو هستید،خواهشمندیم اطلاعات بیشتری برای ساخت حساب کاربری خود ارایه دهید ";
    self.title = STRING_SIGNUP;
    self.formController.formListModel = [NSMutableArray arrayWithArray:@[melliCode, name, lastname, email, password, phone]];
    
    [self.formController setupTableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.formController registerForKeyboardNotifications];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.formController unregisterForKeyboardNotifications];
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
    if (self.completion) {
        self.completion(AUTHENTICATION_FINISHED_WITH_REGISTER);
    }
}

#pragma mark - formControlDelegate
- (void)submitBtnTapped {
    if (![self.formController isFormValid]) {
        return;
    }
    
    [[DataManager sharedInstance] signupUser:self withFieldsDictionary:[self.formController getMutableDictionaryOfForm] completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
        } else {
            for(NSDictionary* errorField in [error.userInfo objectForKey:@"errorMessages"]) {
                NSString *fieldName = [NSString stringWithFormat:@"customer[%@]", errorField[@"field"]];
                
                [self.formController showErrorMessgaeForField:fieldName errorMsg:errorField[@"message"]];
            }
        }
    }];
}

- (void)viewNeedsToEndEditing {
    [self.view endEditing:YES];
}

@end
